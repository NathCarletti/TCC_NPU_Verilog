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
    reg       out_rd_en_reg;
    reg      fifo_read_reg; //read signal
    reg [31:0] fifo_read_count; //contagem

    reg [15:0] mac0_out_reg, mac1_out_reg;
    reg [15:0] relu0_out_reg, relu1_out_reg;
    // =========================
    // NPU (Interface real do projeto)
    // =========================
    wire [7:0]  npu_d_out;
    wire        npu_fifo_full, npu_fifo_empty;
    wire        npu_busy, npu_done;
    wire [15:0] npu_mac0_out, npu_mac1_out;
    wire [15:0] npu_relu0_out, npu_relu1_out;

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
        .npu_out_rd_en(out_rd_en_reg),
        .mac0_out_debug(npu_mac0_out),
        .mac1_out_debug(npu_mac1_out),
        .relu0_out_debug(npu_relu0_out),
        .relu1_out_debug(npu_relu1_out)
    );

    // Detecta borda de subida do DONE
    reg npu_done_d;
    wire done_edge;

    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            npu_done_d <= 1'b0;
        else
            npu_done_d <= npu_done;
    end

    assign done_edge = npu_done && !npu_done_d;

    // =====================================================
    // BLOCO PRINCIPAL
    // =====================================================    
    always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        result_reg <= 0;
        parking_class_reg <= 0;
        status_reg <= 0;
        start_reg_d <= 0;
        out_rd_en_reg <= 1'b0;
    end else begin
        // Delay START para gerar pulso de 1 ciclo
        start_reg_d <= start_reg;
        
        // Status
        status_reg[0] <= npu_busy;

        // DONE latched
        if (npu_done)
            status_reg[1] <= 1'b1;

        // limpa DONE ao iniciar novo processamento
        if (start_reg && !start_reg_d)
            status_reg[1] <= 1'b0;

        // =========================
        // CONTROLE DA FIFO DO NPU
        // =========================
        if (!npu_fifo_empty)
            out_rd_en_reg <= 1'b1;
        else
            out_rd_en_reg <= 1'b0;

        // =========================
        // CAPTURA DO RESULTADO
        // =========================
        if (!npu_fifo_empty) begin
            result_reg <= npu_d_out;
            
            // Capture MAC and ReLU debug values
            mac0_out_reg <= npu_mac0_out;
            mac1_out_reg <= npu_mac1_out;
            relu0_out_reg <= npu_relu0_out;
            relu1_out_reg <= npu_relu1_out;

            // Latch da classe final
            if (db_reg > 8'd40)
                parking_class_reg <= 2'b10;  // obstruída
            else if (npu_d_out == 8'd1)
                parking_class_reg <= 2'b00;  // livre
            else
                parking_class_reg <= 2'b01;  // ocupada
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
                    6'h18: s_axi_rdata <= {24'd0, result_reg};     // resultado (index)
                    6'h1C: s_axi_rdata <= {30'd0, parking_class_reg}; // classe final
                    6'h20: s_axi_rdata <= mac0_out_reg;            // MAC0 completo (16 bits)
                    6'h24: s_axi_rdata <= mac1_out_reg;            // MAC1 completo (16 bits)
                    6'h28: s_axi_rdata <= relu0_out_reg;           // ReLU0 completo (16 bits)
                    6'h2C: s_axi_rdata <= relu1_out_reg;           // ReLU1 completo (16 bits)
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