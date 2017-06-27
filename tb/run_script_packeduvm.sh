rm -rf work
rm -rf *.log
rm -rf transcript
rm -rf vsim.wlf
rm -rf vsim_stacktrace.vstf
vlib work
#------------------------------
# BFMs Compiling
#------------------------------
vlog  uvm-1.2/src/uvm.sv +incdir+uvm_src/
#------------------------------
# BFMs Compiling
#------------------------------
vlog -novopt interfaces/uart_interface.sv +incdir+../
vlog -novopt interfaces/rf_interface.sv +incdir+../
vlog -novopt interfaces/uart_arbiter.sv +incdir+../
#-----------------------------
# Agent Compiling
#------------------------------
vlog -novopt agent/agent_pkg.sv +incdir+agent +incdir+agent/driver  +incdir+./ +incdir+agent/configuration +incdir+agent/sequence +incdir+agent/transaction +incdir+agent/monitor +incdir+agent/coverage +incdir+uvm_src/ +define+UVM_1p2
#-----------------------------
# Environment & Scoreboard Compiling
#------------------------------
vlog -novopt env/env_pkg.sv +incdir+env +incdir+analysis +incdir+uvm_src/ +define+UVM_1p2
#-----------------------------
# UART TEST Compiling
#------------------------------
vlog -novopt uart_pkg.sv +incdir+test/ +incdir+agent/ +incdir+env/ +incdir+./ +incdir+../ +incdir+uvm_src/ +define+UVM_1p2
#-----------------------------
# UART DUT Compiling
#------------------------------
vlog ../rtl/uart_tx.v +incdir+../rtl
vlog ../rtl/uart_rx.v +incdir+../rtl
vlog ../rtl/baud_gen.v +incdir+../rtl
vlog ../rtl/uart_top.v +incdir+../rtl
vlog ../rtl/uart_parser.v +incdir+../rtl
vlog ../rtl/uart2bus_top.v +incdir+../rtl
#-----------------------------
# UART Top Testbench Compiling
#------------------------------
vlog -novopt uart_top.sv +incdir+../../rtl/i2c/ +incdir+./ +incdir+../rtl +incdir+uvm_src/ +define+UVM_1p2
#-----------------------------
# UART Top Testbench Simulation
#------------------------------
vsim -novopt +coverage -c uart_top_tb -sv_lib $UVM_HOME/lib/uvm_dpi64
#run -all
