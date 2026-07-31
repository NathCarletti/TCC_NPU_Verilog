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
    bit prev_valid;
    bit prev_piso_en_piso_out;
    bit prev_piso_shift_out;
    bit prev_piso_clr_piso_out;
    bit [31:0] prev_shift_reg;
    bit [7:0] prev_piso_internal_d_out;
    bit [7:0] prev_piso_dout;
    bit [7:0] prev_fifo_data_in;
    bit prev_fifo_wr_en;
    bit prev_fifo_rd_en;
    bit [7:0] prev_fifo_data_out;
    bit [7:0] prev_wr_ptr;
    bit [7:0] prev_rd_ptr;
    bit [7:0] prev_count;
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
      item.piso_en_piso_out    = vif.piso_en_piso_out;
      item.piso_shift_out      = vif.piso_shift_out;
      item.piso_clr_piso_out   = vif.piso_clr_piso_out;
      item.shift_reg       = vif.shift_reg;
      item.piso_internal_d_out = vif.piso_internal_d_out;
      item.piso_dout       = vif.piso_dout;
      item.fifo_data_in    = vif.fifo_data_in;
      item.fifo_wr_en      = vif.fifo_wr_en;
      item.fifo_rd_en      = vif.fifo_rd_en;
      item.fifo_data_out   = vif.fifo_data_out;
      item.wr_ptr          = vif.wr_ptr;
      item.rd_ptr          = vif.rd_ptr;
      item.count           = vif.count;
      if (!prev_valid ||
          vif.piso_en_piso_out != prev_piso_en_piso_out ||
          vif.piso_shift_out != prev_piso_shift_out ||
          vif.piso_clr_piso_out != prev_piso_clr_piso_out ||
          vif.shift_reg != prev_shift_reg ||
          vif.piso_internal_d_out != prev_piso_internal_d_out ||
          vif.piso_dout != prev_piso_dout ||
          vif.fifo_data_in != prev_fifo_data_in ||
          vif.fifo_wr_en != prev_fifo_wr_en ||
          vif.fifo_rd_en != prev_fifo_rd_en ||
          vif.fifo_data_out != prev_fifo_data_out ||
          vif.wr_ptr != prev_wr_ptr ||
          vif.rd_ptr != prev_rd_ptr ||
          vif.count != prev_count) begin
        `uvm_info("NPU_OUT_PATH",
          $sformatf("EN_PISO_OUT=%0b SHIFT_OUT=%0b CLR_PISO_OUT=%0b shift_reg=%08h piso_D_OUT=%02h PISO_DOUT=%02h fifo_data_in=%02h fifo_wr_en=%0b fifo_rd_en=%0b fifo_data_out=%02h wr_ptr=%0d rd_ptr=%0d count=%0d",
                    vif.piso_en_piso_out,
                    vif.piso_shift_out,
                    vif.piso_clr_piso_out,
                    vif.shift_reg,
                    vif.piso_internal_d_out,
                    vif.piso_dout,
                    vif.fifo_data_in,
                    vif.fifo_wr_en,
                    vif.fifo_rd_en,
                    vif.fifo_data_out,
                    vif.wr_ptr,
                    vif.rd_ptr,
                    vif.count),
          UVM_LOW)
      end
      prev_valid         = 1'b1;
      prev_piso_en_piso_out    = vif.piso_en_piso_out;
      prev_piso_shift_out      = vif.piso_shift_out;
      prev_piso_clr_piso_out   = vif.piso_clr_piso_out;
      prev_shift_reg     = vif.shift_reg;
      prev_piso_internal_d_out = vif.piso_internal_d_out;
      prev_piso_dout     = vif.piso_dout;
      prev_fifo_data_in  = vif.fifo_data_in;
      prev_fifo_wr_en    = vif.fifo_wr_en;
      prev_fifo_rd_en    = vif.fifo_rd_en;
      prev_fifo_data_out = vif.fifo_data_out;
      prev_wr_ptr        = vif.wr_ptr;
      prev_rd_ptr        = vif.rd_ptr;
      prev_count         = vif.count;
      status_port.write(item);
    end
  endtask

endclass : npu_monitor

`endif
