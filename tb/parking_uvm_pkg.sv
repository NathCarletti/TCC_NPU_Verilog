package parking_uvm_pkg;

import uvm_pkg::*;
`include "D:/Questa_install/questa_fse/verilog_src/uvm-1.2/src/uvm_macros.svh"

typedef enum bit [1:0] {
  FREE       = 2'b00,
  OCCUPIED   = 2'b01,
  OBSTRUCTED = 2'b10
} parking_class_e;

typedef enum bit {
  AXI_WRITE,
  AXI_READ
} axi_op_e;

typedef struct {
  string         scenario;
  parking_class_e expected_class;
  parking_class_e actual_class;
  time           latency;
  bit            done_seen;
} parking_result;

typedef struct {
  bit             busy;
  bit             done;
  bit [7:0]       result;
  parking_class_e parking_class;
  bit             fifo_empty;
  bit             fifo_full;
  bit [7:0]       npu_d_out;
  bit [15:0]      mac0_out_debug;
  bit [15:0]      mac1_out_debug;
  bit [15:0]      relu0_out_debug;
  bit [15:0]      relu1_out_debug;
  bit             piso_en_piso_out;
  bit             piso_shift_out;
  bit             piso_clr_piso_out;
  bit [31:0]      shift_reg;
  bit [7:0]       piso_internal_d_out;
  bit [7:0]       piso_dout;
  bit [7:0]       fifo_data_in;
  bit             fifo_wr_en;
  bit             fifo_rd_en;
  bit [7:0]       fifo_data_out;
  bit [7:0]       wr_ptr;
  bit [7:0]       rd_ptr;
  bit [7:0]       count;
  bit [31:0]      shift_reg_debug;
} npu_status_item;


`include "sequence_items/axi_transaction.sv"
`include "sequencer/axi_sequencer.sv"
`include "driver/axi_driver.sv"
`include "monitor/axi_monitor.sv"
`include "monitor/npu_monitor.sv"
`include "agent/axi_agent.sv"
`include "scoreboard/parking_scoreboard.sv"
// `include "coverage/parking_coverage.sv"
`include "env/parking_env.sv"
`include "sequences/write_sequence.sv"
`include "sequences/read_sequence.sv"
`include "sequences/free_spot_sequence.sv"
`include "sequences/occupied_spot_sequence.sv"
`include "sequences/obstructed_spot_sequence.sv"
`include "tests/base_test.sv"
`include "tests/free_spot_test.sv"
`include "tests/occupied_spot_test.sv"
`include "tests/obstructed_spot_test.sv"

endpackage : parking_uvm_pkg

