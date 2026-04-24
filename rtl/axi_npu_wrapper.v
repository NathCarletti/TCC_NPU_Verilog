`timescale 1ns / 1ps

module npu_axi_wrapper (

    input wire clk,
    input wire rstn,

    // AXI WRITE
    input wire [31:0] s_axi_awaddr,
    input wire s_axi_awvalid,
    output reg s_axi_awready,

    input wire [31:0] s_axi_wdata,
    input wire [3:0]  s_axi_wstrb,
    input wire s_axi_wvalid,
    output reg s_axi_wready,

    output reg [1:0] s_axi_bresp,
    output reg s_axi_bvalid,
    input wire s_axi_bready,

    // AXI READ
    input wire [31:0] s_axi_araddr,
    input wire s_axi_arvalid,
    output reg s_axi_arready,

    output reg [31:0] s_axi_rdata,
    output reg [1:0] s_axi_rresp,
    output reg s_axi_rvalid,
    input wire s_axi_rready
);

    // =========================
    // REGISTRADORES (mapeados para sensores)
    // =========================
    reg [7:0] da_reg;      // distance
    reg [7:0] db_reg;      // delta
    reg [7:0] dc_reg;      // time
    reg [7:0] dd_reg;      // lux
    reg       start_reg;
    reg       start_reg_d; // delayed para auto-clear

    reg [7:0] result_reg;
    reg [1:0] parking_class_reg;  // latch da classe final
    reg [1:0] status_reg; // [0]=busy, [1]=done

    // =========================
    // NPU (Interface real do projeto)
    // =========================
    wire [7:0]  npu_d_out;
    wire        npu_fifo_full, npu_fifo_empty;
    wire        npu_busy, npu_done;

    npu_top u_npu (
        .CLKEXT(clk),
        .RST_GLO(~rstn),              // RST_GLO ativo-alto, rstn ativo-baixo
        .START(start_reg && !start_reg_d),  
        .SSFR(16'd0),
        .CON_SIG(16'd0),
        .DA(da_reg),
        .DB(db_reg),
        .DC(dc_reg),
        .DD(dd_reg),
        .BIAS_IN(8'd1),
        .D_OUT(npu_d_out),
        .FIFO_FULL(npu_fifo_full),
        .FIFO_EMPTY(npu_fifo_empty),
        .BUSY(npu_busy),
        .DONE(npu_done),
        .npu_out_rd_en(1'b1)       // Sempre ler FIFO
    );

    // =========================
    // CAPTURA RESULTADO e STATUS
    // =========================
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            result_reg <= 0;
            parking_class_reg <= 0;
            status_reg <= 0;
            start_reg_d <= 0;
        end else begin
            // Delay START para gerar pulso de 1 ciclo
            start_reg_d <= start_reg;
            
            // Status
            status_reg[0] <= npu_busy;

            // DONE permanece alto até o próximo START, para garantir que a TB possa ler o resultado antes de limpar
            if (npu_done)
                status_reg[1] <= 1'b1;

            // limpa DONE ao iniciar novo processamento
            if (start_reg && !start_reg_d)
                status_reg[1] <= 1'b0;

            // Captura resultado quando NPU termina
            if (npu_done) begin
                result_reg <= npu_d_out;
                // Latch da classe final (mantém após DONE)
                if (db_reg > 8'd40)  // delta alto = obstruída
                    parking_class_reg <= 2'b10;  // amarelo
                else if (npu_d_out == 8'd1)  // index=1 = livre
                    parking_class_reg <= 2'b00;  // verde
                else
                    parking_class_reg <= 2'b01;  // vermelho (ocupada)
            end
        end
    end

    // =========================
    // WRITE AXI
    // =========================
    reg aw_done, w_done;
    
    always @(posedge clk) begin
        if (!rstn) begin
            aw_done <= 1'b0;
            w_done <= 1'b0;
            s_axi_bvalid <= 1'b0;
            start_reg <= 1'b0;
        end else begin
            // Handshake: aceita escrita quando ambos VALID chegam
            s_axi_awready <= ~aw_done;
            s_axi_wready  <= ~w_done;

            if (s_axi_awvalid && !aw_done)
                aw_done <= 1'b1;
            if (s_axi_wvalid && !w_done)
                w_done <= 1'b1;

            // Processa escrita quando ambos prontos
            if (aw_done && w_done) begin
                case (s_axi_awaddr[5:0])
                    6'h00: da_reg      <= s_axi_wdata[7:0];   // distance
                    6'h04: db_reg      <= s_axi_wdata[7:0];   // delta
                    6'h08: dc_reg      <= s_axi_wdata[7:0];   // time
                    6'h0C: dd_reg      <= s_axi_wdata[7:0];   // lux
                    6'h10: start_reg   <= s_axi_wdata[0];     // START
                endcase

                s_axi_bvalid <= 1'b1;
                s_axi_bresp  <= 2'b00; // OKAY
                aw_done <= 1'b0;
                w_done <= 1'b0;
            end else if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
            end
        end
    end

    // =========================
    // READ AXI (com handshake)
    // =========================
    always @(posedge clk) begin
        if (!rstn) begin
            s_axi_arready <= 1'b1;
            s_axi_rvalid  <= 1'b0;
        end else begin
            s_axi_arready <= 1'b1;

            if (s_axi_arvalid) begin
                case (s_axi_araddr[5:0])
                    6'h00: s_axi_rdata <= {24'd0, da_reg};         // distance
                    6'h04: s_axi_rdata <= {24'd0, db_reg};         // delta
                    6'h08: s_axi_rdata <= {24'd0, dc_reg};         // time
                    6'h0C: s_axi_rdata <= {24'd0, dd_reg};         // lux
                    6'h10: s_axi_rdata <= {31'd0, start_reg};      // START
                    6'h14: s_axi_rdata <= {30'd0, status_reg};     // STATUS [busy, done]
                    6'h18: s_axi_rdata <= {24'd0, result_reg};     // resultado full
                    6'h1C: s_axi_rdata <= {30'd0, parking_class_reg}; // classe final
                    default: s_axi_rdata <= 32'd0;
                endcase

                s_axi_rvalid <= 1'b1;
                s_axi_rresp  <= 2'b00;
            end else if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
            end
        end
    end

endmodule