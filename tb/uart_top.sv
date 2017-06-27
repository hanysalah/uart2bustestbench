//-------------------------------------------------------------------------------------------------
//
//                                     UART2BUS VERIFICATION
//
//-------------------------------------------------------------------------------------------------
// CREATOR    : HANY SALAH
// PROJECT    : UART2BUS UVM TEST BENCH
// UNIT       : TOP MODULE
//-------------------------------------------------------------------------------------------------
// TITLE      : UART TOP 
// DESCRIPTION: THIS TOP MODULE THAT INHERITS THE ALL TESTBENCH COMPONENT AND CONNECT THEM TO DUT.
//              ALSO INCLUDES THE CLOCK GENERATION MECHANISM.
//-------------------------------------------------------------------------------------------------
// LOG DETAILS
//-------------
// VERSION      NAME        DATE        DESCRIPTION
//    1       HANY SALAH    11012016    FILE CREATION
//    2       HANY SALAH    18022016    IMPROVE BLOCK DESCRIPTION & ADD COMMENTS
//-------------------------------------------------------------------------------------------------
// ALL COPYRIGHTS ARE RESERVED FOR THE PRODUCER ONLY .THIS FILE IS PRODUCED FOR OPENCORES MEMBERS 
// ONLY AND IT IS PROHIBTED TO USE THIS MATERIAL WITHOUT THE CREATOR'S PERMISSION
//-------------------------------------------------------------------------------------------------
  `include "defin_lib.svh"
  `include "uart2bus_top.v"

module uart_top_tb;

  import uvm_pkg::*;
  import uart_pkg::*;
  
  `include "uvm_macros.svh"
  
  // Global System clock
  logic clk_glob;
  
  // UART clock (1/Baud Rate)
  logic clk_uart;

  // Glocal Asynchronous reset
  logic reset;

  assign rf_inf.int_req = arb_inf.int_req;
  assign rf_inf.int_gnt = arb_inf.int_gnt;

  // Initiate UART BFM
  uart_interface  uart_inf (.reset(reset),
                            .clock(clk_uart));

  // Initiate Register File BFM
  rf_interface    rf_inf (.reset(reset),
                          .clock(clk_glob));

  // Initiate Arbiter BFM
  uart_arbiter    arb_inf (.reset (reset),
                           .clock(clk_glob));

  // Initiate Design Under Test DUT
  uart2bus_top      dut(  .clock(clk_glob),
                          .reset(reset),
                          .ser_in(uart_inf.ser_out),
                          .ser_out(uart_inf.ser_in),
                          .int_address(rf_inf.int_address),
                          .int_wr_data(rf_inf.int_wr_data),
                          .int_write(rf_inf.int_write),
                          .int_rd_data(rf_inf.int_rd_data),
                          .int_read(rf_inf.int_read),
                          .int_req(arb_inf.int_req),
                          //.int_gnt(arb_inf.int_gnt));
                          .int_gnt(1'b1));
  


  initial
    begin
    reset = 1'b1;
    clk_glob = 1'b0;
    clk_uart = 1'b0;
    #100;
    reset = 1'b0;
    end

  // Clock Signals Generator
  initial
    begin
    fork
      forever
        begin
        #(`glob_clk_period/2) clk_glob = ~clk_glob;
        #((`glob_clk_period/2)+1) clk_glob = ~clk_glob;
        end
      forever
        begin
        #(`buad_clk_period/2) clk_uart = ~clk_uart;
        #((`buad_clk_period/2)+1) clk_uart = ~clk_uart;
        end
    join
    end


  initial
    begin
    uvm_config_db#(virtual uart_interface)::set(uvm_root::get(), "*", "uart_inf",uart_inf); 

    uvm_config_db#(virtual rf_interface)::set(uvm_root::get(), "*", "rf_inf",rf_inf); 

    uvm_config_db#(virtual uart_arbiter)::set(uvm_root::get(),"*","arb_inf",arb_inf);
    run_test("cover_driven_test"); 
       
    end
    
endmodule:uart_top_tb
