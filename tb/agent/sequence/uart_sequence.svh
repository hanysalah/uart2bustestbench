//-------------------------------------------------------------------------------------------------
//
//                             UART2BUS VERIFICATION
//
//-------------------------------------------------------------------------------------------------
// CREATOR    : HANY SALAH
// PROJECT    : UART2BUS UVM TEST BENCH
// UNIT       : SEQUENCE
//-------------------------------------------------------------------------------------------------
// TITLE      : UART SEQUENCE 
// DESCRIPTION: THIS FILE INCLUDES THE ALL SEQUENCES THAT WOULD BE FORCED INTO DUT. THE SEQUENCES 
//              MENTIONED BELOW IS IDENTIFIED IN THE MANNER RELATED TO THE TEST PLAN SECTION IN 
//              THE DOCUMENT; IT IS IDENTIFIED USING TWO TERMS; SUBSECTION AND ITEM INSIDE SUB-
//              SECTION. 
//-------------------------------------------------------------------------------------------------
// LOG DETAILS
//-------------
// VERSION      NAME        DATE        DESCRIPTION
//    1       HANY SALAH    01012016    FILE CREATION
//    2       HANY SALAH    02012016    ADD REST OF TESTS
//    3       HANY SALAH    29012016    INSERT WRONG MODE IN BOTH BINARY AND TEXT COMMUNICATION
//                                      MODES
//    4       HANY SALAH    09022016    REFINE BLOCK DESCRIPTION
//-------------------------------------------------------------------------------------------------
// ALL COPYRIGHTS ARE RESERVED FOR THE PRODUCER ONLY .THIS FILE IS PRODUCED FOR OPENCORES MEMBERS 
// ONLY AND IT IS PROHIBTED TO USE THIS MATERIAL WITHOUT THE CREATOR'S PERMISSION
//-------------------------------------------------------------------------------------------------

