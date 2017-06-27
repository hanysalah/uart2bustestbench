//-------------------------------------------------------------------------------------------------
//
//                             UART2BUS VERIFICATION
//
//-------------------------------------------------------------------------------------------------
// CREATOR    : HANY SALAH
// PROJECT    : UART2BUS UVM TEST BENCH
// UNIT       : TRANSACTION
//-------------------------------------------------------------------------------------------------
// TITLE      : UART Transaction 
// DESCRIPTION: THIS FILE INCLUDES MAIN TRANSACTION ATTRIBUTES, CONSTRAINTS AND DO-COPY OVERRIDE 
//              FUNCTION 
//-------------------------------------------------------------------------------------------------
// LOG DETAILS
//-------------
// VERSION      NAME        DATE        DESCRIPTION
//    1       HANY SALAH    31122015    FILE CREATION
//    2       HANY SALAH    01012016    COMPLETE ATTRIBUTES
//    3       HANY SALAH    26012016    ADD VALID TRANSACTION CONSTRAINTS
//    4       HANY SALAH    11022016    IMPROVE BLOCK DESCRIPTION AND ADD CODING COMMENTS
//    5       HANY SALAH    25062017    ADD DO_COPY, DO_COMPARE METHODS
//-------------------------------------------------------------------------------------------------
// ALL COPYRIGHTS ARE RESERVED FOR THE PRODUCER ONLY .THIS FILE IS PRODUCED FOR OPENCORES MEMBERS 
// ONLY AND IT IS PROHIBTED TO USE THIS MATERIAL WITHOUT THE CREATOR'S PERMISSION
//-------------------------------------------------------------------------------------------------
class uart_transaction extends uvm_sequence_item;
 
  // Represent the mode of operation either to be text or command mode
  rand mode        _mode;

  // Represent the wrong prefix forced in wrong mode
  rand byte        wrong_prefix;

  // Represent the type of space either to be single space or tab 
  rand space_type  _spacetype1,_spacetype2;

  // Represent the wrong character used as a white space [Refer To Verification Plan For More
  // Information]
  rand  byte        space_wrong1;

  // Represent the wrong character used as a white space [Refer To Verification Plan For More 
  // Information]
  rand  byte        space_wrong2;
  
  // Represent the used data through the stimulus
  rand  byte       _data [];

  // Represent the false data that is drivin on the serial output bus through the read command 
  // response
  rand  byte       false_data [];

  // Represent the length of data used through the stimulus
  rand int unsigned length_data;

  // Represent the type of end of line used 
  rand eol_type     _eoltype;

  // Represent the wrong character used as an end of line [Refer To Verification Plan For More 
  // Information]
  rand byte         eol_wrong;

  // Represent the used address through the stimulus
  rand bit [15:0]   address;

  // Represent the type of command either read, write or no operation
  rand command      _command;

  // Represent the acknowledge request
  rand req      _reqack;

  // Represent the incremental address request
  rand req      _reqinc;

  // Represent the character type of prefix in text mode command
  rand char_type    _chartype;

  // Represent the internal bus state either free or busy
  rand arbit        _arbit;

  // Represent the request to use false data through the read command.
  rand req          false_data_en;

  // Represents random idle time before and after the UART stimulus
  rand int         time_before,time_after;

  // Represents the acknowledge byte driven by the DUT
  byte            acknowledge;

  // Represent the number of the transaction through the whole sequences
  int             _id;

  // Represent the scale that is used to scale the idle time values described above
  int unsigned scale = 100;

  `uvm_object_utils_begin(uart_transaction)
     `uvm_field_int(wrong_prefix,UVM_ALL_ON)
     `uvm_field_enum(mode,_mode,UVM_ALL_ON)
     `uvm_field_enum(eol_type,_eoltype,UVM_ALL_ON)
     `uvm_field_enum(space_type,_spacetype1,UVM_ALL_ON)
     `uvm_field_enum(space_type,_spacetype2,UVM_ALL_ON)
     `uvm_field_enum(command,_command,UVM_ALL_ON)
     `uvm_field_enum(req,_reqack,UVM_ALL_ON)
     `uvm_field_enum(req,_reqinc,UVM_ALL_ON)
     `uvm_field_enum(char_type,_chartype,UVM_ALL_ON)
     `uvm_field_enum(arbit,_arbit,UVM_ALL_ON)
     `uvm_field_enum(req,false_data_en,UVM_ALL_ON)
     `uvm_field_int(wrong_prefix,UVM_ALL_ON)
     `uvm_field_int(space_wrong1,UVM_ALL_ON)
     `uvm_field_int(space_wrong2,UVM_ALL_ON)
     `uvm_field_array_int(_data,UVM_ALL_ON)
     `uvm_field_array_int(false_data,UVM_ALL_ON)
     `uvm_field_int(length_data,UVM_ALL_ON)
     `uvm_field_int(eol_wrong,UVM_ALL_ON)
     `uvm_field_int(address,UVM_ALL_ON)
     `uvm_field_int(time_before,UVM_ALL_ON)
     `uvm_field_int(time_after,UVM_ALL_ON)
     `uvm_field_int(acknowledge,UVM_ALL_ON)
     `uvm_field_int(_id,UVM_ALL_ON)
     `uvm_field_int(scale,UVM_ALL_ON)
  `uvm_object_utils_end
   
  function new (string name ="uart_transaction");
    super.new(name);
  endfunction: new

  // This constraint limit the size of unbounded data and false data arrays to be in the range 
  // between one byte and 256 successive bytes.
  // To make Testbench more simple, the length of data is constrained to be less than or equal
  // 10 bytes.
  // Idle time valu
  constraint data_length {
      _data.size == length_data;
      false_data.size ==length_data;
      length_data <= 10;
      length_data inside {[1:256]};
      time_before inside {200,300,400,500,600,700,800,900,1000};
      time_after  inside {200,300,400,500,600,700,800,900,1000};
  }

  // This constraint is used to constrain the wrong character not to be as the UART standard 
  // characters.
  // In case of text command, it is critical to make the white space wrong character
  // not to be simiar to either single space character or Tab space character.Address and Data 
  // bytes as well shouldn't be like the standard characters.
  // In case of binary command, it is also critical to make the length byte, address bytes, data
  // bytes similiar to UART standard characters.
  constraint transaction_valid {
      !(space_wrong1 inside {`space,`tab,`w,`W,`bin_prfx,`CR,`LF});
      !(space_wrong2 inside {`space,`tab,`w,`W,`bin_prfx,`CR,`LF});
      !(eol_wrong inside {`space,`tab,`w,`W,`bin_prfx,`CR,`LF});
      if (_mode inside {wrong_mode_text,wrong_mode_bin})
        {
          !(space_wrong1 inside {`w,`W,`r,`R,`bin_prfx});
          !(space_wrong2 inside {`w,`W,`r,`R,`bin_prfx});
          !(address [15:08] inside {`w,`W,`r,`R,`bin_prfx});
          !(address [07:00] inside {`w,`W,`r,`R,`bin_prfx});
          foreach(_data[i])
            !(_data[i] inside {`w,`W,`r,`R,`bin_prfx});

          !(length_data inside {`w,`W,`r,`R,`bin_prfx});


        }
  }

  // This constraint is used to re-distribute the random enable bit of the false data usage
  constraint read_data_constraints{

      if(_command == read)
      {
        false_data_en dist {no:=8, yes:=2};
      }
  }

  extern function void do_copy (uvm_object rhs);

  //extern function bit do_compare(uvm_object rhs);

  extern function void do_print(uvm_printer printer=null);
   
   
endclass:uart_transaction


function void uart_transaction::do_copy (uvm_object rhs);
  uart_transaction _trans;
  if (!$cast(_trans,rhs))
    begin
    `uvm_fatal("TYPE MISMATCH","Type mismatch through do_copy method")
    end
  super.do_copy (_trans);
  _mode       =_trans._mode;
  _spacetype1 =_trans._spacetype1;
  _spacetype2 =_trans._spacetype2;
  space_wrong1=_trans.space_wrong1;
  space_wrong2=_trans.space_wrong2;
  _data       =_trans._data;
  length_data =_trans.length_data;
  _eoltype    =_trans._eoltype;
  eol_wrong   =_trans.eol_wrong;
  address     =_trans.address;
  _command    =_trans._command;
  _reqack     =_trans._reqack;
  _reqinc     =_trans._reqinc;
  _chartype   =_trans._chartype;
  _arbit      =_trans._arbit;
  time_before =_trans.time_before;
  time_after  =_trans.time_after;
  acknowledge = _trans.acknowledge;
  wrong_prefix=_trans.wrong_prefix;
  false_data  =_trans.false_data;
  false_data_en =_trans.false_data_en;
  _id           =_trans._id;
endfunction:do_copy


/*function bit uart_transaction::do_compare(uvm_object rhs,
					  uvm_comparer comparer);
   uart_transaction t;
   do_compare=super.do_compare(rhs,comparer);
   $cast(t,rhs);
   do_compare &= comparer.compare_field_ ("_mode",_mode,rhs._mode);
   do_compare &= comparer.compare_field_ ("_spacetype1",_spacetype1, rhs._spacetype1);
   do_compare &= comparer.compare_field_ ("_spacetype2",_spacetype2, rhs._spacetype2);
   do_compare &= comparer.compare_field_ ("space_wrong1",space_wrong1, rhs.space_wrong1);
   do_compare &= comparer.compare_field_ ("space_wrong2",space_wrong2, rhs.space_wrong2);
   do_compare &= comparer.compare_field_ ("_data",_data, rhs._data);
   do_compare &= comparer.compare_field_ ("length_data",length_data, rhs.length_data);
   do_compare &= comparer.compare_field_ ("_eoltype",_eoltype, rhs._eoltype);
   do_compare &= comparer.compare_field_ ("eol_wrong",eol_wrong, rhs.eol_wrong);
   do_compare &= comparer.compare_field_ ("address",address, rhs.address);
   do_compare &= comparer.compare_field_ ("_command",_command, rhs._command);
   do_compare &= comparer.compare_field_ ("_reqack",_reqack, rhs._reqack);
   do_compare &= comparer.compare_field_ ("_reqinc",_reqinc, rhs._reqinc);
   do_compare &= comparer.compare_field_ ("_chartype",_chartype, rhs._chartype);
   do_compare &= comparer.compare_field_ ("_arbit",_arbit, rhs._arbit);
   do_compare &= comparer.compare_field_ ("time_before",time_before, rhs.time_before);
   do_compare &= comparer.compare_field_ ("time_after",time_after, rhs.time_after);
   do_compare &= comparer.compare_field_ ("acknowledge",acknowledge, rhs.acknowledge);
   do_compare &= comparer.compare_field_ ("wrong_prefix",wrong_prefix, rhs.wrong_prefix);
   do_compare &= comparer.compare_field_ ("false_data",false_data, rhs.false_data);
   do_compare &= comparer.compare_field_ ("false_data_en",false_data_en, rhs.false_data_en);
   do_compare &= comparer.compare_field_ ("_id",_id, rhs._id);
endfunction // do_compare*/

function void uart_transaction::do_print(uvm_printer printer=null);
   super.do_print(printer);
endfunction // do_print
