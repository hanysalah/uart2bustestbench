//-------------------------------------------------------------------------------------------------
//
//                             UART2BUS VERIFICATION
//
//-------------------------------------------------------------------------------------------------
// CREATOR    : HANY SALAH
// PROJECT    : UART2BUS UVM TEST BENCH
// UNIT       : INTERFACE
//-------------------------------------------------------------------------------------------------
// TITLE      : UART BFM 
// DESCRIPTION: THIS FILE ACT AS UART MASTER DEVICE APPLY REQUESTS TO THE DUT ACROSS THE STANDARD
//              INTERFACES. IT ALSO INCLUDES ALL THE USER AND STANDARD ROUTINES THAT ARE NEED TO 
//              APPLY, RECEIVE AND MONITOR UART DIFFERENT ACTIVITIES. 
//-------------------------------------------------------------------------------------------------
// LOG DETAILS
//-------------
// VERSION      NAME        DATE        DESCRIPTION
//    1       HANY SALAH    25122015    FILE CREATION
//    2       HANY SALAH    07012016    ADD USER ROUTINE, TEXT MODE ROUTINES.
//    3       HANY SALAH    21012016    REPLACE PUSH BYTE WITH PUSH FIELD
//    4       HANY SALAH    31012016    ADD FAULT AND INVALID COMMAND INDICATORS
//    5       HANY SALAH    13022016    IMPROVE BLOCK DESCRIPTION & ADD COMMENTS.
//    6       HANY SALAH    15022016    ENHANCE BLOCK COMMENTS
//    7       HANY SALAH    16022016    ENHANCE BLOCK COMMENTS
//    8       HANY SALAH    17022016    FINALIZE BLOCK COMMENTS
//-------------------------------------------------------------------------------------------------
// ALL COPYRIGHTS ARE RESERVED FOR THE PRODUCER ONLY .THIS FILE IS PRODUCED FOR OPENCORES MEMBERS 
// ONLY AND IT IS PROHIBTED TO USE THIS MATERIAL WITHOUT THE CREATOR'S PERMISSION
//-------------------------------------------------------------------------------------------------
`include "defin_lib.svh"
interface uart_interface (input bit clock,        // UART Clock Signal
                          input bit reset);       // Global Asynchronous Reset Signal

//-------------------------------------------------------------------------------------------------
//
//                                       BFM PARAMETERS
//
//-------------------------------------------------------------------------------------------------
  // BFM Paramenters are the ones which are set in the test file and are propagated in the whole
  // test-bench. They are defined indetails through test file and specifications document.
  // The range of possible values for all the BFM paramters is stated beside each one
  //
  // Define the active clock edge
  int                 act_edge;     // 2: negative edge   1: positive edge
  
  // Define the first transferred bit from the byte.
  int                 start_bit;    // 2: LSB first       1: MSB first 
  
  // Define the number of stop bits of each UART field
  int                 num_stop_bits;// 2: two stop bits   1: one stop bits
  
  // Define the number of actual bits inbetween the start and stop bits.
  int                 num_bits;     // 7: seven bits data 8: eight bits data
  
  // Define the representation of data through the text mode.
  int                 data_rep;     // 2: binarry         1: ASCII
  
  // Define the parity mode used.
  int                 parity;       // 3: parity odd      2: parity even        1: parity off
  
  // Define the maximum allowable time between the UART request and the DUT response.
  time                response_time;

  // Define the authorization of false data usage.
  int                 falsedata_gen_en;

//-------------------------------------------------------------------------------------------------
//
//                                      UART SIGNLAS
//
//-------------------------------------------------------------------------------------------------

  logic               ser_in;         // Serial Data Input
  logic               ser_out;        // Serial Data Ouptut

//-------------------------------------------------------------------------------------------------
//
//                                 USER VARIABLES DECLARATIONS
//
//-------------------------------------------------------------------------------------------------

  // The user variables are those ones which facilitate the usage of BFM and they aren't mentioned
  // in the standard.
  //
  // Start_trans event is triggered by the driver at the start of each transaction. it would let
  // the other components wake up and poll the UART bus.
  // By triggereing this event, other connected components would know that some UART transaction 
  // would be forced on the UART busses.
  event start_trans;

  // The following two bits are used only in case of apply wrong modes or wrong commands as the
  // following:
  // wrong_data_ctrl is drived by the driver to state that whether the wrong applied command
  // is read or write.
  // Actuall BFM shouldn't discriminate between both of types. Its response should be nothing!!.
  // But this indication facilitates the scoreboard work.
  bit wrong_data_ctrl;           //0:read      1: write

  // wrong_mode_ctrl is also drived by the driver to state whether the wrong applied mode is
  // text or binary.
  // Actuall BFM also shouldn't discriminate between both of types. Its response should be 
  // nothing. But this indication facilitates the scoreboard work.
  bit wrong_mode_ctrl;           //0:text      1: binary

//-------------------------------------------------------------------------------------------------
//
//                                       USER ROUTINES
//
//-------------------------------------------------------------------------------------------------

  // Through This routine, the uart bfm initializes its configuration parameters described above.
  function void set_configuration ( int _edge,
                                    int first_bit,
                                    int _numstopbits,
                                    int _numbits,
                                    int _datarep,
                                    int _paritymode,
                                    time _resp,
                                    int _flse_en);
    act_edge        = _edge;
    start_bit       = first_bit;
    num_stop_bits   = _numstopbits;
    num_bits        = _numbits;
    data_rep        = _datarep;
    parity          = _paritymode;
    response_time   = _resp;
    falsedata_gen_en= _flse_en;
  endfunction: set_configuration


  // Through the following routine, the UART BFM makes an event that some transaction would be 
  // forced on UART signals
  function void set_event ();
    -> start_trans ;
  endfunction:set_event 

  // This routine is used to force data directly on serial out bus. This routine transform one
  // bit only to the form of uart. This form is defined in the definition library. 
  // High value is defined by the macro `one.
  // Low value is defined by the macro `zero.
  function void force_sout(bit x);
    case (x)
      1'b1:
        begin
        ser_out = `one;
        end
      1'b0:
        begin
        ser_out = `zero;
        end
    endcase
  endfunction:force_sout

  // Through this routine, the uart bfm push bit on the serial ouptut port ser_out based on the 
  // configured active edge field, UART will push bit on data. BFM will assign testbench error in 
  // case of un-configured active edge.
  task push_bit_serout (input bit data);
    case (act_edge)
      `_negedge:
        begin
        @(negedge clock)
          begin
          force_sout(data);
          end
        end
      `_posedge:
        begin
        @(posedge clock)
          begin
          force_sout(data);
          end
        end
      default:
        begin
        $error("Non-configured active edge");
        end
    endcase
  endtask:push_bit_serout

  // The following task will catch single bit from serial output port ser_out based on the config-
  // ured active edge field, UART will capture data bit. Based on the configured active edge, this
  // method block the execution till the correct clock edge and then make delay of a quarter of 
  // clock period to guarnttee the stability of data on the serial output port. 
  // BFM will assign testbench error in case of un-configured active edge.
  task catch_bit_serout (output bit data);
    case (act_edge)
      `_negedge:
        begin
        @(negedge clock)
          begin
          #(`buad_clk_period/4) data = ser_out;
          end
        end
      `_posedge:
        begin
        @(posedge clock)
          begin
          #(`buad_clk_period/4) data = ser_out;
          end
        end
      default:
        begin
        $error("Non-configured active edge");
        end
    endcase
  endtask:catch_bit_serout

  // The following task will catch single bit from serial input port ser_in based on the config-
  // ured active edge field, UART will capture data bit. Based on the configured active edge, this
  // method block the execution till the correct clock edge and then make delay of a quarter of 
  // clock period to guarnttee the stability of data on the serial input port. 
  // BFM will assign testbench error in case of un-configured active edge.
  task catch_bit_serin (output bit data);
    case (act_edge)
      `_negedge:
        begin
        @(negedge clock)
          begin
          #(`buad_clk_period/4) data = ser_in;
          end
        end
      `_posedge:
        begin
        @(posedge clock)
          begin
          #(`buad_clk_period/4)data = ser_in;
          end
        end
      default:
        begin
        $error("Non-configured active edge");
        end
    endcase
  endtask:catch_bit_serin

  // Through the following task, UART BFM will force data byte on serial output port based on the 
  // configured start_bit field. This mode encapsulate the data byte inbetween start,stop and even
  // parity bits. The sequence would be the following:
  // 1- Force zero bit on the serial output port as start bit.
  // 2- Send the data byte serially bit by bit.
  // 3- Accoriding to configured parity, force parity bit (optional).
  // 4- Insert one or two stop bits according to BFM configuration.
  // BFM will assign testbench error in case of un-configured parameters.
  task push_field_serout (input byte data);
    
    bit temp;

    // start bit
    push_bit_serout(1'b0);

    // data fields
    case (start_bit)
      `lsb_first:
        begin
        for (int index=0;index<8;index++)
          begin
          push_bit_serout(data[index]);
          end
        end
      `msb_first:
        begin
        for (int index=7;index>=0;index--)
          begin
          push_bit_serout(data[index]);
          end
        end
      default:
        begin
        $error("Undefined serial mode");
        end
    endcase
    // parity bits
    if(parity == `_parityeven)
      begin
      temp=1'b1;
      for (int index=0;index <8;index++)
        begin
        temp = temp ^ data [index];
        end
      end
    else if(parity == `_parityodd)
      begin
      temp=1'b0;
      for (int index=0;index <8;index++)
        begin
        temp = temp ^ data [index];
        end
      end
    else if (parity != `_parityoff)
      begin
      $error("un-configured parity");
      end
    // Stop bit(s)
    repeat (num_stop_bits)
      begin
      push_bit_serout(1'b1);
      end

  endtask:push_field_serout

  // Through the following task, UART BFM will catpure UART field from serial output port based on 
  // the configured start_bit field. The following sequence is carried out :
  // 1- Wait start bit.
  // 2- Catpure the following eight bits in packed byte depending on the configured start bit.
  // 3- Depending on the configured number of stop bits, the stop bit(s) are captured.
  //    - In case that stop bit(s) is zero, the testbench will assign testbench error.
  // BFM will assign testbench error in case of un-configured start_bit field.
  task catch_field_serout (output byte data);
    bit end_bit;

    // wait start bit
    wait(ser_out == 1'b0);
    case(start_bit)
      `lsb_first:
        begin
        for (int index=0;index<8;index++)
          begin
          catch_bit_serout(data[index]);
          end
        end
      `msb_first:
        begin
        for (int index=7;index>=0;index--)
          begin
          catch_bit_serout(data[index]);
          end
        end
      default:
        begin
        $error("Undefined serial mode");
        end
    endcase
    catch_bit_serout(end_bit);
    if(end_bit != 1'b1)
      begin
      $error("at time =%0t ,, the first end bit = %0b",$time,end_bit);
      end
    if (num_stop_bits == 2)
      begin
      catch_bit_serout(end_bit);
      if(end_bit != 1'b1)
        begin
        $error("at time =%0t ,, the first end bit = %0b",$time,end_bit);
        end
      end
  endtask:catch_field_serout

  // Through the following task, UART BFM will catpure UART field from serial input port based on 
  // the configured start_bit field. The applied sequence here differs from the one applied on
  // capture field from serial output port since wrong and unknown commands are forced to the DUT
  // on the UART interface. The DUT is supposed to make no response to such commands.
  // This routine pays concern to this issue by initiating two parallel threads at the beginning;
  // 1- The first one run in the background to wait response time and triggered some internal 
  //    event (terminate event). It also set internal bit (path_select) to zero to make an 
  // indication that no response has been made.
  // 2- The second one includes two parallel sub-threads:
  //    a- The first one wait start bit.
  //    b- The other one wait terminate event triggering.
  //    Whenever one of those sub-threads is terminated, The main thread is joined.
  // The following sequence is carried out in case that start bit is captured:
  // 1- Wait start bit.
  // 2- Catpure the following eight bits in packed byte depending on the configured start bit.
  // 3- Depending on the configured number of stop bits, the stop bit(s) are captured.
  //    - In case that stop bit(s) is zero, the testbench will assign testbench error.
  // BFM will assign testbench error in case of un-configured start_bit field.
  task catch_field_serin (output byte data);
    bit end_bit;
    bit path_select;
    event terminate;
    path_select = 1'b1;
    fork
      begin
      #response_time;
      -> terminate;
      path_select = 1'b0;
      end
    join_none

    fork
      wait (ser_in == 1'b0);
      wait (terminate);
    join_any

    if (path_select)
      begin
      #(`buad_clk_period/2);
      case(start_bit)
        `lsb_first:
          begin
          for (int index=0;index<8;index++)
            begin
            catch_bit_serin(data[index]);
            end
          end
        `msb_first:
          begin
          for (int index=7;index>=0;index--)
            begin
            catch_bit_serin(data[index]);
            end
          end
        default:
          begin
          $error("Undefined serial mode");
          end
      endcase
      catch_bit_serin(end_bit);
      if(end_bit != 1'b1)
        begin
        $error("at time =%0t ,, the first end bit = %0b",$time,end_bit);
        end
      if (num_stop_bits == 2)
        begin
        catch_bit_serin(end_bit);
        if(end_bit != 1'b1)
          begin
          $error("at time =%0t ,, the first end bit = %0b",$time,end_bit);
          end
        end
      end

  endtask:catch_field_serin

  // Through the following function, the byte is reversed in the manner where the byte is merrored
  function byte reverse_byte (byte data);
    byte tmp;
    for (int index=0;index<8;index++)
      begin
      tmp[index] = data[7-index];
      end
    return tmp;
  endfunction:reverse_byte

//-------------------------------------------------------------------------------------------------
//
//                                      UART ROUTINES
//
//-------------------------------------------------------------------------------------------------

  // This method is provided to initiate write request in UART text mode. This task is accomplis-
  // hed through the following sequence:
  // 1- The first field :(Prefix Character)
  //    Depending on whether the mode type is text or wrong text and whether the prefix is small
  //    or capital character, the BFM force the prefix field. In case of wrong text type, the init-
  //    ial field is the provided wrong_prefix input. also internal wrong_mode_ctrl bit is cleared.
  //    - In case of undefined type, testbench assign testbench error.
  //                               -----------------------   
  // 2- The second field:(White Space Character)
  //    Depending on whether the used white space type is a single space, a tab space or provided 
  //    wrong space character is forced on the serial output port. 
  //                               -----------------------
  // 3- The third field:(Data Character)
  //    - In case of the data representation is binary, the data input character is encapsulated 
  //      in UART field and forced in single field.
  //    - In case of the data representation is ASCII, the data input character is divided into 
  //      two nipples. Each one is converted to ASCII character and sent separately in UART field. 
  //      The most significant nipple is sent first.
  //                               -----------------------
  // 4- The forth field:(White Space Character)
  //    Depending on whether the used white space type is a single space, a tab space or provided 
  //    wrong space character is forced on the serial output port. 
  //                               -----------------------
  // 5- The fifth field:(Address Two-Character)
  //    - In case of the data representation is binary, the address input two-character is divided 
  //      into two characters. They are encapsulated into two successive UART fields.
  //    - In case of the data representation is ASCII, the address input two-character is divided 
  //      into four nipples. Each one is converted to ASCII character and sent separately in UART 
  //      field. The ASCII characters are sent where the most significant nipple is sent first.
  //                               -----------------------
  // 6- The sixth field:(End-Of-Line Character):
  //    Depending on whether the used EOL type is CR, LF or provided wrong space character is 
  //    forced on the serial output port. 
  //                               -----------------------
  task write_text_mode(input int _type,
                       input byte wrong_prefix,
                       input int alph,
                       input int scp_type1,
                       input byte space_wrong1,
                       input int scp_type2,
                       input byte space_wrong2,
                       input int eol,
                       input byte eol_wrong,
                       input bit [`size-1:0] address,
                       input byte data);
    // Write procedures
    // First Field
    case (_type)
      `text_mode:
        begin
        if (alph == `small_let)
          begin
          push_field_serout(`w);
          end
        else if (alph == `capital_let)
          begin
          push_field_serout(`W);
          end
        else
          $error("Testbench error .. No capitar or small letter is choosed");
        end
      `wrong_mode_txt:
        begin
        push_field_serout(wrong_prefix);
        wrong_mode_ctrl = 1'b0;
        end
      default:
        begin
        $error("Undefined communication mode ..");
        end
    endcase

    // Second Field
    if (scp_type1 == `single_space)
      begin
      push_field_serout(`space);
      end
    else if (scp_type1 == `tab_space)
      begin
      push_field_serout(`tab);
      end
    else if (scp_type1 == `space_wrong)
      begin
      push_field_serout(space_wrong1);
      end
    else
      $error("Testbench error .. No single space or multiple space is choosed");

    // third field
    case (data_rep)
      `binary_rep:
        begin
        push_field_serout(data);
        end
      `ascii_rep:
        begin
        push_field_serout(bin_asci_conv(data[7:4]));
        push_field_serout(bin_asci_conv(data[3:0]));      
        end
      default:$error("undefined data representation");
    endcase

    // forth field
    if (scp_type2 == `single_space)
      begin
      push_field_serout(`space);
      end
    else if (scp_type2 == `tab_space)
      begin
      push_field_serout(`tab);
      end
    else if (scp_type2 == `space_wrong)
      begin
      push_field_serout(space_wrong2);
      end
    else
      $error("Testbench error .. No single or multiple space is choosed");
    // fivth field
    case (data_rep)
      `binary_rep:
        begin
        push_field_serout(address[15:08]);
        push_field_serout(address[07:00]);
        end
      `ascii_rep:
        begin
        push_field_serout(bin_asci_conv(address[15:12]));
        push_field_serout(bin_asci_conv(address[11:08]));
        push_field_serout(bin_asci_conv(address[07:04]));
        push_field_serout(bin_asci_conv(address[03:00]));      
        end
      default:$error("undefined data representation");
    endcase

    // sixth Field
    if (eol == `cr_eol)
      begin
      push_field_serout(`CR);
      end
    else if (eol == `lf_eol)
      begin
      push_field_serout(`LF);
      end
    else if (eol == `eol_wrong)
      begin
      push_field_serout(eol_wrong);
      end
    else
      $error("Testbench error .. either CR or LF isn't choosed as eol");
  endtask:write_text_mode

  // This method is provided to initiate read request in UART text mode. This task is accomplis-
  // hed through the following sequence:
  // 1- The first field :(Prefix Character)
  //    Depending on whether the mode type is text or wrong text and whether the prefix is small
  //    or capital character, the BFM force the prefix field. In case of wrong text type, the init-
  //    ial field is the provided wrong_prefix input. also internal wrong_mode_ctrl bit is cleared.
  //    - In case of undefined type, testbench assign testbench error.
  //                               -----------------------   
  // 2- The second field:(White Space Character)
  //    Depending on whether the used white space type is a single space, a tab space or provided 
  //    wrong space character is forced on the serial output port. 
  //                               -----------------------
  // 3- The third field:(Address Two-Character)
  //    - In case of the data representation is binary, the address input two-character is divided 
  //      into two characters. They are encapsulated into two successive UART fields.
  //    - In case of the data representation is ASCII, the address input two-character is divided 
  //      into four nipples. Each one is converted to ASCII character and sent separately in UART 
  //      field. The ASCII characters are sent where the most significant nipple is sent first.
  //                               -----------------------
  // 4- The forth field:(End-Of-Line Character):
  //    Depending on whether the used EOL type is CR, LF or provided wrong space character is 
  //    forced on the serial output port. 
  //                               -----------------------
  // GETTING RESPONSE :
  //    Since we may have no response due to either DUT internal bug or the forced request is  
  //    wrong (wrong mode, wrong white space, wrong eol), two parallel threads are initiated; The
  //    first one is to wait for response time and the other one waits start bit on the serial 
  //    input port. Both the two threads are terminated by meeting only one of the two events.
  //    In case of the start bit is captured and according to the configured the data representa-
  //    tion.
  //    - If it is binary, the following UART field is captured and its data is considered to be
  //      the requested data.
  //    - If it is ASCII, the two successive UART fields is captured and each byte is converted to
  //      binary nipple.
  //    The following character is captured and it must be CR.
  //    The following character is captured and it must be LF. 
  //    - If the last two characters aren't as indicated above, the testbench will assign testbench
  //      error.
  //                               -----------------------
  task read_text_mode (input int _type,
                       input byte wrong_prefix,
                       input int alph,
                       input int scp_type,
                       input byte space_wrong,
                       input int eol,
                       input byte eol_wrong,
                       input bit [`size-1:0] address,
                       input byte false_data,
                       input int false_data_en);
    byte data;
    byte temp;
    byte char1,char2;
    bit miss;
    // Read Request
    // First Field
    case (_type)
      `text_mode:
        begin
        if (alph == `small_let)
          begin
          push_field_serout(`r);
          end
        else if (alph == `capital_let)
          begin
          push_field_serout(`R);
          end
        else
          $error("Testbench error .. No capitar or small letter is choosed");
        end
      `wrong_mode_txt:
        begin
        push_field_serout(wrong_prefix);
        wrong_mode_ctrl = 1'b0;
        end
      default:
        begin
        $error("Undefined communication mode ..");
        end
    endcase
    
    // Second Field
    if (scp_type == `single_space)
      begin
      push_field_serout(`space);
      end
    else if (scp_type == `tab_space)
      begin
      push_field_serout(`tab);
      end
    else if (scp_type == `space_wrong)
      begin
      push_field_serout(space_wrong);
      end
    else
      $error("Testbench error .. No single or multiple white space is choosed");

    // Third Field
    case (data_rep)
      `binary_rep:
        begin
        push_field_serout(address[15:08]);
        push_field_serout(address[07:00]);
        end
      `ascii_rep:
        begin
        push_field_serout(bin_asci_conv(address[15:12]));
        push_field_serout(bin_asci_conv(address[11:08]));
        push_field_serout(bin_asci_conv(address[07:04]));
        push_field_serout(bin_asci_conv(address[03:00]));
        end
      default:$error("undefined data representation");
    endcase

    // Forth Field
    if (eol == `cr_eol)
      begin
      push_field_serout(`CR);
      end
    else if (eol == `lf_eol)
      begin
      push_field_serout(`LF);
      end
    else if (eol == `eol_wrong)
      begin
      push_field_serout(eol_wrong);
      end
    else
      $error("Testbench error .. No CR or LF is choosed");

    miss = 1'b0;       
    fork
      begin: miss_response_thread
      # response_time;
      disable capture_response_thread;
      miss = 1'b1;
      end

      begin: capture_response_thread
      wait(ser_in == 1'b0);
      disable miss_response_thread;
      end
    join
    // Capture Response
    if (miss == 1'b0)
      begin
      if (false_data_en ==`_yes && falsedata_gen_en == `_yes)
        begin
        fork
        push_field_serout(false_data);
        join_none
        end
      case (data_rep)
        `binary_rep:
          begin
          catch_field_serin(data);
          end
        `ascii_rep:
          begin
          catch_field_serin(temp);
          data[7:4] = asci_bin_conv(temp);
          catch_field_serin(temp);
          data[3:0] = asci_bin_conv(temp);
          end
        default:
          begin
          $error("Undefined data representation");
          $stop;
          end
      endcase      
      catch_field_serin(char1);
      catch_field_serin(char2);
      if (char1 != `CR || char2 != `LF)
        begin
        $error("EOL is refuesed");
        end
      end
  endtask:read_text_mode

  // This method is provided to initiate write request in UART binary mode. This task is accompli-
  // shed through the following sequence:
  //                               -----------------------
  //          NOTE :: ALL THE FOLLOWING BYTES ARE ENCAPSULATED INTO DEFINED UART FIELD FORM
  //                               -----------------------   
  // 1- The first byte :(Prefix byte)
  //    Depending on whether the mode type is binary or wrong binary the BFM force the prefix field
  //    In case of wrong binary type, the initial field is the provided wrong_prefix input. also 
  //    internal wrong_mode_ctrl bit is set.
  //    - In case of undefined type, testbench assign testbench error.
  //                               -----------------------   
  // 2- The second byte:(Command byte)
  //    Depending on whether the command is valid or invalid command, the two bits of the command
  //    are assigned. Also the auto increment bit and acknowledge request bit are assigned 
  //                               -----------------------
  // 3- The third byte:(Address highest byte)
  //    - The address bits [15:08] .
  //                               -----------------------
  // 4- The forth field:(Address lowest byte)
  //    - The address bits [07:00] .
  //                               -----------------------
  // 5- The fifth field:(Length Of Data byte)
  //    - The number of data bytes inclosed into this stimulus.
  //                               -----------------------
  // 6- The rest fields:(Data):
  //    Data Bytes are sent one by one.
  //                               -----------------------
  // GETTING RESPONSE:
  //    In case that the command includes acknowledge request, UART BFM will wait for the ackno-
  //    wledge unified character. 
  //                               -----------------------
  task automatic write_binary_mode (input int _type,
                                    input byte wrong_prefix,
                                    input int command,
                                    input int reqack,
                                    input int reqinc,
                                    input int unsigned data_length,
                                    input bit [`size-1:0] address,
                                    ref byte data []);
    byte tmp;
    int unsigned index;

    // first byte : binary prefix
    case(_type)
    `binary_mode:
      begin
      push_field_serout(`bin_prfx);
      end
    `wrong_mode_binry:
      begin
      push_field_serout(wrong_prefix);
      wrong_mode_ctrl = 1'b1;
      end
    default:
      begin
      $error("Undefined Communication Mode");
      end
    endcase

    // second byte : command
    case(command)
      `write_comm:
        begin
        tmp[5:4] = `write_ctrl;    
        end
      `wrong_comm_write:
        begin
        tmp[5:4] = `invalid_ctrl;
        wrong_data_ctrl = 1'b1;
        end
      default:
        begin
        $error("Undefined Command");
        end
    endcase
    tmp[5:4] = 2'b10;
    if(reqinc==`_yes)
      begin
      tmp[1] = 1'b0;
      end
    else if (reqinc == `_no)
      begin
      tmp[1] = 1'b1;
      end
    else
      begin
      $error("undefined increment request");
      end

    if(reqack==`_yes)
      begin
      tmp[0] = 1'b1;
      end
    else if (reqack == `_no)
      begin
      tmp[0] = 1'b0;
      end
    else
      begin
      $error("undefined acknowledge request");
      end
    push_field_serout(tmp);

    // Third byte : higher byte of address
    push_field_serout(address[15:08]);

    // Forth byte : Lower byte of address
    push_field_serout(address[07:00]);

    // Fifth byte : data length
    push_field_serout(data_length);

    index = 0;
    while(index<data_length)
      begin
      push_field_serout(data[index]);
      index++;
      end

    if (reqack == `_yes)
      begin
      catch_field_serin(tmp);
      if (tmp != `ACK)
        begin
        $error("The captured acknowledge isn't as unified character");
        end
      end
  endtask:write_binary_mode

  // This method is provided to initiate read request in UART binary mode. This task is accompli-
  // shed through the following sequence:
  //                               -----------------------
  //          NOTE :: ALL THE FOLLOWING BYTES ARE ENCAPSULATED INTO UART DEFINED FIELD FORM
  //                               -----------------------   
  // 1- The first byte :(Prefix byte)
  //    Depending on whether the mode type is binary or wrong binary the BFM force the prefix field
  //    In case of wrong binary type, the initial field is the provided wrong_prefix input. also 
  //    internal wrong_mode_ctrl bit is set.
  //    - In case of undefined type, testbench assign testbench error.
  //                               -----------------------   
  // 2- The second byte:(Command byte)
  //    Depending on whether the command is valid or invalid command, the two bits of the command
  //    are assigned. Also the auto increment bit and acknowledge request bit are assigned 
  //                               -----------------------
  // 3- The third byte:(Address highest byte)
  //    - The address bits [15:08] .
  //                               -----------------------
  // 4- The forth field:(Address lowest byte)
  //    - The address bits [07:00] .
  //                               -----------------------
  // 5- The fifth field:(Length Of Data byte)
  //    - The number of data bytes inclosed into this stimulus.
  //                               -----------------------
  // GETTING RESPONSE:
  //    Through this field, three independent parallel processes are carried out :
  //    i- The first one is mendatory and is responsible for capturing the UART fields drived by
  //       The DUT on the serial input port. Also it is responsible for capturing the acknowledge
  //       byte in case that the command include acknowledge request.
  //   ii- The second one is responsible for terminating this routine in case that no response has
  //       been driven by the DUT within the response time.
  //  iii- The last one is to drive dummy UART fields. It is used only when both the internal 
  //       false data enable and the global false data enable are set. Refer to UART testbench 
  //       specifications document for more details.
  //                               -----------------------
  task automatic read_binary_mode  (input int _type,
                                    input byte wrong_prefix,
                                    input int _command,
                                    input int reqack,
                                    input int reqinc,
                                    input int unsigned data_length,
                                    input bit [`size-1:0] address,
                                    ref byte data [],
                                    ref byte false_data [],
                                    input bit false_data_en);
    byte tmp;
    int unsigned index;
    int unsigned index_false;

    // first byte : binary prefix
    case (_type)
      `binary_mode:
        begin
        push_field_serout(`bin_prfx);
        end
      `wrong_mode_binry:
        begin
        push_field_serout(wrong_prefix);
        wrong_mode_ctrl = 1'b1;
        end
      default:
        begin
        $error("Undefined Communication Mode");
        end
    endcase

    // second byte : command
    case (_command)
      `read_comm:
        begin
        tmp[5:4] = `read_ctrl;
        end
      `wrong_comm_read:
        begin
        tmp[5:4] = `invalid_ctrl;
        wrong_data_ctrl = 1'b0;
        end
      default:
        begin
        $error("Undefined Command type");
        end
    endcase

    if(reqinc==`_yes)
      begin
      tmp[1] = 1'b0;
      end
    else if (reqinc == `_no)
      begin
      tmp[1] = 1'b1;
      end
    else
      begin
      $error("undefined increment request");
      end

    if(reqack==`_yes)
      begin
      tmp[0] = 1'b1;
      end
    else if (reqack == `_no)
      begin
      tmp[0] = 1'b0;
      end
    else
      begin  
      $error("undefined acknowledge request");
      end
    push_field_serout(tmp);

    // Third byte : higher byte of address
    push_field_serout(address[15:08]);

    // Forth byte : Lower byte of address
    push_field_serout(address[07:00]);

    // Fifth byte : data length
    if (data_length == 256)
      begin
      tmp = 8'b00;
      end
    else
      begin
      tmp = data_length;
      end
    push_field_serout(tmp);

    index = 0;

    fork
      if(false_data_en == `_yes && falsedata_gen_en == `_yes)
        begin
        while(index_false<data_length)
          begin
          push_field_serout(false_data[index_false]);
          index_false++;
          end
        end
      while(index<data_length)
        begin
        catch_field_serin(data[index]);
        index++;
        end
    join  
    if (reqack == `_yes)
      begin
      catch_field_serin(tmp);
      if (tmp != `ACK && _type == `binary_mode && _command == `read_comm)
        begin
        $error("The captured acknowledge isn't as unified character");
        end
      end
  endtask:read_binary_mode

  // This method is provided to initiate NOP command in UART binary mode. This task is accompli-
  // shed through the following sequence:
  //                               -----------------------
  //          NOTE :: ALL THE FOLLOWING BYTES ARE ENCAPSULATED INTO UART DEFINED FIELD FORM
  //                               -----------------------   
  // 1- The first byte :(Prefix byte)
  //    Depending on whether the mode type is binary or wrong binary the BFM force the prefix field
  //    In case of wrong binary type, the initial field is the provided wrong_prefix input. also 
  //    internal wrong_mode_ctrl bit is set.
  //    - In case of undefined type, testbench assign testbench error.
  //                               -----------------------   
  // 2- The second byte:(Command byte)
  //    The two bits of commads are assigned. Also the auto increment bit and acknowledge request 
  //    bit are assigned 
  //                               -----------------------
  // GETTING RESPONSE:
  //    In case that the command includes acknowledge request, UART BFM will wait for the ackno-
  //    wledge unified character. 
  //                               -----------------------
  task nop_command (input int _type,
                    input byte wrong_prefix,
                    input int reqack,
                    input int reqinc);
    byte tmp;
    int unsigned index;
    // first byte : prefix
    wrong_mode_ctrl = 1'b0;
    // first byte : binary prefix
    case (_type)
      `binary_mode:
        begin
        push_field_serout(`bin_prfx);
        end
      `wrong_mode_binry:
        begin
        push_field_serout(wrong_prefix);
        wrong_mode_ctrl = 1'b1;
        end
      default:
        begin
        $error("Undefined Communication Mode");
        end
    endcase

    // second byte :  command
    tmp[5:4] = 2'b00;
    if(reqinc==`_yes)
      begin
      tmp[1] = 1'b0;
      end
    else if (reqinc == `_no)
      begin
      tmp[1] = 1'b1;
      end
    else
      begin
      $error("undefined increment request");
      end

    if(reqack==`_yes)
      begin
      tmp[0] = 1'b1;
      end
    else if (reqack == `_no)
      begin
      tmp[0] = 1'b0;
      end
    else
      begin
      $error("undefined acknowledge request");
      end
    push_field_serout(tmp);

    if(reqack==`_yes)
      begin
      catch_field_serin(tmp);
      if(tmp!=`ACK)
        begin
        $error("Undefined acknowledge character");
        end
      end
  endtask:nop_command

  // This task is used to make the bus idle for time (idle).
  task wait_idle_time (time idle);
    force_sout(1'b1);
    #idle;
  endtask: wait_idle_time

//-------------------------------------------------------------------------------------------------
//
//                                     MONITOR ROUTINES
//
//-------------------------------------------------------------------------------------------------
  // This section of routines is used to monitor the UART signals and capture all the informations
  // about the stimulus, DUT state and DUT response as well. Each one is described in details below
  //  
  // This routine is used to wait for transaction start. It waits for start_trans triggering.
  task wait_event();
    wait (start_trans);
  endtask:wait_event

  // This method is the main method of the monitoring routines used to capture the UART 
  // transactions on the UART interfaces. Whenever it is called, it carries out the following 
  // procedures:
  // 1- Capture the first field loaded on the serial output port and detect the command type to be
  //    either text read, text write, binary, wrong command. And according to the command, another 
  //    proper task will be called.
  // NOTE: In case of wrong command, with the aid of internal bit wrong_mode_ctrl, UART BFM could 
  //       detect the actual type of wrong command.
  //                               -----------------------
  // 2- (I) In case that the command type is text, the dynamic array of data is initialized with 
  //        the standard size one byte. Also command and character type fields are assigned. Refer 
  //        to transaction fields for more informations about these fields.
  //   (II) In case that the command type is binary, capture_binary_command task is called.
  //  (III) In case that the command type is wrong, nothing is done.
  task automatic capture_command (output int command_type,
                                  output int _command,
                                  output int _chartype,
                                  output int _spacetype1,
                                  output int space_wrong1,
                                  output int _spacetype2,
                                  output int space_wrong2,
                                  output int _eoltype,
                                  output int eol_wrong,
                                  output bit [`size-1:0] address,
                                  ref byte data [],
                                  output byte acknowledge,
                                  output int unsigned data_length,
                                  output int _reqack,
                                  output int _reqinc);

    byte temp;
    byte read_byte;
    catch_field_serout(read_byte);
    case (read_byte)
      `w:
        begin
        command_type  = `text_mode;
        _command      = `write_comm;
        _chartype     = `small_let;
        data = new [1];
        capture_text_write_command(_spacetype1,
                                   space_wrong1,
                                   _spacetype2,
                                   space_wrong2,
                                   _eoltype,
                                   eol_wrong,
                                   address,
                                   data[0]);
        end
      `W:
        begin
        command_type  = `text_mode;
        _command      = `write_comm;
        _chartype     = `capital_let;
        data = new [1];
        capture_text_write_command(_spacetype1,
                                   space_wrong1,
                                   _spacetype2,
                                   space_wrong2,
                                   _eoltype,
                                   eol_wrong,
                                   address,
                                   data[0]);
        end
      `r:
        begin
        command_type  = `text_mode;
        _command      = `read_comm;
        _chartype     = `small_let;
        data = new [1];
        capture_text_read_command(_spacetype1,
                                  space_wrong1,
                                  _eoltype,
                                  eol_wrong,
                                  address,
                                  data [0]);
        end
      `R:
        begin
        command_type  = `text_mode;
        _command      = `read_comm;
        _chartype     = `capital_let;
        data = new [1];
        capture_text_read_command(_spacetype1,
                                  space_wrong1,
                                  _eoltype,
                                  eol_wrong,
                                  address,
                                  data [0]);
        end
      `bin_prfx:
        begin
        command_type  = `binary_mode;
        capture_binary_command(_command,
                               _reqack,
                               _reqinc,
                               address,
                               data_length,
                               data,
                               acknowledge);
        end
      default:
        begin
        if (wrong_mode_ctrl)
          begin
          command_type  = `wrong_mode_binry;
          end
        else
          begin
          command_type  = `wrong_mode_txt;
          end
        end
    endcase
  endtask:capture_command

  // This method is used to capture read command in text mode. Whenever it is called, the following
  // procedures are carried out :
  //                               -----------------------
  // 1- Capture the second command field which includes the white space character.
  //                               -----------------------
  // 2- According to the configured data representation:
  //    i- Binary representation: Catch the following two UART fields on the serial output port 
  //                              which include the current stimulus address.
  //   ii- ASCII representation: Catch the following four UART fields on the serial output port
  //                             which include the current stimulus address in ASCII format.their 
  //                             data bytes are converted to binary format.
  //                               -----------------------
  // 3- Capture the following field which includes the end of line character.
  //                               -----------------------
  // GETTING RESPONSE: 
  //  - Run two concurrent threads:
  //    i- The first one is to wait response time.
  //   ii- The second one is to capture the data UART fields on the serial input port.
  //  - In case that no response is found, this task is terminated.
  //  - After catch the data fields, the next two fields are also captured to check the two end
  //    of line characters.
  //                               -----------------------
  task capture_text_read_command (output int _spacetype,
                                  output int space_wrong,
                                  output int _eoltype,
                                  output int eol_wrong,
                                  output bit [`size-1:0] address,
                                  output byte data);
    byte read_byte;
    bit miss;

    catch_field_serout(read_byte);
    case (read_byte)
      `space:
        begin
        _spacetype  = `single_space;
        end
      `tab:
        begin
        _spacetype  = `tab_space;
        end
      default:
        begin
        _spacetype  = `space_wrong;
        space_wrong = read_byte;
        end
    endcase

    case(data_rep)
      `binary_rep:
        begin
        catch_field_serout(read_byte);
        address[15:08] = read_byte;
        catch_field_serout(read_byte);
        address[07:00] = read_byte;
        end
      `ascii_rep:
        begin
        catch_field_serout(read_byte);
        address[15:12] = asci_bin_conv(read_byte);
        catch_field_serout(read_byte);
        address[11:08] = asci_bin_conv(read_byte);
        catch_field_serout(read_byte);
        address[07:04] = asci_bin_conv(read_byte);
        catch_field_serout(read_byte);
        address[03:00] = asci_bin_conv(read_byte);
        end
      default:
        begin
        $error("undefined data representation");
        $stop;
        end
    endcase

    catch_field_serout(read_byte);
    case(read_byte)
      `CR:
        begin
        _eoltype    = `cr_eol;
        end
      `LF:
        begin
        _eoltype    = `lf_eol;
        end
      default:
        begin
        _eoltype    = `eol_wrong;
        eol_wrong   = read_byte;
        end
    endcase

    miss = 1'b0;
    fork
      begin: miss_response_thread
      #response_time;
      disable capture_response_thread;
      miss = 1'b1;
      end

      begin: capture_response_thread
      wait(ser_in == 1'b0);
      disable miss_response_thread;
      end
    join

    if (miss==1'b0)
      begin
      case(data_rep)
        `binary_rep:
          begin
          catch_field_serin(read_byte);
          data = read_byte;
          end
        `ascii_rep:
          begin
          catch_field_serin(read_byte);
          data[7:4] = asci_bin_conv(read_byte);
          catch_field_serin(read_byte);
          data[3:0] = asci_bin_conv(read_byte);
          end
        default:
          begin
          $error("undefined data representation");
          $stop;
          end
      endcase

      catch_field_serin(read_byte);
      if (read_byte == `CR)
        begin
        catch_field_serin(read_byte);
        if (read_byte != `LF)
          begin
          $error("the catpured byte isn't LF");
          end
        end
      else if (read_byte == `LF)
        begin
        $error("The captured byte is LF instead of CR");
        end
      else
        begin
        $error("Fatal Error : final character in read request isn't CR and LF");
        end
      end    

  endtask:capture_text_read_command

  // This method is used to capture write command in text mode. Whenever it is called, the follo-
  // wing procedures are carried out :
  //                               -----------------------
  // 1- Capture the second command field which includes the white space character.
  //                               -----------------------
  // 2- According to the configured data representation:
  //    i- Binary representation: Catch the following UART field on the serial output port 
  //                              which includes the current stimulus data.
  //   ii- ASCII representation: Catch the following two UART fields on the serial output port
  //                             which include the current stimulus data in ASCII format.their 
  //                             data bytes are converted to binary format.
  //                               -----------------------
  // 3- Capture the next field which includes the white space character.
  //                               -----------------------
  // 4- According to the configured data representation:
  //    i- Binary representation: Catch the following two UART fields on the serial output port 
  //                              which include the current stimulus address.
  //   ii- ASCII representation: Catch the following four UART fields on the serial output port
  //                             which include the current stimulus address in ASCII format.their 
  //                             data bytes are converted to binary format.
  //                               -----------------------
  // 3- Capture the following field which includes the end of line character.
  //                               -----------------------

  task capture_text_write_command ( output int _spacetype1,
                                    output int space_wrong1,
                                    output int _spacetype2,
                                    output int space_wrong2,
                                    output int _eoltype,
                                    output int eol_wrong,
                                    output bit [`size-1:0] address,
                                    output byte data);

    byte read_byte;
    catch_field_serout(read_byte);
    case (read_byte)
      `space:
        begin
        _spacetype1  = `single_space;
        end
      `tab:
        begin
        _spacetype1  = `tab_space;
        end
      default:
        begin
        _spacetype1  = `space_wrong;
        space_wrong1 = read_byte;
        end
    endcase

    case(data_rep)
      `binary_rep:
        begin
        catch_field_serout(read_byte);
        data = read_byte;
        end
      `ascii_rep:
        begin
        catch_field_serout(read_byte);
        data[7:4] = asci_bin_conv(read_byte);
        catch_field_serout(read_byte);
        data[3:0] = asci_bin_conv(read_byte);
        end
      default:
        begin
        $error("undefined data representation");
        $stop;
        end
    endcase

    catch_field_serout(read_byte);
    case (read_byte)
      `space:
        begin
        _spacetype2  = `single_space;
        end
      `tab:
        begin
        _spacetype2  = `tab_space;
        end
      default:
        begin
        _spacetype2  = `space_wrong;
        space_wrong2 = read_byte;
        end
    endcase

    case(data_rep)
      `binary_rep:
        begin
        catch_field_serout(read_byte);
        address[15:08] = read_byte;
        catch_field_serout(read_byte);
        address[07:00] = read_byte;
        end
      `ascii_rep:
        begin
        catch_field_serout(read_byte);
        address[15:12] = asci_bin_conv(read_byte);
        catch_field_serout(read_byte);
        address[11:08] = asci_bin_conv(read_byte);
        catch_field_serout(read_byte);
        address[07:04] = asci_bin_conv(read_byte);
        catch_field_serout(read_byte);
        address[03:00] = asci_bin_conv(read_byte);
        end
      default:
        begin
        $error("Undefined data representation");
        $stop;
        end
    endcase

    catch_field_serout(read_byte);
    case(read_byte)
      `CR:
        begin
        _eoltype    = `cr_eol;
        end
      `LF:
        begin
        _eoltype    = `lf_eol;
        end
      default:
        begin
        _eoltype    = `eol_wrong;
        eol_wrong   = read_byte;
        end
    endcase
  endtask: capture_text_write_command

  // This method is used to capture binary mode command. Whenever it is called, the following
  // procedures are carried out :
  //                               -----------------------
  // 1- Capture and decode the second command field which includes the command, the acknowledge
  //    request and also the address auto-increment enable.
  //  - In case that the command bits indicate invalid command, BFM uses wrond_data_ctrl internal
  //    bit to know wether this stimulus is wrong read or wrong write. No response should be driven
  //    by the DUT in the both cases. But we need to discriminte between the two cases to facili- 
  //    tates the scoreboard job.
  //                               -----------------------
  // 2- Capture the following field which includes the higher byte of the command address.
  //                               -----------------------
  // 3- Capture the following field which includes the lower byte of the command address.
  //                               -----------------------
  // 4- Capture the next field which includes the number of data bytes.
  //                               -----------------------
  // 5- According to the decoded command:
  //    i- Read Command   : Poll the serial input port and capture number of successive UART fields
  //                        equal to the number of data bytes. In case of acknowledge request, ano-
  //                        ther field is captured and compared to the standard acknowledge 
  //                        character
  //
  //   ii- Write Command  : Poll the serial output port and capture number of successive UART fie- 
  //                        lds equal to the number of data bytes. In case of acknowledge request,
  //                        another field is captured on the serial input port and compare to the 
  //                        standard acknowledge character
  //
  //  iii- NOP Command    : In case of acknowledge request, another field is captured on the serial
  //                        input port and compared to the standard acknowledge character
  //
  //  iv- Invalid Command : In case that it is wrong read command, the same sequence obligied at
  //                        the valid read command is carried out.
  //                        In case that it is wrond write command, the same sequence obligied at
  //                        the valid write command is carried out.
  //                               -----------------------
  // NOTE: Since the number of data bytes is defined at the run-time, we use queue of bytes to 
  //       packetaize the data temporarily and re-assign it to the dynamic array of data.
  //                               -----------------------  
  task automatic capture_binary_command (output int _command,
                                         output int _reqack,
                                         output int _reqinc,
                                         output bit [15:0] address,
                                         output int data_length,
                                         ref byte data [],
                                         output byte acknowledge);
    byte read_byte;
    int index;
    byte que [$];
    
    // first byte
    catch_field_serout(read_byte);
    case(read_byte[5:4])
      `nop_ctrl:
        begin
        _command = `nop_comm;
        end
      `read_ctrl:
        begin
        _command = `read_comm;
        end
      `write_ctrl:
        begin
        _command = `write_comm;
        end
      `invalid_ctrl:
        begin
        if(wrong_data_ctrl)
          begin
          _command = `wrong_comm_write;
          end
        else
          begin
          _command = `wrong_comm_read;
          end
        end
      default:
        begin
        $error("invalid Command");
        end
    endcase
    
    if (read_byte[1])
      begin
      _reqinc = `_no;
      end
    else
      begin
      _reqinc = `_yes;
      end
    if (read_byte[0])
      begin
      _reqack = `_yes;
      end
    else
      begin
      _reqack = `_no;
      end
      if (_command != `nop_comm)
        begin
        catch_field_serout(read_byte);
        address[15:08] = read_byte;

        catch_field_serout(read_byte);
        address[07:00] = read_byte;

        catch_field_serout(read_byte);
        if (read_byte == 8'h00)
          begin
          data_length = 256;
          end
        else
          begin
          data_length = read_byte;
          end

        que.delete();
        if (_command == `read_comm || _command == `wrong_comm_read)
          begin
          index=0;
          while(index < data_length)
            begin
            catch_field_serin(read_byte);
            que.push_back(read_byte);
            index++;
            end
          end
        else if (_command == `write_comm || _command == `wrong_comm_write)
          begin
          index=0;
          while(index < data_length)
            begin
            catch_field_serout(read_byte);
            que.push_back(read_byte);
            index++;
            end
          end
        data = new [que.size];
        data = que;
        end
    if(_reqack == `_yes)
      begin
      catch_field_serin(acknowledge);
      end
  endtask:capture_binary_command

 endinterface:uart_interface