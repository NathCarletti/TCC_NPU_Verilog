`ifndef FREE_SPOT_SEQUENCE_SV
`define FREE_SPOT_SEQUENCE_SV


class free_spot_sequence extends uvm_sequence#(axi_transaction);

  `uvm_object_utils(free_spot_sequence)

  function new(string name = "free_spot_sequence");
    super.new(name);
  endfunction

  task body();
    bit [31:0] status_word;
    parking_result pr;
    write_sequence wr;
    read_sequence rd;
    axi_sequencer axi_seq;
    time start_time;
    time end_time;

    wr = write_sequence::type_id::create("wr_da", null);
    wr.addr = 32'h0000;
    wr.data = 32'd200;
    wr.start(m_sequencer);

    wr = write_sequence::type_id::create("wr_db", null);
    wr.addr = 32'h0004;
    wr.data = 32'd2;
    wr.start(m_sequencer);

    wr = write_sequence::type_id::create("wr_dc", null);
    wr.addr = 32'h0008;
    wr.data = 32'd30;
    wr.start(m_sequencer);

    wr = write_sequence::type_id::create("wr_dd", null);
    wr.addr = 32'h000C;
    wr.data = 32'd120;
    wr.start(m_sequencer);

    wr = write_sequence::type_id::create("wr_start", null);
    wr.addr = 32'h0010;
    wr.data = 32'd1;
    wr.start(m_sequencer);
    start_time = $time;

    forever begin
      rd = read_sequence::type_id::create("rd_status", null);
      rd.addr = 32'h0014;
      rd.start(m_sequencer);
      status_word = rd.read_data;
      if (status_word[1]) begin
        break;
      end
      #10;
    end

    end_time = $time;

    rd = read_sequence::type_id::create("rd_result", null);
    rd.addr = 32'h0018;
    rd.start(m_sequencer);

    pr.scenario = "free_spot";
    pr.expected_class = FREE;
    pr.actual_class = parking_class_e'(rd.read_data[1:0]);
    pr.latency = end_time - start_time;
    pr.done_seen = 1;
    axi_seq = axi_sequencer'(m_sequencer);
    axi_seq.result_port.write(pr);
  endtask

endclass : free_spot_sequence

`endif


