`ifndef OCCUPIED_SPOT_TEST_SV
`define OCCUPIED_SPOT_TEST_SV

class occupied_spot_test extends base_test;

  `uvm_component_utils(occupied_spot_test)

  function new(string name = "occupied_spot_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    occupied_spot_sequence seq;
    occupied_variant_sequence variant_seq;
    write_sequence clear_start;
    phase.raise_objection(this);
    seq = occupied_spot_sequence::type_id::create("seq");
    seq.start(env.m_axi_agent.sequencer);

    // START must return to zero before the second rising-edge start pulse.
    clear_start = write_sequence::type_id::create("clear_start");
    clear_start.addr = 32'h0010;
    clear_start.data = 32'd0;
    clear_start.start(env.m_axi_agent.sequencer);

    variant_seq = occupied_variant_sequence::type_id::create("variant_seq");
    variant_seq.start(env.m_axi_agent.sequencer);
    phase.drop_objection(this);
  endtask

endclass : occupied_spot_test

`endif
