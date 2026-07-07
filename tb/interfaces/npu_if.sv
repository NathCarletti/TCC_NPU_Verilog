`ifndef NPU_IF_SV
`define NPU_IF_SV


interface npu_if(input logic clk, input logic rstn);
  logic        busy;
  logic        done;
  logic [7:0]  result;
  logic [1:0]  parking_class;
  logic        fifo_empty;
  logic        fifo_full;
  logic [7:0]  npu_d_out;
  logic [15:0] mac0_out_debug;
  logic [15:0] mac1_out_debug;
  logic [15:0] relu0_out_debug;
  logic [15:0] relu1_out_debug;
endinterface : npu_if

`endif
