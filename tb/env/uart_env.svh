//-------------------------------------------------------------------------------------------------
//
//                             UART2BUS VERIFICATION
//
//-------------------------------------------------------------------------------------------------
// CREATOR    : HANY SALAH
// PROJECT    : UART2BUS UVM TEST BENCH
// UNIT       : AGENT
//-------------------------------------------------------------------------------------------------
// TITLE      : UART ENVIRONMENT 
// DESCRIPTION: THIS BLOCK INCLUDES THE TESTBENCH AGENTS AND SCOREBOARD 
//-------------------------------------------------------------------------------------------------
// LOG DETAILS
//-------------
// VERSION      NAME        DATE        DESCRIPTION
//    1       HANY SALAH    10012016    FILE CREATION
//    2       HANY SALAH    11022016    IMPROVE BLOCK DESCRIPTION & ADD COMMENTS
//-------------------------------------------------------------------------------------------------
// ALL COPYRIGHTS ARE RESERVED FOR THE PRODUCER ONLY .THIS FILE IS PRODUCED FOR OPENCORES MEMBERS 
// ONLY AND IT IS PROHIBTED TO USE THIS MATERIAL WITHOUT THE CREATOR'S PERMISSION
//-------------------------------------------------------------------------------------------------
class uart_env extends uvm_env;
  
  uart_agent          agent;

  uart_scoreboard     scbd;

  `uvm_component_utils(uart_env)

  function new (string name,uvm_component parent);
    super.new(name,parent);
  endfunction:new

  extern function void build_phase (uvm_phase phase);

  extern function void connect_phase (uvm_phase phase);
endclass:uart_env

function void uart_env::build_phase (uvm_phase phase);
  super.build_phase(phase);
  agent = uart_agent::type_id::create("agent",this);
  scbd  = uart_scoreboard::type_id::create("uart_scoreboard",this);

endfunction:build_phase

function void uart_env::connect_phase (uvm_phase phase);
  super.connect_phase(phase);

  agent.drv_port.connect(scbd.scbd_drv);
  agent.mon_port.connect(scbd.scbd_mon);
  
endfunction:connect_phase