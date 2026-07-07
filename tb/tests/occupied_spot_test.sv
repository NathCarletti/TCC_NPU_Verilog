`ifndef OCCUPIED_SPOT_TEST_SV
`define OCCUPIED_SPOT_TEST_SV

class occupied_spot_test extends base_test;

  `uvm_component_utils(occupied_spot_test)

  function new(string name = "occupied_spot_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    occupied_spot_sequence seq;
    phase.raise_objection(this);
    seq = occupied_spot_sequence::type_id::create("seq");
    seq.start(env.m_axi_agent.sequencer);
    phase.drop_objection(this);
  endtask

endclass : occupied_spot_test

`endif

