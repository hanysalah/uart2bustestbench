//-------------------------------------------------------------------------------------------------
//
//                             UART2BUS VERIFICATION
//
//-------------------------------------------------------------------------------------------------
// CREATOR    : HANY SALAH
// PROJECT    : UART2BUS UVM TEST BENCH
// UNIT       : AGENT
//-------------------------------------------------------------------------------------------------
// TITLE      : UART Coverage 
// DESCRIPTION: THIS BLOCK INCLUDES ALL THE COVERPINS THAT ARE SAMPLED EACH STIMULUS 
//-------------------------------------------------------------------------------------------------
// LOG DETAILS
//-------------
// VERSION      NAME        DATE        DESCRIPTION
//    1       HANY SALAH    08022016    FILE CREATION
//    2       HANY SALAH    11022016    IMPROVE BLOCK DESCRIPTION & ADD CODE COMMENTS
//-------------------------------------------------------------------------------------------------
// ALL COPYRIGHTS ARE RESERVED FOR THE PRODUCER ONLY .THIS FILE IS PRODUCED FOR OPENCORES MEMBERS 
// ONLY AND IT IS PROHIBTED TO USE THIS MATERIAL WITHOUT THE CREATOR'S PERMISSION
//-------------------------------------------------------------------------------------------------


class uart_coverage extends uvm_subscriber#(uart_transaction);
  
  `uvm_component_utils(uart_coverage)

  uart_transaction        trans,_trans;

  covergroup trans_attrib;
    communication_mode:
      coverpoint trans._mode{
        bins valid_mode         = {text,binary};
        illegal_bins invalid_mode       = {wrong_mode_text,wrong_mode_bin};
      }
    address:
      coverpoint trans.address;

  endgroup:trans_attrib

  covergroup text_mode_cov;
    command:
      coverpoint trans._command{
        bins          valid_command  ={read,2};
        illegal_bins  invalid_command={nop,invalid_read,invalid_write};
      }
    first_white_space_field:
      coverpoint trans._spacetype1{bins         validspace   ={single,tab};
				   illegal_bins invalidspace ={wrong_space};}
    second_white_space_field:
      coverpoint trans._spacetype2{bins         validspace   ={single,tab};
				   illegal_bins invalidspace ={wrong_space};}
    end_of_line_field:
      coverpoint trans._eoltype{bins         valideol={cr,lf};
				illegal_bins eol ={wrong_eol};}
    prefix_character_type:
      coverpoint trans._chartype;
     
  endgroup:text_mode_cov

  covergroup binary_mode_cov;
    command:
      coverpoint trans._command{
        bins normal_command={read,2,nop};
        illegal_bins wrong_command ={invalid_read,invalid_write};
      }
    acknowledge_requirement:
      coverpoint trans._reqack;
    incremental_address_requirement:
      coverpoint trans._reqinc;
    Length_of_data:
      coverpoint trans.length_data{
        bins zero           = {0};
        bins valid          = {[1:256]};
        illegal_bins invalid= {[257:$]};
      }
  endgroup:binary_mode_cov

  function new (string name, uvm_component parent);
    super.new(name,parent);
    
    trans_attrib    = new();
    text_mode_cov   = new();
    binary_mode_cov = new();
  endfunction:new

  extern function void build_phase(uvm_phase phase);

  extern function void connect_phase (uvm_phase phase);
   
  extern task run_phase (uvm_phase);

  extern function void write (uart_transaction t);
   
  
endclass:uart_coverage


function void uart_coverage::build_phase (uvm_phase phase);
  super.build_phase(phase);


  trans  = uart_transaction::type_id::create("trans");
  _trans = uart_transaction::type_id::create("_trans");

endfunction:build_phase

function void uart_coverage::connect_phase(uvm_phase phase);
endfunction:connect_phase

task uart_coverage::run_phase(uvm_phase phase);

endtask:run_phase

function void uart_coverage::write(uart_transaction t);
   $cast(trans,t.clone());
   trans_attrib.sample();
   uvm_resource_db#(int)::write_by_name("coverage_cloud","general_coverage",trans_attrib.get_coverage());   
    if(trans._mode == text)
      begin
      text_mode_cov.sample();
      uvm_resource_db#(int)::write_by_name("coverage_cloud","text_coverage",text_mode_cov.get_coverage());
      end
    else if (trans._mode == binary)
      begin
      binary_mode_cov.sample();
      uvm_resource_db#(int)::write_by_name("coverage_cloud","binary_coverage",binary_mode_cov.get_coverage());
      end
endfunction // write
