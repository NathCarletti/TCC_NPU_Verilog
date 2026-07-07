`ifndef AXI_DRIVER_SV
`define AXI_DRIVER_SV

class axi_driver extends uvm_driver#(axi_transaction);

  `uvm_component_utils(axi_driver)

  virtual axi_if vif;

  function new(string name = "axi_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal(get_full_name(), "Virtual AXI interface not set")
    end
  endfunction

  task run_phase(uvm_phase phase);
    axi_transaction tr;
    forever begin
      seq_item_port.get_next_item(tr);
      if (tr.read) begin
        perform_read(tr);
      end else begin
        perform_write(tr);
      end
      seq_item_port.item_done();
    end
  endtask

  task perform_write(ref axi_transaction tr);
    vif.awaddr  <= tr.addr;
    vif.awvalid <= 1'b1;
    vif.wdata   <= tr.data;
    vif.wstrb   <= tr.wstrb;
    vif.wvalid  <= 1'b1;
    vif.bready  <= 1'b1;

    wait (vif.awready && vif.wready);
    @(posedge vif.clk);

    vif.awvalid <= 1'b0;
    vif.wvalid  <= 1'b0;

    wait (vif.bvalid);
    @(posedge vif.clk);

    vif.bready <= 1'b0;
    tr.read_data = 32'h0000;
  endtask

  task perform_read(ref axi_transaction tr);
    vif.araddr  <= tr.addr;
    vif.arvalid <= 1'b1;
    vif.rready  <= 1'b1;

    wait (vif.arready);
    @(posedge vif.clk);

    vif.arvalid <= 1'b0;

    wait (vif.rvalid);
    @(posedge vif.clk);

    tr.read_data = vif.rdata;
    vif.rready  <= 1'b0;
  endtask

endclass : axi_driver

`endif



