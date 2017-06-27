//-------------------------------------------------------------------------------------------------
//
//                             UART2BUS VERIFICATION
//
//-------------------------------------------------------------------------------------------------
// CREATOR    : HANY SALAH
// PROJECT    : UART2BUS UVM TEST BENCH
// UNIT       : AGENT
//-------------------------------------------------------------------------------------------------
// TITLE      : UART AGENT 
// DESCRIPTION: This 
//-------------------------------------------------------------------------------------------------
// LOG DETAILS
//-------------
// VERSION      NAME        DATE        DESCRIPTION
//    1       HANY SALAH    10012016    FILE CREATION
//    2       HANY SALAH    09022016    ADD COVERAGE BLOCK
//    3       HANY SALAH    11022016    IMPROVE BLOCK DESCRIPTION & ADD COMMENTS
//-------------------------------------------------------------------------------------------------
// ALL COPYRIGHTS ARE RESERVED FOR THE PRODUCER ONLY .THIS FILE IS PRODUCED FOR OPENCORES MEMBERS 
// ONLY AND IT IS PROHIBTED TO USE THIS MATERIAL WITHOUT THE CREATOR'S PERMISSION
//-------------------------------------------------------------------------------------------------

class uart_agent extends uvm_agent;

  // UART Driver
  uart_driver           _drv;

  // UART Sequencer
  uvm_sequencer#(uart_transaction) _seq;

  // UART Monitor
  uart_monitor          _mon;

  // UART Coverage block
  uart_coverage         _cov;

  // TLM analysis port that is linked to driver tlm analysis port.
  uvm_analysis_port #(uart_transaction) drv_port;

  // TLM analysis port that is linked to monitor tlm analysis port.
  uvm_analysis_port #(uart_transaction) mon_port;
  
  `uvm_component_utils(uart_agent)

  function new (string name,uvm_component parent);
    super.new(name,parent);
  endfunction:new


  extern function void build_phase (uvm_phase phase);

  extern function void connect_phase (uvm_phase phase);
endclass:uart_agent

function void uart_agent::build_phase (uvm_phase phase);
  super.build_phase(phase);
  _drv = uart_driver::type_id::create("_drv",this);
  _seq = uvm_sequencer#(uart_transaction)::type_id::create("_seq",this);
  _mon = uart_monitor::type_id::create("_mon",this);
  _cov = uart_coverage::type_id::create("_cov",this);

  drv_port = new ("drv_port",this);
  mon_port = new ("mon_port",this);
endfunction:build_phase

function void uart_agent::connect_phase (uvm_phase phase);
  super.connect_phase(phase);
  _drv.seq_item_port.connect(_seq.seq_item_export);

  _drv.drv_scbd_cov.connect(drv_port);

  _mon.mon_scbd.connect(mon_port);
  _mon.mon_scbd.connect(_cov.analysis_export);
endfunction:connect_phase
