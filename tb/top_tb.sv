`timescale 1ns / 1ps

import uvm_pkg::*;
import parking_uvm_pkg::*;
// `include "D:/Questa_install/questa_fse/verilog_src/uvm-1.2/src/uvm_macros.svh"

module top_tb;

  bit clk;
  bit rstn;

  axi_if axi_vif(clk, rstn);
  npu_if npu_vif(clk, rstn);

  wire [1:0] status_out;
  wire [7:0] result_out;
  wire [1:0] parking_class_out;
  wire       npu_fifo_full_out;
  wire       npu_fifo_empty_out;
  wire       npu_busy_out;
  wire       npu_done_out;
  wire [7:0] npu_d_out_out;
  wire [15:0] npu_mac0_out_debug;
  wire [15:0] npu_mac1_out_debug;
  wire [15:0] npu_relu0_out_debug;
  wire [15:0] npu_relu1_out_debug;

  assign npu_vif.busy            = npu_busy_out;
  assign npu_vif.done            = npu_done_out;
  assign npu_vif.result          = result_out;
  assign npu_vif.parking_class   = parking_class_out;
  assign npu_vif.fifo_empty      = npu_fifo_empty_out;
  assign npu_vif.fifo_full       = npu_fifo_full_out;
  assign npu_vif.npu_d_out       = npu_d_out_out;
  assign npu_vif.mac0_out_debug  = npu_mac0_out_debug;
  assign npu_vif.mac1_out_debug  = npu_mac1_out_debug;
  assign npu_vif.relu0_out_debug = npu_relu0_out_debug;
  assign npu_vif.relu1_out_debug = npu_relu1_out_debug;
  assign npu_vif.piso_en_piso_out    = u_dut.u_npu.fsm_inst.piso.EN_PISO_OUT;
  assign npu_vif.piso_shift_out      = u_dut.u_npu.fsm_inst.piso.SHIFT_OUT;
  assign npu_vif.piso_clr_piso_out   = u_dut.u_npu.fsm_inst.piso.CLR_PISO_OUT;
  assign npu_vif.shift_reg       = u_dut.u_npu.fsm_inst.piso.shift_reg;
  assign npu_vif.piso_internal_d_out = u_dut.u_npu.fsm_inst.piso.D_OUT;
  assign npu_vif.piso_dout       = u_dut.u_npu.fsm_inst.PISO_DOUT;
  assign npu_vif.fifo_data_in    = u_dut.u_npu.fsm_inst.fifo_data_in;
  assign npu_vif.fifo_wr_en      = u_dut.u_npu.fsm_inst.fifo_wr_en;
  assign npu_vif.fifo_rd_en      = u_dut.u_npu.fsm_inst.fifo_rd_en;
  assign npu_vif.fifo_data_out   = u_dut.u_npu.fsm_inst.fifo_data_out;
  assign npu_vif.wr_ptr          = u_dut.u_npu.fsm_inst.out_fifo.wr_ptr;
  assign npu_vif.rd_ptr          = u_dut.u_npu.fsm_inst.out_fifo.rd_ptr;
  assign npu_vif.count           = u_dut.u_npu.fsm_inst.out_fifo.count;
  
  assign npu_vif.mem0_debug =
    u_dut.u_npu.fsm_inst.out_fifo.mem0_debug;
  assign npu_vif.mem1_debug =
    u_dut.u_npu.fsm_inst.out_fifo.mem1_debug;

assign npu_vif.out_rd_en_reg   = u_dut.out_rd_en_reg;
assign npu_vif.out_rd_en_reg_d = u_dut.out_rd_en_reg_d;
assign npu_vif.result_reg      = u_dut.result_reg;
assign npu_vif.SEL_OUT        = u_dut.u_npu.fsm_inst.SEL_OUT;
assign npu_vif.index        = u_dut.u_npu.fsm_inst.index;
assign npu_vif.largest        = u_dut.u_npu.fsm_inst.largest;
assign npu_vif.EN_COMP        = u_dut.u_npu.fsm_inst.comp.EN_COMP;
assign npu_vif.RST_COMP        = u_dut.u_npu.fsm_inst.comp.RST_COMP;
assign npu_vif.trig        = u_dut.u_npu.fsm_inst.comp.trig;
assign npu_vif.in1        = u_dut.u_npu.fsm_inst.comp.in1;
assign npu_vif.in2        = u_dut.u_npu.fsm_inst.comp.in2;
assign npu_vif.cont = u_dut.u_npu.fsm_inst.comp.cont;


  npu_axi_wrapper u_dut (
    .clk(clk),
    .rstn(rstn),
    .s_axi_awaddr(axi_vif.awaddr),
    .s_axi_awvalid(axi_vif.awvalid),
    .s_axi_awready(axi_vif.awready),
    .s_axi_wdata(axi_vif.wdata),
    .s_axi_wstrb(axi_vif.wstrb),
    .s_axi_wvalid(axi_vif.wvalid),
    .s_axi_wready(axi_vif.wready),
    .s_axi_bresp(axi_vif.bresp),
    .s_axi_bvalid(axi_vif.bvalid),
    .s_axi_bready(axi_vif.bready),
    .s_axi_araddr(axi_vif.araddr),
    .s_axi_arvalid(axi_vif.arvalid),
    .s_axi_arready(axi_vif.arready),
    .s_axi_rdata(axi_vif.rdata),
    .s_axi_rresp(axi_vif.rresp),
    .s_axi_rvalid(axi_vif.rvalid),
    .s_axi_rready(axi_vif.rready),
    .status_out(status_out),
    .result_out(result_out),
    .parking_class_out(parking_class_out),
    .npu_fifo_full_out(npu_fifo_full_out),
    .npu_fifo_empty_out(npu_fifo_empty_out),
    .npu_busy_out(npu_busy_out),
    .npu_done_out(npu_done_out),
    .npu_d_out_out(npu_d_out_out),
    .npu_mac0_out_debug(npu_mac0_out_debug),
    .npu_mac1_out_debug(npu_mac1_out_debug),
    .npu_relu0_out_debug(npu_relu0_out_debug),
    .npu_relu1_out_debug(npu_relu1_out_debug)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    rstn = 0;
    axi_vif.awaddr  = 0;
    axi_vif.awvalid = 0;
    axi_vif.wdata   = 0;
    axi_vif.wstrb   = 0;
    axi_vif.wvalid  = 0;
    axi_vif.bready  = 0;
    axi_vif.araddr  = 0;
    axi_vif.arvalid = 0;
    axi_vif.rready  = 0;
    #100;
    rstn = 1;
  end

  initial begin
    uvm_config_db#(virtual axi_if)::set(null, "*", "vif", axi_vif);
    uvm_config_db#(virtual npu_if)::set(null, "*", "npu_vif", npu_vif);
    run_test();
  end

endmodule : top_tb
