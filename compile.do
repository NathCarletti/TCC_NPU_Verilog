transcript on

vdel -lib work -all
vlib work

# UVM
set UVM_HOME D:/Questa_install/questa_fse/verilog_src/uvm-1.2/src
set UVM_DPI  D:/Questa_install/questa_fse/uvm-1.2/win64/uvm_dpi

# Compilação
vlog -sv -work work \
+incdir+$UVM_HOME \
$UVM_HOME/uvm_pkg.sv \
+incdir+tb \
tb/parking_uvm_pkg.sv \
tb/interfaces/axi_if.sv \
tb/interfaces/npu_if.sv \
rtl/*.v \
tb/top_tb.sv

# Simulação
if {![info exists TESTNAME]} {
    set TESTNAME free_spot_test
}

vsim \
-sv_lib $UVM_DPI \
work.top_tb \
+UVM_TESTNAME=$TESTNAME
