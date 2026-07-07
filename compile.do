transcript on

vdel -lib work -all
vlib work

set UVM_HOME D:/Questa_install/questa_fse/verilog_src/uvm-1.2/src

vlog -sv -work work \
+incdir+$UVM_HOME \
$UVM_HOME/uvm_pkg.sv \
+incdir+tb \
tb/parking_uvm_pkg.sv \
tb/interfaces/axi_if.sv \
tb/interfaces/npu_if.sv \
rtl/*.v \
tb/top_tb.sv

vsim -novopt work.top_tb +UVM_TESTNAME=free_spot_test


