`ifndef BASE_TEST_SV
`define BASE_TEST_SV

class base_test extends uvm_test;

  `uvm_component_utils(base_test)

  parking_env env;

  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = parking_env::type_id::create("env", this);
  endfunction

endclass

`endif



