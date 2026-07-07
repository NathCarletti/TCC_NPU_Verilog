`ifndef PARKING_COVERAGE_SV
`define PARKING_COVERAGE_SV

`uvm_analysis_imp_decl(_result)
`uvm_analysis_imp_decl(_status)

class parking_coverage extends uvm_component;

  `uvm_component_utils(parking_coverage)

  uvm_analysis_imp_result#(parking_result, parking_coverage) result_imp;
  uvm_analysis_imp_status#(npu_status_item, parking_coverage) status_imp;

  parking_result  result_sample;
  npu_status_item status_sample;

  covergroup cg_result;
    cp_expected: coverpoint result_sample.expected_class {
      bins free       = {FREE};
      bins occupied   = {OCCUPIED};
      bins obstructed = {OBSTRUCTED};
    }
    cp_actual: coverpoint result_sample.actual_class {
      bins free       = {FREE};
      bins occupied   = {OCCUPIED};
      bins obstructed = {OBSTRUCTED};
    }
    cp_done: coverpoint result_sample.done_seen {
      bins done    = {1};
      bins pending = {0};
    }
    cross cp_expected, cp_actual;
  endgroup

  covergroup cg_status;
    cp_busy: coverpoint status_sample.busy {
      bins idle   = {0};
      bins active = {1};
    }
    cp_done: coverpoint status_sample.done {
      bins none = {0};
      bins pulse = {1};
    }
    cp_fifo_empty: coverpoint status_sample.fifo_empty {
      bins empty     = {1};
      bins not_empty = {0};
    }
    cp_fifo_full: coverpoint status_sample.fifo_full {
      bins full     = {1};
      bins not_full = {0};
    }
    cp_parking_class: coverpoint status_sample.parking_class {
      bins free       = {FREE};
      bins occupied   = {OCCUPIED};
      bins obstructed = {OBSTRUCTED};
    }
  endgroup

  function new(string name = "parking_coverage", uvm_component parent = null);
    super.new(name, parent);
    result_imp = new("result_imp", this);
    status_imp = new("status_imp", this);
    cg_result = new();
    cg_status = new();
  endfunction

  function void write_result(parking_result t);
    result_sample = t;
    cg_result.sample();
  endfunction

  function void write_status(npu_status_item t);
    status_sample = t;
    cg_status.sample();
  endfunction

endclass : parking_coverage

`endif



