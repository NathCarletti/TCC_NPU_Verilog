`ifndef FREE_SPOT_TEST_SV
`define FREE_SPOT_TEST_SV


class free_spot_test extends base_test;

  `uvm_component_utils(free_spot_test)

  function new(string name = "free_spot_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    free_spot_sequence seq;
    phase.raise_objection(this);
    seq = free_spot_sequence::type_id::create("seq");
    seq.start(env.m_axi_agent.sequencer);
    phase.drop_objection(this);
  endtask

endclass : free_spot_test

`endif

