`ifndef READ_SEQUENCE_SV
`define READ_SEQUENCE_SV

class read_sequence extends uvm_sequence#(axi_transaction);

  `uvm_object_utils(read_sequence)

  bit [31:0] addr;
  bit [31:0] read_data;

  function new(string name = "read_sequence");
    super.new(name);
  endfunction

  task body();
    axi_transaction tr;
    tr = axi_transaction::type_id::create("tr", null);
    tr.addr = addr;
    tr.read = 1;
    tr.op = AXI_READ;

    start_item(tr);
    finish_item(tr);
    read_data = tr.read_data;
  endtask

endclass : read_sequence

`endif


