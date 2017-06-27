# uart2bustestbench
UVM Verification IP to uart2bus IP. 
This UVM testbench is presented to functionally verify UART2BUS RTL released by Moti Litochevski in opencores.org. It is an illustrative example of how to build a complex UVM environment and supports more facilities in reporting and debugging. So if you are a beginner in the field of VLSI functional verification, it might help you well to go through the UVM latest methodology.
- There is a verification document that includes the all verification aspects with a good documentation.
- There is different example of simulation methodologies like coverage-driven/simulation-based.
- THE DIRECTORY "uvm_1.2" INCLUDES THE LATEST UVM SOURCE CODE.
- THERE ARE TWO SCRIPTS TO RUN.
  - THE FIRST SCRIPT NAMED "run_script.sh" TO RUN USING THE BUILT-IN UVM SOURCE CODE IN YOUR SIMULATION TOOL.
  - THE SECOND SCRIPT NAMED "run_script_packeduvm.sh" TO RUN USING THE UVM SOURCE CODE IN THE DIRECTORY "uvm_1.2". DON'T USE IT UNLESS YOU HAVE ALREADY COMPILED THE DPI BEFORE
