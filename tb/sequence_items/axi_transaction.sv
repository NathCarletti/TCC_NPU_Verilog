`ifndef AXI_TRANSACTION_SV
`define AXI_TRANSACTION_SV


class axi_transaction extends uvm_sequence_item;

  `uvm_object_utils(axi_transaction)

   bit [31:0] addr;
   bit [31:0] data;
   bit [3:0]  wstrb;
  bit             read;
  bit [31:0]      read_data;
  axi_op_e        op;

  function new(string name = "axi_transaction", uvm_component parent = null);
    super.new(name);
    wstrb = 4'hF;
    read   = 0;
    op     = AXI_WRITE;
  endfunction

  function void do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_field_int("addr", addr, $bits(addr), UVM_HEX);
    printer.print_field_int("data", data, $bits(data), UVM_HEX);
    printer.print_field_int("wstrb", wstrb, $bits(wstrb), UVM_HEX);
    printer.print_field_int("read", read, $bits(read), UVM_BIN);
    printer.print_field_int("read_data", read_data, $bits(read_data), UVM_HEX);
    printer.print_field_int("op", op, $bits(op), UVM_BIN);
  endfunction

endclass : axi_transaction

`endif



