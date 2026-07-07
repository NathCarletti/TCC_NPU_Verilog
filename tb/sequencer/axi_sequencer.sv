`ifndef AXI_SEQUENCER_SV
`define AXI_SEQUENCER_SV


class axi_sequencer extends uvm_sequencer#(axi_transaction);

  `uvm_component_utils(axi_sequencer)

  uvm_analysis_port#(parking_result) result_port;

  function new(string name = "axi_sequencer", uvm_component parent = null);
    super.new(name, parent);
    result_port = new("result_port", this);
  endfunction

endclass : axi_sequencer

`endif



