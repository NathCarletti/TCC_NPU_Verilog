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
  logic        piso_en_piso_out;
  logic        piso_shift_out;
  logic        piso_clr_piso_out;
  logic [31:0] shift_reg;
  logic [7:0]  piso_internal_d_out;
  logic [7:0]  piso_dout;
  logic [7:0]  fifo_data_in;
  logic        fifo_wr_en;
  logic        fifo_rd_en;
  logic [7:0]  fifo_data_out;
  logic [7:0]  wr_ptr;
  logic [7:0]  rd_ptr;
  logic [7:0]  count;
  logic [7:0]  mem0_debug;
  logic [7:0]  mem1_debug;
  logic [7:0]  out_rd_en_reg;
  logic [7:0]  out_rd_en_reg_d;
  logic [7:0]  done_edge;
  logic [7:0]  result_reg;
  logic [7:0] SEL_OUT;
  logic [7:0] index;
  logic [7:0] largest;  
  logic [7:0]  EN_COMP;
  logic [7:0]  RST_COMP;
  logic [7:0]  trig;
  logic [7:0]  in1;
  logic [7:0]  in2;
   logic [7:0] cont;

 

endinterface : npu_if

`endif
