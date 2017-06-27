//-------------------------------------------------------------------------------------------------
//
//                             UART2BUS VERIFICATION
//
//-------------------------------------------------------------------------------------------------
// CREATOR    : HANY SALAH
// PROJECT    : UART2BUS UVM TEST BENCH
// UNIT       : ENVIRONEMNT
//-------------------------------------------------------------------------------------------------
// TITLE      : UART ENVIRONMENT PACKAGE 
// DESCRIPTION: THIS PACKAGE INCLUDE  
//-------------------------------------------------------------------------------------------------
// LOG DETAILS
//-------------
// VERSION      NAME        DATE        DESCRIPTION
//    1       HANY SALAH    10012016    FILE CREATION
//    2       HANY SALAH    24012016    ADD UART SCOREBOARD
//    3       HANY SALAH    11022016    IMPROVE BLOCK DESCRIPTION & ADD COMMENTS 
//-------------------------------------------------------------------------------------------------
// ALL COPYRIGHTS ARE RESERVED FOR THE PRODUCER ONLY .THIS FILE IS PRODUCED FOR OPENCORES MEMBERS 
// ONLY AND IT IS PROHIBTED TO USE THIS MATERIAL WITHOUT THE CREATOR'S PERMISSION
//-------------------------------------------------------------------------------------------------

package env_pkg;

  import agent_pkg::*;
  import uvm_pkg::*;

  `include "uvm_macros.svh"


  `include "uart_scoreboard.svh"
  `include "uart_env.svh"

endpackage:env_pkg