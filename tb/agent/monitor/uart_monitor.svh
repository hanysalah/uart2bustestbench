//-----------------------------------------------------------------------------
//
//                             UART2BUS VERIFICATION
//
//-----------------------------------------------------------------------------
// CREATOR    : HANY SALAH
// PROJECT    : UART2BUS UVM TEST BENCH
// UNIT       : MONITOR
//-----------------------------------------------------------------------------
// TITLE      : UART Monitor 
// DESCRIPTION: This 
//-----------------------------------------------------------------------------
// LOG DETAILS
//-------------
// VERSION      NAME        DATE        DESCRIPTION
//    1       HANY SALAH    12012016    FILE CREATION
//    2       HANY SALAH    31012016    ADD INVALID WRITE CASE TO TRANSACTION 
//                                      PACKETAIZATION METHOD
//-----------------------------------------------------------------------------
// ALL COPYRIGHTS ARE RESERVED FOR THE PRODUCER ONLY .THIS FILE IS PRODUCED FOR
// OPENCORES MEMBERS ONLY AND IT IS PROHIBTED TO USE THIS MATERIAL WITHOUT THE 
// CREATOR'S PERMISSION
//-----------------------------------------------------------------------------
class uart_monitor extends uvm_monitor;
  
  uart_transaction  trans;

  uart_config       _config;

  virtual uart_interface    uart_inf;

  virtual rf_interface      rf_inf;

  uvm_analysis_port #(uart_transaction) mon_scbd;

  `uvm_component_utils(uart_monitor)

  function new (string name, uvm_component parent);
    super.new(name,parent);
  endfunction:new

  function void display_content ();
    `uvm_info("TRACE","Printing the transaction content:",UVM_HIGH);
     trans.print();
  endfunction:display_content

  extern function void build_phase (uvm_phase phase);

  extern function void connect_phase (uvm_phase phase);

  extern function void end_of_elaboration_phase (uvm_phase phase);

  extern task run_phase (uvm_phase phase);

endclass:uart_monitor

function void uart_monitor::build_phase (uvm_phase phase);
  super.build_phase(phase);
  
  _config = uart_config::type_id::create("_config",this);

  trans = uart_transaction::type_id::create("trans");

  mon_scbd = new ("mon_scbd",this);
endfunction:build_phase

function void uart_monitor::connect_phase (uvm_phase phase);

endfunction:connect_phase

function void uart_monitor::end_of_elaboration_phase(uvm_phase phase);
  if (!uvm_config_db#(uart_config)::get(this,"","UART_CONFIGURATION",_config))
    `uvm_fatal("NOCONFIGURATION",{"configuration instance must be set for",get_full_name(),"._config"})

  if (!uvm_config_db#(virtual uart_interface)::get(this,"","uart_inf",_config.uart_inf))
    `uvm_fatal("NOINF",{"UART Interface instance must be set for",get_full_name,".uart_inf"})  
  uart_inf = _config.uart_inf;

  if(!uvm_config_db#(virtual rf_interface)::get(this,"","rf_inf",_config.rf_inf))
    `uvm_fatal("NOINF",{"RF Interface instance must be set for",get_full_name(),".rf_inf"})
  rf_inf = _config.rf_inf;

endfunction:end_of_elaboration_phase

task uart_monitor::run_phase (uvm_phase phase);
  int iteration;
  int command_type;
  int _command;
  int _chartype;
  int _spacetype1;
  int _spacetype2;
  int _eoltype;
  int _reqack;
  int _reqinc;
  byte data_temp[$];

  iteration = 0;
  forever
    begin
    iteration++;
    uart_inf.wait_event();
    trans.acknowledge=8'b00;

    uart_inf.capture_command(command_type,
                             _command,
                             _chartype,
                             _spacetype1,
                             trans.space_wrong1,
                             _spacetype2,
                             trans.space_wrong2,
                             _eoltype,
                             trans.eol_wrong,
                             trans.address,
                             trans._data,
                             trans.acknowledge,
                             trans.length_data,
                             _reqack,
                             _reqinc);
    trans._mode        = mode'(command_type);
    trans._command     = command'(_command);
    trans._chartype    = char_type'(_chartype);
    trans._spacetype1  = space_type'(_spacetype1);
    trans._spacetype2  = space_type'(_spacetype2); 
    trans._eoltype     = eol_type '(_eoltype);
    trans._reqinc      = req '(_reqinc);
    trans._reqack      = req '(_reqack);
    if (trans._command == write || trans._command == invalid_write)
      begin
      if (trans._mode == text || trans._mode == wrong_mode_text)
        begin
        trans._data[0] = rf_inf.read_mem_data(trans.address);
        end
      else if (trans._mode == binary || trans._mode == wrong_mode_bin)
        begin
        rf_inf.read_block(trans.length_data,
                          trans.address,
                          trans._data);
        end
      end
    //display_content();
    trans._id = iteration;
    mon_scbd.write(trans);
   end
   
endtask:run_phase
