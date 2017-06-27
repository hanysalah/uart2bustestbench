//-------------------------------------------------------------------------------------------------
//
//                             UART2BUS VERIFICATION
//
//-------------------------------------------------------------------------------------------------
// CREATOR    : HANY SALAH
// PROJECT    : UART2BUS UVM TEST BENCH
// UNIT       : AGENT
//-------------------------------------------------------------------------------------------------
// TITLE      : UART AGENT PACKAGE 
// DESCRIPTION: THIS PACKAGE INCLUDES ALL AGENT BLOCKS AND ALSO DEFINITIONS LI-
//              BRARY.
//-------------------------------------------------------------------------------------------------
// LOG DETAILS
//-------------
// VERSION      NAME        DATE        DESCRIPTION
//    1       HANY SALAH    10012016    FILE CREATION
//    2       HANY SALAH    11022016    IMPROVE BLOCK DESCRIPTION
//-------------------------------------------------------------------------------------------------
// ALL COPYRIGHTS ARE RESERVED FOR THE PRODUCER ONLY .THIS FILE IS PRODUCED FOR OPENCORES MEMBERS 
// ONLY AND IT IS PROHIBTED TO USE THIS MATERIAL WITHOUT THE CREATOR'S PERMISSION
//-------------------------------------------------------------------------------------------------

package agent_pkg;
  
  `include "defin_lib.svh"

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "uart_transaction.svh"
  `include "uart_sequence.svh"
  `include "uart_config.svh"
  `include "uart_driver.svh"
  `include "uart_monitor.svh"
  `include "uart_coverage.svh"

  `include "uart_agent.svh"

endpackage:agent_pkg