`ifndef WRITE_SEQUENCE_SV
`define WRITE_SEQUENCE_SV

class write_sequence extends uvm_sequence#(axi_transaction);

  `uvm_object_utils(write_sequence)

  bit [31:0] addr;
  bit [31:0] data;
  bit [3:0]  wstrb;

  function new(string name = "write_sequence");
    super.new(name);
    wstrb = 4'hF;
  endfunction

  task body();
    axi_transaction tr;
    tr = axi_transaction::type_id::create("tr", null);
    tr.addr  = addr;
    tr.data  = data;
    tr.wstrb = wstrb;
    tr.read  = 0;
    tr.op    = AXI_WRITE;

    start_item(tr);
    finish_item(tr);
  endtask

endclass : write_sequence

`endif


