//-------------------------------------------------------------------------------------------------
//
//                             UART2BUS VERIFICATION
//
//-------------------------------------------------------------------------------------------------
// CREATOR    : HANY SALAH
// PROJECT    : UART2BUS UVM TEST BENCH
// UNIT       : TOP MODULE
//-------------------------------------------------------------------------------------------------
// TITLE      : UART Package 
// DESCRIPTION: THIS PACKAGE IMPORTS THE ALL SUBPACKAGES AND WHOLE TESTS 
//-------------------------------------------------------------------------------------------------
// LOG DETAILS
//-------------
// VERSION      NAME        DATE        DESCRIPTION
//    1       HANY SALAH    11012016    FILE CREATION
//    2       HANY SALAH    13022016    MODIFY BLOCK DESCRIPTION & ADD COMMENTS
//-------------------------------------------------------------------------------------------------
// ALL COPYRIGHTS ARE RESERVED FOR THE PRODUCER ONLY .THIS FILE IS PRODUCED FOR OPENCORES MEMBERS 
// ONLY AND IT IS PROHIBTED TO USE THIS MATERIAL WITHOUT THE CREATOR'S PERMISSION
//-------------------------------------------------------------------------------------------------
package uart_pkg;

  import uvm_pkg::*;
  import agent_pkg::*;
  import env_pkg::*;


  `include "uvm_macros.svh"

  `include "uart_test.svh"

    
endpackage:uart_pkg