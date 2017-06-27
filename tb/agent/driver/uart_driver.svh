//-------------------------------------------------------------------------------------------------
//
//                                     UART2BUS VERIFICATION
//
//-------------------------------------------------------------------------------------------------
// CREATOR    : HANY SALAH
// PROJECT    : UART2BUS UVM TEST BENCH
// UNIT       : DRIVER
//-------------------------------------------------------------------------------------------------
// TITLE      : UART DRIVER 
// DESCRIPTION: THIS DRIVER IS RESPONSIBLE FOR SETTING BFMS CONFIGURATIONS. ALSO DRIVING STIMULUS
//              TO THE BFMS AND SENDING TRANSACTIONS TO SCOREBOARD.
//-------------------------------------------------------------------------------------------------
// LOG DETAILS
//-------------
// VERSION      NAME        DATE        DESCRIPTION
//    1       HANY SALAH    02012016    FILE CREATION
//    2       HANY SALAH    07012016    ADD INITIALIZE BFM METHOD
//    3       HANY SALAH    17022016    IMPROVE BLOCK DESCRIPTION AND ADD COMMENTS
//-------------------------------------------------------------------------------------------------
// ALL COPYRIGHTS ARE RESERVED FOR THE PRODUCER ONLY .THIS FILE IS PRODUCED FOR OPENCORES MEMBERS 
// ONLY AND IT IS PROHIBTED TO USE THIS MATERIAL WITHOUT THE CREATOR'S PERMISSION
//-------------------------------------------------------------------------------------------------

class uart_driver extends uvm_driver #(uart_transaction);

  // Two Transaction Instances that are used to bring and clone the stimulus
  uart_transaction      trans,_trans;

  // Instance from Global UART Configuration
  uart_config           _config;

  // UART Interafce instance
  virtual uart_interface  uart_inf;

  // RF Interface instance
  virtual rf_interface rf_inf;

  // Arbiter Interface Instance
  virtual uart_arbiter  arb_inf;

  // Analysis Port to both scoreboard and driver
  uvm_analysis_port #(uart_transaction)   drv_scbd_cov;

  `uvm_component_utils(uart_driver)

  function new (string name , uvm_component parent);
    super.new(name,parent);
  endfunction: new

  // UVM Build Phase Declaration that includes locating instances and get interfaces handler from 
  // the configuration database
  extern function void build_phase (uvm_phase phase);
  
  // Both BFMs configurations setting and BFMs assignment are carried out through this UVM phase.
  extern function void end_of_elaboration_phase (uvm_phase phase);

  extern task run_phase (uvm_phase phase);

  // Actual drive data routine
  extern task drive_data ();

  // initialize bfms
  extern function void initialize_bfms (act_edge  _edge,
                                        start_bit _bit,
                                        int enable,
                                        int num_stop_bits,
                                        int num_of_bits,
                                        data_mode _datamode,
                                        parity_mode _paritymode,
                                        time _resp);
endclass:uart_driver

function void uart_driver::build_phase (uvm_phase phase);
  super.build_phase(phase);

  trans   = uart_transaction::type_id::create("trans");
  _trans  = uart_transaction::type_id::create("_trans");

  _config = uart_config::type_id::create("_config");

  drv_scbd_cov = new("drv_scbd_cov",this);

endfunction:build_phase

function void uart_driver::end_of_elaboration_phase (uvm_phase phase);

  if(!uvm_config_db#(uart_config)::get(this, "", "UART_CONFIGURATION", _config))
    `uvm_fatal("NOCONFIGURATION",{"configuration instance must be set for: ",get_full_name(),"._config"});

  if(!uvm_config_db#(virtual uart_interface)::get(this, "", "uart_inf", _config.uart_inf))
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".uart_inf"});
    uart_inf=_config.uart_inf;

  if(!uvm_config_db#(virtual rf_interface)::get(this, "", "rf_inf", _config.rf_inf))
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".rf_inf"});
    rf_inf=_config.rf_inf;  

  if(!uvm_config_db#(virtual uart_arbiter)::get(this,"","arb_inf",_config.arb_inf))
      `uvm_fatal("NOVIF",{"virtual interface must be set for:",get_full_name(),".arb_inf"})
    arb_inf=_config.arb_inf;
  initialize_bfms(_config._edge,
              _config._start,
              _config.use_false_data,
              _config.num_stop_bits,
              _config.num_of_bits,
              _config._datamode,
              _config._paritymode,
              _config.response_time);

endfunction:end_of_elaboration_phase

function void uart_driver::initialize_bfms (act_edge  _edge,
                                            start_bit _bit,
                                            int  enable,
                                            int num_stop_bits,
                                            int num_of_bits,
                                            data_mode _datamode,
                                            parity_mode _paritymode,
                                            time      _resp);
  uart_inf.set_configuration (_edge,_bit,num_stop_bits,num_of_bits,_datamode,_paritymode,_resp,enable);
   
endfunction:initialize_bfms

task uart_driver::run_phase (uvm_phase phase);
  
  forever
    begin
    seq_item_port.get_next_item(_trans);
    $cast(trans,_trans.clone());
    drv_scbd_cov.write(trans);
    drive_data();
    seq_item_port.item_done();
    end
endtask:run_phase

task uart_driver::drive_data();
  uart_inf.wait_idle_time(trans.time_before*trans.scale);
  uart_inf.set_event();
  if (trans._mode == text || trans._mode == wrong_mode_text)
    begin
    case(trans._command)
      read:
        begin
        rf_inf.fill_byte (trans.address,
                          trans._data[0]);
        uart_inf.read_text_mode(trans._mode,
                                trans.wrong_prefix,
                                trans._chartype,
                                trans._spacetype1,
                                trans.space_wrong1,
                                trans._eoltype,
                                trans.eol_wrong,
                                trans.address,
                                trans.false_data[0],
                                trans.false_data_en);

        end
      write:
        begin
        uart_inf.write_text_mode(trans._mode,
                                 trans.wrong_prefix,
                                 trans._chartype,
                                 trans._spacetype1,
                                 trans.space_wrong1,
                                 trans._spacetype2,
                                 trans.space_wrong2,
                                 trans._eoltype,
                                 trans.eol_wrong,
                                 trans.address,
                                 trans._data[0]);

        end
      nop:
        begin
        `uvm_fatal("TB ISSUE","NOP command value shouldn't be valued in text mode")
        end
      default:
        begin
        `uvm_fatal("TB ISSUE", "wrong_mode")
        end
    endcase
    end
  else if (trans._mode==binary || trans._mode==wrong_mode_bin)
    begin
    if (trans._command == read || trans._command == invalid_read)
      begin
      rf_inf.fill_block(trans.address,
                        trans._data,
                        trans.length_data);
      uart_inf.read_binary_mode(trans._mode,
                                trans.wrong_prefix,
                                trans._command,
                                trans._reqack,
                                trans._reqinc,
                                trans.length_data,
                                trans.address,
                                trans._data,
                                trans.false_data,
                                trans.false_data_en);
      end
    else if (trans._command == write || trans._command == invalid_write)
      begin
      uart_inf.write_binary_mode(trans._mode,
                                 trans.wrong_prefix,
                                 trans._command,
                                 trans._reqack,
                                 trans._reqinc,
                                 trans.length_data,
                                 trans.address,
                                 trans._data);
      end
    else
      begin
      uart_inf.nop_command(trans._mode,
                           trans.wrong_prefix,
                           trans._reqack,
                           trans._reqinc);
      end

    end
  uart_inf.wait_idle_time(trans.time_after*trans.scale);
endtask:drive_data
