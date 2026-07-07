`ifndef AXI_MONITOR_SV
`define AXI_MONITOR_SV


class axi_monitor extends uvm_component;

  `uvm_component_utils(axi_monitor)

  virtual axi_if vif;
  uvm_analysis_port#(axi_transaction) item_collected_port;

  function new(string name = "axi_monitor", uvm_component parent = null);
  super.new(name, parent);
  item_collected_port = new("item_collected_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal(get_full_name(), "Virtual AXI interface not set for monitor")
    end
  endfunction

  task run_phase(uvm_phase phase);
    axi_transaction tr;
    forever begin
      @(posedge vif.clk);
      if (vif.awvalid && vif.awready) begin
        tr = axi_transaction::type_id::create("write_tr", this);
        tr.addr = vif.awaddr;
        tr.data = vif.wdata;
        tr.wstrb = vif.wstrb;
        tr.read = 0;
        tr.op = AXI_WRITE;
        item_collected_port.write(tr);
      end
      if (vif.arvalid && vif.arready) begin
        tr = axi_transaction::type_id::create("read_tr", this);
        tr.addr = vif.araddr;
        tr.read = 1;
        tr.op = AXI_READ;
        item_collected_port.write(tr);
      end
      if (vif.rvalid && vif.rready) begin
        tr = axi_transaction::type_id::create("read_rsp", this);
        tr.read = 1;
        tr.read_data = vif.rdata;
        tr.op = AXI_READ;
        item_collected_port.write(tr);
      end
    end
  endtask

endclass : axi_monitor

`endif



