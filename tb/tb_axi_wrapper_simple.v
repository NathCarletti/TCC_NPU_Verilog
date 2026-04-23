// Testbench para AXI NPU Wrapper (Versão Simplificada)
// Testa os 3 cenários: livre, ocupada, obstruída

`timescale 1ns/1ps

module tb_axi_npu_wrapper;

    reg         clk;
    reg         rstn;

    // AXI Signals
    reg  [31:0] s_axi_awaddr;
    reg         s_axi_awvalid;
    wire        s_axi_awready;

    reg  [31:0] s_axi_wdata;
    reg  [3:0]  s_axi_wstrb = 4'b1111;
    reg         s_axi_wvalid;
    wire        s_axi_wready;

    wire [1:0]  s_axi_bresp;
    wire        s_axi_bvalid;
    reg         s_axi_bready;

    reg  [31:0] s_axi_araddr;
    reg         s_axi_arvalid;
    wire        s_axi_arready;

    wire [31:0] s_axi_rdata;
    wire [1:0]  s_axi_rresp;
    wire        s_axi_rvalid;
    reg         s_axi_rready;

    // DUT
    npu_axi_wrapper u_dut (
        .clk(clk),
        .rstn(rstn),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready)
    );

    // Clock 100 MHz
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ================================================================
    // Tasks AXI
    // ================================================================

    task axi_write(input [31:0] addr, input [31:0] data);
        begin
            @(posedge clk);
            s_axi_awaddr  = addr;
            s_axi_awvalid = 1'b1;
            s_axi_wdata   = data;
            s_axi_wvalid  = 1'b1;
            s_axi_bready  = 1'b1;

            wait(s_axi_awready && s_axi_wready);
            @(posedge clk);
            s_axi_awvalid = 1'b0;
            s_axi_wvalid  = 1'b0;

            wait(s_axi_bvalid);
            @(posedge clk);
            s_axi_bready  = 1'b0;

            $display("[AXI_WR] addr=0x%02x data=0x%08x", addr[7:0], data);
        end
    endtask

    task axi_read(input [31:0] addr, output [31:0] data);
        begin
            @(posedge clk);
            s_axi_araddr  = addr;
            s_axi_arvalid = 1'b1;
            s_axi_rready  = 1'b1;

            wait(s_axi_arready);
            @(posedge clk);
            s_axi_arvalid = 1'b0;

            wait(s_axi_rvalid);
            data = s_axi_rdata;
            @(posedge clk);
            s_axi_rready  = 1'b0;

            $display("[AXI_RD] addr=0x%02x data=0x%08x", addr[7:0], data);
        end
    endtask

    task wait_done;
        reg [31:0] status;
        integer timeout;
        begin
            timeout = 0;
            repeat(2000) begin
                axi_read(32'h0014, status);  // Read STATUS
                if (status[1] == 1'b1) begin
                    $display("[TB] NPU DONE! status=0x%08x", status);
                    timeout = 0;
                    break;
                end
                timeout = timeout + 1;
            end
            if (timeout > 0) begin
                $display("[TB] ERROR: Timeout aguardando DONE");
            end
        end
    endtask

    // ================================================================
    // Teste Principal
    // ================================================================
    initial begin
        reg [31:0] data;
        integer i;

        $display("\n[TB] ========================================");
        $display("[TB] Iniciando Testbench AXI NPU Wrapper");
        $display("[TB] ========================================\n");

        // Reset
        rstn = 1'b0;
        s_axi_awvalid = 1'b0;
        s_axi_wvalid  = 1'b0;
        s_axi_arvalid = 1'b0;
        s_axi_bready  = 1'b0;
        s_axi_rready  = 1'b0;
        repeat(10) @(posedge clk);

        rstn = 1'b1;
        repeat(5) @(posedge clk);

        // ================================================================
        // CENÁRIO 0: VAGA LIVRE
        // ================================================================
        $display("\n[TB] ========== CENÁRIO 0: VAGA LIVRE ==========");
        $display("[TB] Input: dist=200, delta=2, time=30, lux=120");
        
        axi_write(32'h0000, 32'd200);  // DA = 200 (distance)
        axi_write(32'h0004, 32'd2);    // DB = 2 (delta - baixo = livre)
        axi_write(32'h0008, 32'd30);   // DC = 30 (time)
        axi_write(32'h000C, 32'd120);  // DD = 120 (lux)
        repeat(5) @(posedge clk);
        
        axi_write(32'h0010, 32'd1);    // START
        repeat(5) @(posedge clk);
        
        wait_done();
        repeat(10) @(posedge clk);
        
        axi_read(32'h0018, data);  // Resultado bruto
        $display("[TB] Resultado bruto: 0x%02x", data[7:0]);
        
        axi_read(32'h001C, data);  // Classe final
        $display("[TB] Classe final: %b (esperado 00 = verde/livre)\n", data[1:0]);

        // ================================================================
        // CENÁRIO 1: VAGA OCUPADA
        // ================================================================
        $display("[TB] ========== CENÁRIO 1: VAGA OCUPADA ==========");
        $display("[TB] Input: dist=30, delta=1, time=20, lux=80");
        
        axi_write(32'h0000, 32'd30);   // DA = 30
        axi_write(32'h0004, 32'd1);    // DB = 1 (delta baixo)
        axi_write(32'h0008, 32'd20);   // DC = 20
        axi_write(32'h000C, 32'd80);   // DD = 80
        repeat(5) @(posedge clk);
        
        axi_write(32'h0010, 32'd1);    // START
        repeat(5) @(posedge clk);
        
        wait_done();
        repeat(10) @(posedge clk);
        
        axi_read(32'h0018, data);  // Resultado bruto
        $display("[TB] Resultado bruto: 0x%02x", data[7:0]);
        
        axi_read(32'h001C, data);  // Classe final
        $display("[TB] Classe final: %b (esperado 01 = vermelho/ocupada)\n", data[1:0]);

        // ================================================================
        // CENÁRIO 2: VAGA OBSTRUÍDA
        // ================================================================
        $display("[TB] ========== CENÁRIO 2: VAGA OBSTRUÍDA ==========");
        $display("[TB] Input: dist=110, delta=50, time=15, lux=20");
        
        axi_write(32'h0000, 32'd110);  // DA = 110
        axi_write(32'h0004, 32'd50);   // DB = 50 (delta ALTO = obstruída!)
        axi_write(32'h0008, 32'd15);   // DC = 15
        axi_write(32'h000C, 32'd20);   // DD = 20
        repeat(5) @(posedge clk);
        
        axi_write(32'h0010, 32'd1);    // START
        repeat(5) @(posedge clk);
        
        wait_done();
        repeat(10) @(posedge clk);
        
        axi_read(32'h0018, data);  // Resultado bruto
        $display("[TB] Resultado bruto: 0x%02x", data[7:0]);
        
        axi_read(32'h001C, data);  // Classe final
        $display("[TB] Classe final: %b (esperado 10 = amarelo/obstruída)\n", data[1:0]);

        $display("[TB] ========================================");
        $display("[TB] Simulação Completa!");
        $display("[TB] ========================================\n");
        $stop;
    end

endmodule