// Base Sequence Class that hold the common attributes to all sequences
class uart_base_sequence extends uvm_sequence #(uart_transaction);
  
  uart_transaction    trans;

  `uvm_object_utils(uart_base_sequence)

  function new (string name = "uart_base_sequence");
    super.new(name);
    trans = uart_transaction::type_id::create("trans");
  endfunction:new
endclass:uart_base_sequence

//-------------------------------------------------------------------------------------------------
//
//                                    WRITE IN TEXT MODE
//
//-------------------------------------------------------------------------------------------------

  // 1.1 Apply UART write request using capital W
  class seq_1p1 extends uart_base_sequence;
    
    `uvm_object_utils(seq_1p1)

    function new (string name = "seq_1p1");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == text;
        _spacetype1 != wrong_space;
        _spacetype2 != wrong_space;
        length_data == 1;
        _eoltype    != wrong_eol;
        _command    == write;
        _reqinc     == no;
        _arbit      == accept;
        _chartype   == cap;
      }; 
      finish_item(trans);
    endtask:body
  endclass:seq_1p1


  // 1.2 Apply UART write request using small w
  class seq_1p2 extends uart_base_sequence;
    
    `uvm_object_utils(seq_1p2)

    function new (string name = "seq_1p2");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == text;
        _spacetype1 != wrong_space;
        _spacetype2 != wrong_space;
        length_data == 1;
        _eoltype    != wrong_eol;
        _command    == write;
        _reqinc     == no;
        _arbit      == accept;
        _chartype   == smal;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_1p2


  // 1.3 Apply UART write request using single space only
  class seq_1p3 extends uart_base_sequence;
    
    `uvm_object_utils(seq_1p3)

    function new (string name = "seq_1p3");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == text;
        _spacetype1 == single;
        _spacetype2 == single;
        length_data == 1;
        _eoltype    != wrong_eol;
        _command    == write;
        _reqinc     == no;
        _arbit      == accept;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_1p3


  // 1.4 Apply UART write request using tab only.
  class seq_1p4 extends uart_base_sequence;
    
    `uvm_object_utils(seq_1p4)

    function new (string name = "seq_1p4");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == text;
        _spacetype1 == tab;
        _spacetype2 == tab;
        length_data == 1;
        _eoltype    != wrong_eol;
        _command    == write;
        _reqinc     == no;
        _arbit      == accept;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_1p4


  // 1.5 Apply UART write request using both single space and tab.
  class seq_1p5 extends uart_base_sequence;
    
    `uvm_object_utils(seq_1p5)

    function new (string name = "seq_1p5");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == text;
        _spacetype1 != wrong_space;
        _spacetype2 != wrong_space;
        _spacetype2 != _spacetype1;
        length_data == 1;
        _eoltype    != wrong_eol;
        _command    == write;
        _reqinc     == no;
        _arbit      == accept;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_1p5


  // 1.6 Apply UART write request using one wrong space.
  class seq_1p6 extends uart_base_sequence;
    
    `uvm_object_utils(seq_1p6)

    function new (string name = "seq_1p6");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == text;
        (_spacetype1 == wrong_space) -> (_spacetype2 inside {tab, single});
        (_spacetype1 != wrong_space) -> (_spacetype2 == wrong_space);  
        length_data == 1;
        _eoltype    != wrong_eol;
        _command    == write;
        _reqinc     == no;
        _arbit      == accept;
      }; 
      finish_item(trans);
    endtask:body
  endclass:seq_1p6


  // 1.7 Apply UART write request using two wrong spaces
  class seq_1p7 extends uart_base_sequence;
    
    `uvm_object_utils(seq_1p7)

    function new (string name = "seq_1p7");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == text;
        _spacetype1 == wrong_space;
        _spacetype2 == wrong_space;
        length_data == 1;
        _eoltype    != wrong_eol;
        _command    == write;
        _reqinc     == no;
        _arbit      == accept;
      }; 
      finish_item(trans);
    endtask:body
  endclass:seq_1p7


  // 1.8 Apply UART write request to address 0
  class seq_1p8 extends uart_base_sequence;
    
    `uvm_object_utils(seq_1p8)

    function new (string name = "seq_1p8");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == text;
        _spacetype1 != wrong_space;
        _spacetype2 != wrong_space;
        length_data == 1;
        _eoltype    != wrong_eol;
        _command    == write;
        address     == 16'b0;
        _reqinc     == no;
        _arbit      == accept;
      }; 
      finish_item(trans);
    endtask:body
  endclass:seq_1p8


  // 1.9 Apply UART write request to full range address
  class seq_1p9 extends uart_base_sequence;
    
    `uvm_object_utils(seq_1p9)

    function new (string name = "seq_1p9");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == text;
        _spacetype1 != wrong_space;
        _spacetype2 != wrong_space;
        length_data == 1;
        _eoltype    != wrong_eol;
        _command    == write;
        address     == 16'hFFFF;
        _reqinc     == no;
        _arbit      == accept;
      }; 
      finish_item(trans);
    endtask:body
  endclass:seq_1p9


  // 1.10 Apply UART write request with data equal 0.
  class seq_1p10 extends uart_base_sequence;
    
    `uvm_object_utils(seq_1p10)

    function new (string name = "seq_1p10");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == text;
        _spacetype1 != wrong_space;
        _spacetype2 != wrong_space;
        length_data == 1;
        _eoltype    != wrong_eol;
        _command    == write;
        _data [0]   == 8'b0;
        _reqinc     == no;
        _arbit      == accept;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_1p10


  // 1.11 Apply UART write request with full range data.
  class seq_1p11 extends uart_base_sequence;
    
    `uvm_object_utils(seq_1p11)

    function new (string name = "seq_1p11");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == text;
        _spacetype1 != wrong_space;
        _spacetype2 != wrong_space;
        length_data == 1;
        _eoltype    != wrong_eol;
        _command    == write;
        _data [0]   == 8'hff;
        _reqinc     == no;
        _arbit      == accept;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_1p11


  // 1.12 Apply UART write request using different EOL character.
  class seq_1p12 extends uart_base_sequence;
    
    `uvm_object_utils(seq_1p12)

    function new (string name = "seq_1p12");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == text;
        _spacetype1 != wrong_space;
        _spacetype2 != wrong_space;
        length_data == 1;
        _eoltype    == wrong_eol;
        _command    == write;
        _reqinc     == no;
        _arbit      == accept;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_1p12


  // 1.13 Apply UART Write request using wrong prefix
  class seq_1p13 extends uart_base_sequence;
    
    `uvm_object_utils(seq_1p13)

    function new (string name = "seq_1p13");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == wrong_mode_text;
        _spacetype1 != wrong_space;
        _spacetype2 != wrong_space;
        length_data == 1;
        _eoltype    != wrong_eol;
        _command    == write;
        _reqinc     == no;
        _arbit      == accept;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_1p13

