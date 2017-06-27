//-------------------------------------------------------------------------------------------------
//
//                                   UART2BUS VERIFICATION
//
//-------------------------------------------------------------------------------------------------// CREATOR    : HANY SALAH
// PROJECT    : UART2BUS UVM TEST BENCH
// UNIT       : AGENT
//-------------------------------------------------------------------------------------------------// TITLE      : UART Configuration
// DESCRIPTION: UART Configuration INCLUDES INSTANCE OF THE THREE BFMS. ALSO INCLUDES THE WHOLE EN-
//              VIRONMENT CONFIGURATIONS THAT ARE SET IN THE TEST. 
//-------------------------------------------------------------------------------------------------// LOG DETAILS
//-------------
// VERSION      NAME        DATE        DESCRIPTION
//    1       HANY SALAH    02012016    FILE CREATION
//    2       HANY SALAH    09022016    REFINE THE BLOCK DESCRIPTION AND ADD DESCRIPTIVE COMMENTS
//-------------------------------------------------------------------------------------------------// ALL COPYRIGHTS ARE RESERVED FOR THE PRODUCER ONLY .THIS FILE IS PRODUCED FOR OPENCORES MEMBERS 
// ONLY AND IT IS PROHIBTED TO USE THIS MATERIAL WITHOUT THE CREATOR'S PERMISSION
//-------------------------------------------------------------------------------------------------

class uart_config extends uvm_object;
  
  // Uart BFM Instance
  virtual uart_interface    uart_inf;

  // Register File BFM Instance
  virtual rf_interface      rf_inf;

  // Arbiter BFM Instance
  virtual uart_arbiter      arb_inf;

  // Active clock edge that would syncronize the whole system to be either the positive or the neg-
  // tive edge
  act_edge      _edge;

  // Define the sequence to be used in transmitting one byte serially; either to start with the MSB
  // or the LSB.
  start_bit     _start;

  // Define the Represenetation of data through the text mode to be either ASCII or Binary
  data_mode			_datamode;

  // Define the number of stop bits at the final of each UART field to be one of two bits
  int 					num_stop_bits;

  // Define the number of bits inbetween the start and the stop bits to be seven or eight bits
  int 					num_of_bits;

  // Define the parity mode used to be either no parity, odd parity or even parity.
  parity_mode		_paritymode;

  // Define the maximum time between the generated stimulus and the DUT response.
  time          response_time;

  // Define the possibility of generating false data through the read command. This attribute is
  // general control one that would be make this feature would be used or not. And another field
  // would be generated through the sequence.
  req           use_false_data;

  `uvm_object_utils(uart_config)

  function new (string name = "uart_config");
    super.new(name);
  endfunction:new
endclass:uart_config