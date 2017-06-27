//-------------------------------------------------------------------------------------------------
//
//                             UART2BUS VERIFICATION
//
//-------------------------------------------------------------------------------------------------
// CREATOR    : HANY SALAH
// PROJECT    : UART2BUS UVM TEST BENCH
// UNIT       : INTERFACE
//-------------------------------------------------------------------------------------------------
// TITLE      : UART Arbiter 
// DESCRIPTION: THIS BFM ACT AS ARBITER CONNECTED TO THE DUT. ITS DUTY IS ONLY TO GIVE THE DUT THE
//              BUS GRANT OR NOT. 
//-------------------------------------------------------------------------------------------------
// LOG DETAILS
//-------------
// VERSION      NAME        DATE        DESCRIPTION
//    1       HANY SALAH    29122015    FILE CREATION
//    2       HANY SALAH    12022016    ENHANCE BLOCK DESCRIPTION & ADD COMMENTS
//-------------------------------------------------------------------------------------------------
// ALL COPYRIGHTS ARE RESERVED FOR THE PRODUCER ONLY .THIS FILE IS PRODUCED FOR OPENCORES MEMBERS 
// ONLY AND IT IS PROHIBTED TO USE THIS MATERIAL WITHOUT THE CREATOR'S PERMISSION
//-------------------------------------------------------------------------------------------------
interface uart_arbiter (input bit clock,
						            input bit reset);

//-------------------------------------------------------------------------------------------------
//
//                                Bus Control Signals
//
//-------------------------------------------------------------------------------------------------

  logic               int_req;        // Request Internal Bus Access
  logic               int_gnt;        // Grant Internal Bus Access

//-------------------------------------------------------------------------------------------------
//
//                                Arbiter Control Signals
//  
//-------------------------------------------------------------------------------------------------

  // When this routine is called, it wait the request signal activation to give the bus grant to
  // the DUT.
  task accept_req ();
    wait (int_req);
    int_gnt = 1'b1;
  endtask:accept_req

  // When this routine is called, it wait the request signal activation and then declain the 
  // the request buy set int_gnt to zero.
  task declain_req ();
    wait (int_req);
    int_gnt = 1'b0;
  endtask:declain_req

endinterface:uart_arbiter