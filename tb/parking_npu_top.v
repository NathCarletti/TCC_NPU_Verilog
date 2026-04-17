// Top-level de integração para o sistema de classificação de vaga de estacionamento
module parking_npu_top (
    input  wire        clk,
    input  wire        resetn,

    // Entradas simuladas (sinais de sensores)
    input  wire [7:0]  sensor_distance,    // distância do ultrassônico (cm)
    input  wire [7:0]  sensor_delta,       // variação de distância
    input  wire [7:0]  sensor_time,        // tempo / timestamp
    input  wire [7:0]  sensor_lux,         // luminosidade (opcional)

    // Controle de início de inferência
    input  wire        start,

    // Saídas de estado
    output wire [1:0]  parking_class, // 0=livre,1=ocupada,2=obstruída
    output wire        npu_busy,
    output wire        npu_done,
    output wire        fifo_full,
    output wire        fifo_empty,

    // Saídas para LEDs
    output wire        led_green,
    output wire        led_yellow,
    output wire        led_red,

    // FIFO read control / debug
    output wire        out_rd_en,
    output wire        fifo_read,
    output wire [31:0] debug_fifo_read_count,

    // Debug signals
    output wire [31:0] debug_cycle_count,
    output wire [1:0]  debug_npu_state,
    output wire [31:0] debug_npu_input,
    output wire [7:0]  debug_npu_output
);

    // Sinais internos da NPU
    wire [7:0] npu_dout;
    wire [7:0] npu_bias = 8'd1;  // bias fixo para exemplo

    // A NPU recebe 4 canais de dados, nosso exemplo só tem 4 sensores simples.
    wire [7:0] npu_DA = sensor_distance;
    wire [7:0] npu_DB = sensor_delta;
    wire [7:0] npu_DC = sensor_time;
    wire [7:0] npu_DD = sensor_lux;

    // Debug registers
    reg [31:0] cycle_count;
    reg [1:0]  npu_state_reg;
    reg [31:0] npu_input_reg;
    reg [7:0]  npu_output_reg;
    reg [1:0]  parking_class_reg;

    // START mantido por vários ciclos (para dar margem ao bloco NPU)
    reg [2:0] start_hold;
    wire      start_internal = (start_hold != 3'd0);

    // Gerar pulso START para 'npu_top' (1 ciclo) a partir de hold longo
    reg start_q;
    wire start_pulse = start_internal && !start_q;

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            start_q <= 1'b0;
            start_hold <= 3'd0;
        end else begin
            start_q <= start_internal;
            if (start)
                start_hold <= 3'd3; // manter por 3 ciclos
            else if (start_hold != 3'd0)
                start_hold <= start_hold - 1;
        end
    end

    // Contador de ciclos global para debug
    always @(posedge clk or negedge resetn) begin
        if (!resetn)
            cycle_count <= 32'd0;
        else
            cycle_count <= cycle_count + 1;
    end

    // FIFO (debug)
    reg out_rd_en_reg;
    reg fifo_read_reg; //read signal
    reg [31:0] fifo_read_count; //contagem

    // Amostra dos dados de entrada e saída mantendo o valor atual
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            npu_input_reg   <= 32'd0;
            npu_output_reg  <= 8'd0;
            out_rd_en_reg   <= 1'b0;
            fifo_read_reg   <= 1'b0;
            fifo_read_count <= 32'd0;
        end else begin
            npu_input_reg <= {sensor_distance, sensor_delta, sensor_time, sensor_lux};

            // Quando FIFO não estiver vazio, mantemos read ativo
            if (!fifo_empty) begin
                out_rd_en_reg <= 1'b1;
                fifo_read_reg <= 1'b1;
                fifo_read_count <= fifo_read_count + 1;
                npu_output_reg <= npu_dout;  // captura o valor listado no D_OUT
            end else begin
                out_rd_en_reg <= 1'b0;
                fifo_read_reg <= 1'b0;
            end
        end
    end

    // NPU state machine simples para debug (0=idle,1=busy,2=done)
    always @(*) begin
        if (npu_busy)
            npu_state_reg = 2'b01;
        else if (npu_done)
            npu_state_reg = 2'b10;
        else
            npu_state_reg = 2'b00;
    end

    // Latch da classe final para manter LEDs acesos após a conclusão
    always @(posedge clk or negedge resetn) begin
        if (!resetn)
            parking_class_reg <= 2'b00;
        else if (npu_done)
            parking_class_reg <= (sensor_delta > 8'd40) ? 2'b10 :  // obstruída se delta alta
                                 (npu_dout == 8'd1) ? 2'b00 :       // livre se index=1
                                 2'b01;                             // ocupada se index=2
    end

    // Instancia NPU existente
    npu_top u_npu_top (
        .CLKEXT(clk),
        .RST_GLO(!resetn),          // npu_top usa reset ativo-alto
        .START(start_pulse),
        .SSFR(16'd0),
        .CON_SIG(16'd0),
        .DA(npu_DA),
        .DB(npu_DB),
        .DC(npu_DC),
        .DD(npu_DD),
        .BIAS_IN(npu_bias),
        .D_OUT(npu_dout),
        .FIFO_FULL(fifo_full),
        .FIFO_EMPTY(fifo_empty),
        .BUSY(npu_busy),
        .DONE(npu_done),
        .npu_out_rd_en(out_rd_en_reg) // Pop do FIFO na direção do NPU
    );

    // Debug outputs
    assign debug_cycle_count = cycle_count;
    assign debug_npu_state  = npu_state_reg;
    assign debug_npu_input  = npu_input_reg;
    assign debug_npu_output = npu_output_reg;
    assign out_rd_en = out_rd_en_reg;
    assign fifo_read = fifo_read_reg;
    assign debug_fifo_read_count = fifo_read_count;

    // Traduz o resultado de 8 bits da NPU para 3 classes
    // Assumimos que a NPU já produz um valor em {0,1,2}. Caso contrário, truncar.
    assign parking_class = parking_class_reg;

    // Controlador de LEDs
    parking_controller u_parking_controller (
        .parking_class(parking_class),
        .led_green(led_green),
        .led_yellow(led_yellow),
        .led_red(led_red)
    );

endmodule
