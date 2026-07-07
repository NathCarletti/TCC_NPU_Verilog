`ifndef OBSTRUCTED_SPOT_TEST_SV
`define OBSTRUCTED_SPOT_TEST_SV

class obstructed_spot_test extends base_test;

  `uvm_component_utils(obstructed_spot_test)

  function new(string name = "obstructed_spot_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    obstructed_spot_sequence seq;
    phase.raise_objection(this);
    seq = obstructed_spot_sequence::type_id::create("seq");
    seq.start(env.m_axi_agent.sequencer);
    phase.drop_objection(this);
  endtask

endclass : obstructed_spot_test

`endif