//-------------------------------------------------------------------------------------------------
//
//                                    READ IN TEXT MODE
//
//-------------------------------------------------------------------------------------------------

  // 2.1 Apply UART read request using capital R
  class seq_2p1 extends uart_base_sequence;
    
    `uvm_object_utils(seq_2p1)

    function new (string name = "seq_2p1");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == text;
        _spacetype1 != wrong_space;
        _spacetype2 != wrong_space;
        length_data == 1;
        _eoltype    != wrong_eol;
        _command    == read;
        _reqinc     == no;
        _arbit      == accept;
        _chartype   == cap;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_2p1


  // 2.2 Apply UART read request using small r
  class seq_2p2 extends uart_base_sequence;
    
    `uvm_object_utils(seq_2p2)

    function new (string name = "seq_2p2");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == text;
        _spacetype1 != wrong_space;
        _spacetype2 != wrong_space;
        length_data == 1;
        _eoltype    != wrong_eol;
        _command    == read;
        _reqinc     == no;
        _arbit      == accept;
        _chartype   == smal;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_2p2


  // 2.3 Apply UART read request using single space only
  class seq_2p3 extends uart_base_sequence;
    
    `uvm_object_utils(seq_2p3)

    function new (string name = "seq_2p3");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == text;
        _spacetype1 == single;
        _spacetype2 == single;
        length_data == 1;
        _eoltype    != wrong_eol;
        _command    == read;
        _reqinc     == no;
        _arbit      == accept;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_2p3


  // 2.4 Apply UART read request using tab only.
  class seq_2p4 extends uart_base_sequence;
    
    `uvm_object_utils(seq_2p4)

    function new (string name = "seq_2p4");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == text;
        _spacetype1 == tab;
        _spacetype2 == tab;
        length_data == 1;
        _eoltype    != wrong_eol;
        _command    == read;
        _reqinc     == no;
        _arbit      == accept;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_2p4


  // 2.5 Apply UART read request using both single space and tab.
  class seq_2p5 extends uart_base_sequence;
    
    `uvm_object_utils(seq_2p5)

    function new (string name = "seq_2p5");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == text;
        _spacetype1 != wrong_space;
        _spacetype2 != wrong_space;
        _spacetype2 != _spacetype1;
        length_data == 1;
        _eoltype    != wrong_eol;
        _command    == read;
        _reqinc     == no;
        _arbit      == accept;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_2p5


  // 2.6 Apply UART read request using one wrong space.
  class seq_2p6 extends uart_base_sequence;
    
    `uvm_object_utils(seq_2p6)

    function new (string name = "seq_2p6");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == text;
        (_spacetype1 == wrong_space) -> (_spacetype2 inside {tab, single});
        (_spacetype1 != wrong_space) -> (_spacetype2 == wrong_space);  
        length_data == 1;
        _eoltype    != wrong_eol;
        _command    == read;
        _reqinc     == no;
        _arbit      == accept;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_2p6


  // 2.7 Apply UART read request using two wrong spaces
  class seq_2p7 extends uart_base_sequence;
    
    `uvm_object_utils(seq_2p7)

    function new (string name = "seq_2p7");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == text;
        _spacetype1 == wrong_space;
        _spacetype2 == wrong_space;
        length_data == 1;
        _eoltype    != wrong_eol;
        _command    == read;
        _reqinc     == no;
        _arbit      == accept;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_2p7


  // 2.8 Apply UART read request to address 0
  class seq_2p8 extends uart_base_sequence;
    
    `uvm_object_utils(seq_2p8)

    function new (string name = "seq_2p8");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == text;
        _spacetype1 != wrong_space;
        _spacetype2 != wrong_space;
        length_data == 1;
        _eoltype    != wrong_eol;
        _command    == read;
        address     == 16'b0;
        _reqinc     == no;
        _arbit      == accept;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_2p8


  // 2.9 Apply UART read request to full range address
  class seq_2p9 extends uart_base_sequence;
    
    `uvm_object_utils(seq_2p9)

    function new (string name = "seq_2p9");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == text;
        _spacetype1 != wrong_space;
        _spacetype2 != wrong_space;
        length_data == 1;
        _eoltype    != wrong_eol;
        _command    == read;
        address     == 16'hFFFF;
        _reqinc     == no;
        _arbit      == accept;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_2p9


  // 2.10 Apply UART read request with data equal 0.
  class seq_2p10 extends uart_base_sequence;
    
    `uvm_object_utils(seq_2p10)

    function new (string name = "seq_2p10");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == text;
        _spacetype1 != wrong_space;
        _spacetype2 != wrong_space;
        length_data == 1;
        _eoltype    != wrong_eol;
        _command    == read;
        _data [0]   == 8'b0;
        _reqinc     == no;
        _arbit      == accept;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_2p10


  // 2.11 Apply UART read request with full range data.
  class seq_2p11 extends uart_base_sequence;
    
    `uvm_object_utils(seq_2p11)

    function new (string name = "seq_2p11");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == text;
        _spacetype1 != wrong_space;
        _spacetype2 != wrong_space;
        length_data == 1;
        _eoltype    != wrong_eol;
        _command    == read;
        _data [0]   == 8'hff;
        _reqinc     == no;
        _arbit      == accept;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_2p11


  // 2.12 Apply UART read request using different EOL character.
  class seq_2p12 extends uart_base_sequence;
    
    `uvm_object_utils(seq_2p12)

    function new (string name = "seq_2p12");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == text;
        _spacetype1 != wrong_space;
        _spacetype2 != wrong_space;
        length_data == 1;
        _eoltype    == wrong_eol;
        _command    == read;
        _reqinc     == no;
        _arbit      == accept;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_2p12


  // 2.13 Apply UART Read request using wrong prefix
  class seq_2p13 extends uart_base_sequence;
    
    `uvm_object_utils(seq_2p13)

    function new (string name = "seq_2p13");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == wrong_mode_text;
        _spacetype1 != wrong_space;
        _spacetype2 != wrong_space;
        length_data == 1;
        _eoltype    != wrong_eol;
        _command    == read;
        _reqinc     == no;
        _arbit      == accept;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_2p13

//-------------------------------------------------------------------------------------------------
//
//                                    NOP IN COMMAND MODE
//
//-------------------------------------------------------------------------------------------------

  // 3.1 Apply UART NOP command with acknowledge request and right command
  //     mode prefix
  class seq_3p1 extends uart_base_sequence;
    
    `uvm_object_utils(seq_3p1)

    function new (string name = "seq_3p1");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == binary;
        _command    == nop;
        (length_data > 1) -> (_reqinc == yes);
        _arbit      == accept;
        _reqack     == yes;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_3p1

  // 3.2 Apply UART NOP command with acknowledge request and wrong command
  //     mode prefix
  class seq_3p2 extends uart_base_sequence;
    
    `uvm_object_utils(seq_3p2)

    function new (string name = "seq_3p2");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == wrong_mode_bin;
        _command    == nop;
        address     != 16'h0;
        (length_data > 1) -> (_reqinc == yes);
        _arbit      == accept;
        _reqack     == yes;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_3p2

  // 3.3 Apply several UART NOP command to different locations with different
  //     data lengths
  class seq_3p3 extends uart_base_sequence;
    
    rand int unsigned num_of_comands;

    `uvm_object_utils(seq_3p3)

    function new (string name = "seq_3p3");
      super.new(name);
    endfunction:new

    constraint num_iter {
      num_of_comands inside {[1:5]};
    }

    virtual task body ();
      randomize();
      start_item(trans);
      repeat (num_of_comands)
        begin
        trans.randomize() with {
          _mode       == binary;
          _command    == nop;
          (length_data > 1) -> (_reqinc == yes);
          _arbit      == accept;
          _reqack     == yes;
        } ;
        end
      finish_item(trans);
    endtask:body
  endclass:seq_3p3

  // 4.1 Apply UART NOP command with non-acknowledge request and right command
  //     mode prefix
  class seq_4p1 extends uart_base_sequence;
    
    `uvm_object_utils(seq_4p1)

    function new (string name = "seq_4p1");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == binary;
        _command    == nop;
        (length_data > 1) -> (_reqinc == yes);
        _arbit      == accept;
        _reqack     == no;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_4p1

  // 4.2 Apply UART NOP command with non-acknowledge request and wrong command
  //     mode prefix
  class seq_4p2 extends uart_base_sequence;
    
    `uvm_object_utils(seq_4p2)

    function new (string name = "seq_4p2");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == wrong_mode_bin;
        _command    == nop;
        address[15:7] != 8'h00;
        (length_data > 1) -> (_reqinc == yes);
        _arbit      == accept;
        _reqack     == no;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_4p2

  // 4.3 Apply several UART NOP command to different locations with different
  //     data lengths and non-acknowledge request
  class seq_4p3 extends uart_base_sequence;
    
    rand int unsigned num_of_comands;

    `uvm_object_utils(seq_4p3)

    function new (string name = "seq_4p3");
      super.new(name);
    endfunction:new

    constraint num_iter {
      num_of_comands inside {[1:5]};
    }

    virtual task body ();
      randomize();
      start_item(trans);
      repeat (num_of_comands)
        begin
        trans.randomize() with {
          _mode       == binary;
          _command    == nop;
          (length_data > 1) -> (_reqinc == yes);
          _arbit      == accept;
          _reqack     == no;
        } ;
        end
      finish_item(trans);
    endtask:body
  endclass:seq_4p3 

//-------------------------------------------------------------------------------------------------
//
//                                    WRITE IN COMMAND MODE
//
//-------------------------------------------------------------------------------------------------

  // 5.1 Apply UART write command with wrong prefix.
  class seq_5p1 extends uart_base_sequence;

    `uvm_object_utils(seq_5p1)

    function new (string name="seq_5p1");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == wrong_mode_bin;
        _command    == write;
        address[15:7] != 8'h00;
        (length_data > 1) -> (_reqinc == yes);
        _arbit      == accept;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_5p1

  // 5.2 Apply UART write commands to different addresses.
  class seq_5p2 extends uart_base_sequence;

    rand int unsigned num_of_comands;

    `uvm_object_utils(seq_5p2)

    function new (string name="seq_5p2");
      super.new(name);
    endfunction:new
    
    constraint num_iter {
      num_of_comands inside {[1:5]};
    }

    virtual task body ();
      randomize();
      start_item(trans);
      repeat (num_of_comands)
        begin
        trans.randomize() with {
                _mode       == binary;
                _command    == write;
                (length_data > 1) -> (_reqinc == yes);
                _arbit      == accept;
              }; 
        end
      finish_item(trans);
    endtask:body
  endclass:seq_5p2

  // 5.3 Apply UART write commands with several data lengths
  class seq_5p3 extends uart_base_sequence;

    rand int unsigned num_of_comands;

    `uvm_object_utils(seq_5p3)

    function new (string name="seq_5p3");
      super.new(name);
    endfunction:new
    
    constraint num_iter {
      num_of_comands inside {[1:5]};
    }

    virtual task body ();
      randomize();
      start_item(trans);
      repeat (num_of_comands)
        begin
        trans.randomize() with {
                _mode       == binary;
                _command    == write;
                (length_data > 1) -> (_reqinc == yes);
                _arbit      == accept;
              } ;
        end
      finish_item(trans);
    endtask:body
  endclass:seq_5p3

  // 5.4 Apply UART write command to address 0 with random data.
  class seq_5p4 extends uart_base_sequence;

    `uvm_object_utils(seq_5p4)

    function new (string name="seq_5p4");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
              _mode       == binary;
              _command    == write;
              address     == 16'b0;
              (length_data > 1) -> (_reqinc == yes);
              _arbit      == accept;
            } ;
      finish_item(trans);
    endtask:body
  endclass:seq_5p4

  // 5.5 Apply UART write command to address 0xFFFF with random data.
  class seq_5p5 extends uart_base_sequence;

    `uvm_object_utils(seq_5p5)

    function new (string name="seq_5p5");
      super.new(name);
    endfunction:new
    
    virtual task body ();
      start_item(trans);
      trans.randomize() with {
              _mode       == binary;
              _command    == write;
              address     == 16'hFFFF;
              (length_data > 1) -> (_reqinc == yes);
              _arbit      == accept;
            } ;
      finish_item(trans);
    endtask:body
  endclass:seq_5p5

  // 5.6 Apply UART write command with acknowledge request.
  class seq_5p6 extends uart_base_sequence;

    `uvm_object_utils(seq_5p6)

    function new (string name="seq_5p6");
      super.new(name);
    endfunction:new
    
    virtual task body ();
      start_item(trans);
      trans.randomize() with {
              _mode       == binary;
              _command    == write;
              (length_data > 1) -> (_reqinc == yes);
              _arbit      == accept;
              _reqack     == yes;
            } ;
      finish_item(trans);
    endtask:body
  endclass:seq_5p6

  // 5.7 Apply UART write command with non-acknowledge request.
  class seq_5p7 extends uart_base_sequence;

    `uvm_object_utils(seq_5p7)

    function new (string name="seq_5p7");
      super.new(name);
    endfunction:new
    
    virtual task body ();
      start_item(trans);
      trans.randomize() with {
              _mode       == binary;
              _command    == write;
              (length_data > 1) -> (_reqinc == yes);
              _arbit      == accept;
              _reqack     == no;
            } ;
      finish_item(trans);
    endtask:body
  endclass:seq_5p7

  // 5.8 Apply UART write command including single byte.
  class seq_5p8 extends uart_base_sequence;

    `uvm_object_utils(seq_5p8)

    function new (string name="seq_5p8");
      super.new(name);
    endfunction:new
    
    virtual task body ();
      start_item(trans);
      trans.randomize() with {
              _mode       == binary;
              _command    == write;
              length_data == 1;
              (length_data > 1) -> (_reqinc == yes);
              _arbit      == accept;
            } ;
      finish_item(trans);
    endtask:body
  endclass:seq_5p8

  // 5.9 Apply UART write command including non-incremental address bit.
  class seq_5p9 extends uart_base_sequence;

    `uvm_object_utils(seq_5p9)

    function new (string name="seq_5p9");
      super.new(name);
    endfunction:new
    
    virtual task body ();
      start_item(trans);
      trans.randomize() with {
              _mode       == binary;
              _command    == write;
              (length_data > 1) -> (_reqinc == yes);
              _arbit      == accept;
              _reqinc     == no;
            } ;
      finish_item(trans);
    endtask:body
  endclass:seq_5p9

  // 5.10 Apply UART write command including incremental address bit.
  class seq_5p10 extends uart_base_sequence;

    `uvm_object_utils(seq_5p10)

    function new (string name="seq_5p10");
      super.new(name);
    endfunction:new
    
    virtual task body ();
      start_item(trans);
      trans.randomize() with {
              _mode       == binary;
              _command    == write;
              (length_data > 1) -> (_reqinc == yes);
              _arbit      == accept;
              _reqinc     == yes;
            } ;
      finish_item(trans);
    endtask:body
  endclass:seq_5p10

//-------------------------------------------------------------------------------------------------
//
//                                    READ IN COMMAND MODE
//
//-------------------------------------------------------------------------------------------------

  // 6.1 Apply UART read command with wrong prefix.
  class seq_6p1 extends uart_base_sequence;

    `uvm_object_utils(seq_6p1)

    function new (string name="seq_6p1");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
        _mode       == wrong_mode_bin;
        _command    == read;
        address[15:7] != 8'h00;
        (length_data > 1) -> (_reqinc == yes);
        _arbit      == accept;
      } ;
      finish_item(trans);
    endtask:body
  endclass:seq_6p1

  // 6.2 Apply UART read commands to different addresses.
  class seq_6p2 extends uart_base_sequence;

    rand int unsigned num_of_comands;

    `uvm_object_utils(seq_6p2)

    function new (string name="seq_6p2");
      super.new(name);
    endfunction:new
    
    constraint num_iter {
      num_of_comands inside {[1:5]};
    }

    virtual task body ();
      randomize();
      start_item(trans);
      repeat (num_of_comands)
        begin
        trans.randomize() with {
                _mode       == binary;
                _command    == read;
                (length_data > 1) -> (_reqinc == yes);
                _arbit      == accept;
              } ;
        end
      finish_item(trans);
    endtask:body
  endclass:seq_6p2

  // 6.3 Apply UART read commands with several data lengths
  class seq_6p3 extends uart_base_sequence;

    rand int unsigned num_of_comands;

    `uvm_object_utils(seq_6p3)

    function new (string name="seq_6p3");
      super.new(name);
    endfunction:new
    
    constraint num_iter {
      num_of_comands inside {[1:5]};
    }

    virtual task body ();
      randomize();
      start_item(trans);
      repeat (num_of_comands)
        begin
        trans.randomize() with {
                _mode       == binary;
                _command    == read;
                (length_data > 1) -> (_reqinc == yes);
                _arbit      == accept;
              } ;
        end
      finish_item(trans);
    endtask:body
  endclass:seq_6p3

  // 6.4 Apply UART read command to address 0 with random data.
  class seq_6p4 extends uart_base_sequence;

    `uvm_object_utils(seq_6p4)

    function new (string name="seq_6p4");
      super.new(name);
    endfunction:new

    virtual task body ();
      start_item(trans);
      trans.randomize() with {
              _mode       == binary;
              _command    == read;
              address     == 16'b0;
              (length_data > 1) -> (_reqinc == yes);
              _arbit      == accept;
            } ;
      finish_item(trans);
    endtask:body
  endclass:seq_6p4

  // 6.5 Apply UART read command to address 0xFFFF with random data.
  class seq_6p5 extends uart_base_sequence;

    `uvm_object_utils(seq_6p5)

    function new (string name="seq_6p5");
      super.new(name);
    endfunction:new
    
    virtual task body ();
      start_item(trans);
      trans.randomize() with {
              _mode       == binary;
              _command    == read;
              address     == 16'hFFFF;
              (length_data > 1) -> (_reqinc == yes);
              _arbit      == accept;
            } ;
      finish_item(trans);
    endtask:body
  endclass:seq_6p5

  // 6.6 Apply UART read command with acknowledge request.
  class seq_6p6 extends uart_base_sequence;

    `uvm_object_utils(seq_6p6)

    function new (string name="seq_6p6");
      super.new(name);
    endfunction:new
    
    virtual task body ();
      start_item(trans);
      trans.randomize() with {
              _mode       == binary;
              _command    == read;
              (length_data > 1) -> (_reqinc == yes);
              _arbit      == accept;
              _reqack     == yes;
            } ;
      finish_item(trans);
    endtask:body
  endclass:seq_6p6

  // 6.7 Apply UART read command with non-acknowledge request.
  class seq_6p7 extends uart_base_sequence;

    `uvm_object_utils(seq_6p7)

    function new (string name="seq_6p7");
      super.new(name);
    endfunction:new
    
    virtual task body ();
      start_item(trans);
      trans.randomize() with {
              _mode       == binary;
              _command    == read;
              (length_data > 1) -> (_reqinc == yes);
              _arbit      == accept;
              _reqack     == no;
            } ;
      finish_item(trans);
    endtask:body
  endclass:seq_6p7

  // 6.8 Apply UART read command including single byte.
  class seq_6p8 extends uart_base_sequence;

    `uvm_object_utils(seq_6p8)

    function new (string name="seq_6p8");
      super.new(name);
    endfunction:new
    
    virtual task body ();
      start_item(trans);
      trans.randomize() with {
              _mode       == binary;
              _command    == read;
              length_data == 1;
              (length_data > 1) -> (_reqinc == yes);
              _arbit      == accept;
            } ;
      finish_item(trans);
    endtask:body
  endclass:seq_6p8

  // 6.9 Apply UART read command including non-incremental address bit.
  class seq_6p9 extends uart_base_sequence;

    `uvm_object_utils(seq_6p9)

    function new (string name="seq_6p9");
      super.new(name);
    endfunction:new
    
    virtual task body ();
      start_item(trans);
      trans.randomize() with {
              _mode       == binary;
              _command    == read;
              (length_data > 1) -> (_reqinc == yes);
              _arbit      == accept;
              _reqinc     == no;
            } ;
      finish_item(trans);
    endtask:body
  endclass:seq_6p9

  // 6.10 Apply UART read command including incremental address bit.
  class seq_6p10 extends uart_base_sequence;

    `uvm_object_utils(seq_6p10)

    function new (string name="seq_6p10");
      super.new(name);
    endfunction:new
    
    virtual task body ();
      start_item(trans);
      trans.randomize() with {
              _mode       == binary;
              _command    == read;
              (length_data > 1) -> (_reqinc == yes);
              _arbit      == accept;
              _reqinc     == yes;
            } ;
      finish_item(trans);
    endtask:body
  endclass:seq_6p10

//-------------------------------------------------------------------------------------------------
//
//                                     INTERNAL BUS
//
//-------------------------------------------------------------------------------------------------

  // 7.1 Apply UART read or write commands and give the UART the bus grant.
  class seq_7p1 extends uart_base_sequence;

    `uvm_object_utils(seq_7p1)

    function new (string name="seq_7p1");
      super.new(name);
    endfunction:new
    
    virtual task body ();
      start_item(trans);
      trans.randomize() with {
              _mode       == binary;
              _command    inside {write,read};
              (length_data > 1) -> (_reqinc == yes);
              _arbit      == accept;
              _reqinc     == yes;
            } ;
      finish_item(trans);
    endtask:body
  endclass:seq_7p1

  // 7.2 Apply UART read or write commands and give no agreement to access internal bus
  class seq_7p2 extends uart_base_sequence;

    `uvm_object_utils(seq_7p2)

    function new (string name="seq_7p2");
      super.new(name);
    endfunction:new
    
    virtual task body ();
      start_item(trans);
      trans.randomize() with {
              _mode       == binary;
              _command    inside {write,read};
              (length_data > 1) -> (_reqinc == yes);
              _arbit      == declain;
              _reqinc     == yes;
            } ;
      finish_item(trans);
    endtask:body
  endclass:seq_7p2

//-------------------------------------------------------------------------------------------------
//
//                                      INVALID COMMANDS
//
//-------------------------------------------------------------------------------------------------

  // 8.1 Apply Invalid UART command in form of write binary command.
  class seq_8p1 extends uart_base_sequence;

    `uvm_object_utils(seq_8p1)

    function new (string name="seq_8p1");
      super.new(name);
    endfunction:new
    
    virtual task body ();
      start_item(trans);
      trans.randomize() with {
              _mode       == binary;
              _command    == invalid_write;
              (length_data > 1) -> (_reqinc == yes);
              _arbit      == accept;
              _reqinc     == yes;
            } ;
      finish_item(trans);
    endtask:body
  endclass:seq_8p1

  // 8.2 Apply Invalid UART command in form of read binary command.
  class seq_8p2 extends uart_base_sequence;

    `uvm_object_utils(seq_8p2)

    function new (string name="seq_8p2");
      super.new(name);
    endfunction:new
    
    virtual task body ();
      start_item(trans);
      trans.randomize() with {
              _mode       == binary;
              _command    == invalid_read;
              (length_data > 1) -> (_reqinc == yes);
              _arbit      == declain;
              _reqinc     == yes;
            } ;
      finish_item(trans);
    endtask:body
  endclass:seq_8p2
