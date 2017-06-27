//-------------------------------------------------------------------------------------------------
//
//                             UART2BUS VERIFICATION
//
//-------------------------------------------------------------------------------------------------
// CREATOR    : HANY SALAH
// PROJECT    : UART2BUS UVM TEST BENCH
// UNIT       : DEFINITION LIBRARY
//-------------------------------------------------------------------------------------------------
// TITLE      : UART DEFINITION LIBRARY 
// DESCRIPTION: THIS LIBRARY INCLUDES ALL THE USER MACROSES, TIMESCALE, TRANSACTION DATA TYPES, 
//              GLOBAL FUNCTIONS AND CONFIGURATION DATA TYPES 
//-------------------------------------------------------------------------------------------------
// LOG DETAILS
//-------------
// VERSION      NAME        DATE        DESCRIPTION
//    1       HANY SALAH    25122015    FILE CREATION
//    2       HANY SALAH    31122015    ADD DATA TYPE DEFINITIONS
//    3       HANY SALAH    11012016    ADD TIMING PARAMETERS DEFINITION
//    4       HANY SALAH    18022016    IMPROVE BLOCK DESCRIPTION
//-------------------------------------------------------------------------------------------------
// ALL COPYRIGHTS ARE RESERVED FOR THE PRODUCER ONLY .THIS FILE IS PRODUCED FOR OPENCORES MEMBERS 
// ONLY AND IT IS PROHIBTED TO USE THIS MATERIAL WITHOUT THE CREATOR'S PERMISSION
//-------------------------------------------------------------------------------------------------

`timescale 1ns/1ns

//-------------------------------------------------------------------------------------------------
//
//                               Definition Identifiers
//
//-------------------------------------------------------------------------------------------------
  
  // Define high value
  `define one 1'b1

  // Define low value
  `define zero 1'b0
  
  // Define size of address line
  `define size  16

  // 2 power size
  `define mem_size 65536 

  // ASCII of 'r'
  `define r   8'h72     

  // ASCII of 'R'
  `define R   8'h52

  // ASCII of 'w'
  `define w   8'h77

  // ASCII of 'W'
  `define W   8'h57

  // BINARY COMMAND PREFIX
  `define bin_prfx 8'h0

  // Single Space
  `define space 8'h20

  // Signel Tab
  `define tab   8'h09

  // LF
  `define LF    8'h0A

  // CR
  `define CR    8'h0D

  //UNIFIED ACK
  `define ACK   8'h5A

  // work on positive edge
  `define _posedge      1

  // work on negative edge
  `define _negedge      2

  // start with MSB
  `define msb_first     1

  // start with LSB
  `define lsb_first     2

  // Text Mode Command
  `define text_mode     1

  // Binary Mode Command
  `define binary_mode   2

  // Wrong Mode text Command
  `define wrong_mode_txt 3

  // Wrong Mode bin Command
  `define wrong_mode_binry 4

  // Read Command
  `define read_comm     1

  // write Command
  `define write_comm    2

  // nop Command
  `define nop_comm      3

  // wrong Read Command
  `define wrong_comm_read 4

  // wrong Write Command
  `define wrong_comm_write 5

  // Use single white space
  `define single_space  1

  // Use multiple white space
  `define tab_space     2

  // Use wrong space character
  `define space_wrong   3

  // use cr as eol
  `define cr_eol        1

  // use lf as eol
  `define lf_eol        2

  // Use wrong eol
  `define eol_wrong     3

  // request either address increment or acknowledge
  `define _yes          1

  // don't request either address increment or acknowledge
  `define _no           2

  // Use capital Leter
  `define capital_let   1

  // Use small letter
  `define small_let     2

  // accept arbitration
  `define accept        1

  // declain arbitration
  `define declain       2

  // Binary represnetation
  `define binary_rep    1

  // ASCII Representation
  `define ascii_rep     2

  // NOP Control
  `define nop_ctrl      2'b00

  // Read Control
  `define read_ctrl     2'b01

  // Write Control
  `define write_ctrl    2'b10

  // Invalid Control
  `define invalid_ctrl  2'b11

  `define _parityoff    1

  `define _parityeven   2

  `define _parityodd    3
//-------------------------------------------------------------------------------------------------
//
//                                    Timing Defines
//
//-------------------------------------------------------------------------------------------------
  // Define stability time
  `define stab               10

  // Define the period of global clock in terms of ns
  `define glob_clk_period    25

  // Define the period of baud clock in terms of ns
  `define buad_clk_period    8680

//-------------------------------------------------------------------------------------------------
//
//                                Configuration Data Type
//
//-------------------------------------------------------------------------------------------------

  // Represents the active edge
  typedef enum {pos_edge=1,            // Based on positive edge 
                neg_edge=2} act_edge;  // Based on negative edge

  // Represent the starting bit
  typedef enum {msb=1,                 // Most Significant bit first
                lsb=2}  start_bit;     // Least Significant bit first

