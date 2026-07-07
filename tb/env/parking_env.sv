`ifndef PARKING_ENV_SV
`define PARKING_ENV_SV

class parking_env extends uvm_env;

  `uvm_component_utils(parking_env)

  axi_agent          m_axi_agent;
  npu_monitor        m_npu_monitor;
  parking_scoreboard m_scoreboard;
  parking_coverage   m_coverage;

  function new(string name = "parking_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
  super.build_phase(phase);

  m_axi_agent   = axi_agent::type_id::create("axi_agent", this);
  m_npu_monitor = npu_monitor::type_id::create("npu_monitor", this);
  m_scoreboard  = parking_scoreboard::type_id::create("scoreboard", this);
  m_coverage    = parking_coverage::type_id::create("coverage", this);
endfunction

function void connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  m_axi_agent.sequencer.result_port.connect(m_scoreboard.analysis_export);
  m_axi_agent.sequencer.result_port.connect(m_coverage.result_imp);
  m_npu_monitor.status_port.connect(m_coverage.status_imp);
endfunction

endclass : parking_env

`endif



