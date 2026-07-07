`ifndef NPU_MONITOR_SV
`define NPU_MONITOR_SV


class npu_monitor extends uvm_monitor;

  `uvm_component_utils(npu_monitor)

  virtual npu_if vif;
  uvm_analysis_port#(npu_status_item) status_port;

  function new(string name = "npu_monitor", uvm_component parent = null);
  super.new(name, parent);
  status_port = new("status_port", this);
endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual npu_if)::get(this, "", "npu_vif", vif)) begin
      `uvm_fatal(get_full_name(), "Virtual NPU interface not set for monitor")
    end
  endfunction

  task run_phase(uvm_phase phase);
    npu_status_item item;
    forever begin
      @(posedge vif.clk);
      item.busy            = vif.busy;
      item.done            = vif.done;
      item.result          = vif.result;
      item.parking_class   = parking_class_e'(vif.parking_class);
      item.fifo_empty      = vif.fifo_empty;
      item.fifo_full       = vif.fifo_full;
      item.npu_d_out       = vif.npu_d_out;
      item.mac0_out_debug  = vif.mac0_out_debug;
      item.mac1_out_debug  = vif.mac1_out_debug;
      item.relu0_out_debug = vif.relu0_out_debug;
      item.relu1_out_debug = vif.relu1_out_debug;
      status_port.write(item);
    end
  endtask

endclass : npu_monitor

`endif



