`ifndef PARKING_SCOREBOARD_SV
`define PARKING_SCOREBOARD_SV


class parking_scoreboard extends uvm_subscriber#(parking_result);

  `uvm_component_utils(parking_scoreboard)

  function new(string name = "parking_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void write(parking_result t);
    string status;
    if (!t.done_seen) begin
      `uvm_error(get_full_name(), $sformatf("Scenario %s did not observe DONE", t.scenario))
      return;
    end

    if (t.actual_class == t.expected_class) begin
      status = "PASS";
      `uvm_info(get_full_name(), $sformatf("%s: %s expected=%0b actual=%0b latency=%0t", t.scenario, status, t.expected_class, t.actual_class, t.latency), UVM_LOW)
    end else begin
      status = "FAIL";
      `uvm_error(get_full_name(), $sformatf("%s: %s expected=%0b actual=%0b latency=%0t", t.scenario, status, t.expected_class, t.actual_class, t.latency))
    end
  endfunction

endclass : parking_scoreboard

`endif