//-------------------------------------------------------------------------------------------------
//
//                               New Data Type Definitions
//
//-------------------------------------------------------------------------------------------------

  // Represents the mode of command to be one of the following options {text, command, wrong}. 
  // Wrong command mode is used to send a tricky fault command to test our DUT.
  typedef enum {text=1,                         // Communicate using text mode
                binary=2,                       // Communicate using command mode
                wrong_mode_text=3,              // Communicate using wrong prefix(text mode)
                wrong_mode_bin=4} mode;         // Communicate using wrong prefix(binary mode)

  // Represents the type of the used white space to be one of the following options {single, tab, 
  // wrong}. Wrong type also is used to push tricky byte in the text mode.
  typedef enum {single=1,             // Using single space as a white space
                tab=2,                // Using tab as a white space
                wrong_space=3} space_type;  // Using wrong white space

  // Represents the type of end of line used to be one of the following choices{cr, lf, wrong}.
  // Wrong type is also used to push DUT in tricky manner.
  typedef enum {cr=1,                      // Using CR as EOL
                lf=2,                      // Using LF as EOL
                wrong_eol=3} eol_type;    // Using wrong EOL

  // Represents the command either to be one of the following choices {read, write, NOP}
  typedef enum {read=1,                     // Read Command
                write=2,                    // Write Command
                nop=3,                      // Make No Operation
                invalid_read=4,             // Invalid Command with read data
                invalid_write=5} command;   // Invalid Command with write data

  // Represents both acknowledge and incremental address request{yes, no}
  typedef enum {yes=1,                // Request Acknowledge
                no=2} req;            // Request No Acknowledge

  // Represents the type of prefix in text mode either to be {capital, small}.
  typedef enum {cap=1,                // Capital Letter
                smal=2} char_type;    // Small Letter

  // Represents the internal bus state either {accept, refuse}
  typedef enum {accept=1,             // Accept Bus Grant
                declain=2} arbit;     // Refuse Bus Grant

  // Define mode of data {ascii or binary}
  typedef enum {bin=1,                // Binary Representation (data remains unchanged)
                ascii=2} data_mode;   // ASCII Representation  (each niblle is converted into 
                                      // ASCII byte)

  // Define mode of the used parity
  typedef enum {parity_off=1,                 // Don't Add Parity Field
                parity_even=2,                // Add Even Parity to fields 
                parity_odd=3}  parity_mode ;  // Add Odd Parity to fields

//-------------------------------------------------------------------------------------------------
//
//                                 GLOBAL FUNCTIONS
//
//-------------------------------------------------------------------------------------------------

  // Binary To ASCII Conversion to convert nibble into ASCII byte through the following look-up-
  // table
  function byte bin_asci_conv (bit[3:0] data);
    byte temp;
    case (data)
      4'h0:
        begin
        temp = 8'h30;
        end
      4'h1:
        begin
        temp = 8'h31;
        end
      4'h2:
        begin
        temp = 8'h32;
        end
      4'h3:
        begin
        temp = 8'h33;
        end
      4'h4:
        begin
        temp = 8'h34;
        end
      4'h5:
        begin
        temp = 8'h35;
        end
      4'h6:
        begin
        temp = 8'h36;
        end
      4'h7:
        begin
        temp = 8'h37;
        end
      4'h8:
        begin
        temp = 8'h38;
        end
      4'h9:
        begin
        temp = 8'h39;
        end
      4'hA:
        begin
        temp = 8'h41;
        end
      4'hB:
        begin
        temp = 8'h42;
        end
      4'hC:
        begin
        temp = 8'h43;
        end
      4'hD:
        begin
        temp = 8'h44;
        end
      4'hE:
        begin
        temp = 8'h45;
        end
      4'hF:
        begin
        temp = 8'h46;
        end
    endcase
    return temp;
  endfunction:bin_asci_conv

  // ASCII To Binary Conversion is to convert ASCII byte into Binary nibble through the following 
  // Look-Up-Table
  function bit [3:0] asci_bin_conv (byte data);
    bit [3:0] temp;
    case (data)
      8'h30:
        begin
        temp = 4'h0;
        end
      8'h31:
        begin
        temp = 4'h1;
        end
      8'h32:
        begin
        temp = 4'h2;
        end
      8'h33:
        begin
        temp = 4'h3;
        end
      8'h34:
        begin
        temp = 4'h4;
        end
      8'h35:
        begin
        temp = 4'h5;
        end
      8'h36:
        begin
        temp = 4'h6;
        end
      8'h37:
        begin
        temp = 4'h7;
        end
      8'h38:
        begin
        temp = 4'h8;
        end
      8'h39:
        begin
        temp = 4'h9;
        end
      8'h41:
        begin
        temp = 4'hA;
        end
      8'h42:
        begin
        temp = 4'hB;
        end
      8'h43:
        begin
        temp = 4'hC;
        end
      8'h44:
        begin
        temp = 4'hD;
        end
      8'h45:
        begin
        temp = 4'hE;
        end
      8'h46:
        begin
        temp = 4'hF;
        end
      default:
        begin
        $error("undefined ascii symbol");
        end
    endcase
    return temp;
  endfunction:asci_bin_conv
