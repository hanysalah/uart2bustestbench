//-------------------------------------------------------------------------------------------------
//
//
//                             UART2BUS VERIFICATION
//
//
//-------------------------------------------------------------------------------------------------
// CREATOR    : HANY SALAH
// PROJECT    : UART2BUS UVM TEST BENCH
// UNIT       : INTERFACE
//-------------------------------------------------------------------------------------------------
// TITLE      : REGISTER FILE BFM 
// DESCRIPTION: THIS BUS FUNCTIONAL MODEL (BFM) ACTS AS ACTUAL REGISTER FILE CONNECTED TO THE DUT
//              ACROSS THE NON-STANDARD INTERFACE. IT IS IMPLEMENTED IN THE MANNER THAT APPLY THE
//              COMMUNICATION PROTOCOL DESCRIPED IN THE DUT MICROARCHITECTURE SPECIFICATIONS
//-------------------------------------------------------------------------------------------------
// LOG DETAILS
//-------------
// VERSION      NAME        DATE        DESCRIPTION
//    1       HANY SALAH    25122015    FILE CREATION
//    2       HANY SALAH    20012016    ADD READ BLOCK ROUTINE
//    3       HANY SALAH    11022016    IMPROVE BLOCK DESCRIPTION & ADD BLOCK COMMENTS
//-------------------------------------------------------------------------------------------------
// ALL COPYRIGHTS ARE RESERVED FOR THE PRODUCER ONLY .THIS FILE IS PRODUCED FOR OPENCORES MEMBERS 
// ONLY AND IT IS PROHIBTED TO USE THIS MATERIAL WITHOUT THE CREATOR'S PERMISSION
//-------------------------------------------------------------------------------------------------
`include "defin_lib.svh"
interface rf_interface (input bit clock,        // Global Clock Signal
                        input bit reset);       // Global Asynchronous Reset Signal



//-------------------------------------------------------------------------------------------------
//
//                                   Register File Side Signals
//
//-------------------------------------------------------------------------------------------------

  logic [15:0]   int_address;         // Address Bus To Register File
  
  logic [7:0]         int_wr_data;    // Write Data To Register File
  logic               int_write;      // Write Contorl To Register File

  logic [7:0]         int_rd_data;    // Read Data From Register File
  logic               int_read;       // Read Control To Register File

//-------------------------------------------------------------------------------------------------
//
//                                    CONTROL SIGNALS
//  
//-------------------------------------------------------------------------------------------------

  // This output is set when the testbench gives the bus access to the UART DUT
  logic               int_gnt;

  // This input is activated whenever the UART DUT request to grant the bus access
  logic               int_req;

//-------------------------------------------------------------------------------------------------
//
//                                     Internal Variables
//
//-------------------------------------------------------------------------------------------------

  // Memory of 64K bytes as Register File
  byte       register_file [`mem_size-1:0];

//-------------------------------------------------------------------------------------------------
//
//                                      Operation Blocks
//
//-------------------------------------------------------------------------------------------------
  
  // This is the main operation always block that responds to the asynchronous reset. Every clock
  // positive edge, it check for both int_read & int_write inputs. if the int_write is activated,
  // it store the data forced on the int_wr_data into the memory location defined by the address
  // applied on the int_address port. if the int_read is activated, it load the data stored in the
  // memory location defined by the address applied on the int_address port.
  // It's forbidden to assert both the int_write & int_read signal in the same time.
  always
    begin
    @(posedge clock or posedge reset);
      begin
      if (reset)
        begin
        reset_mem();
        end
      else if (int_write)
        begin
        fill_byte(int_address,int_wr_data);
        end
      else if (int_read)
        begin
        int_rd_data = read_mem_data(int_address);
        end
      end    
    end

//-------------------------------------------------------------------------------------------------
//
//                                    Non Standard Routines
//
//-------------------------------------------------------------------------------------------------

  // fill_byte routine is a function that fill only a single byte in the register file defined by
  // the input address with the single byte identified by data.
  function void fill_byte (bit [`size-1:0] address,
                           byte            data);
    register_file[address] = data;
  endfunction:fill_byte
  
  // fill_block routine is a function that fill continuous block of locations in the register file.
  // The starting address identified by the address input and the data is defined by the dynamic
  // array data with length equal to block_length input.
  // In case that the block of memory locations includes the top memory location which meant that 
  // the memory pointer(address) will reach its highest possible value and roll to zero. The imp-
  // lemented function has put this point in the concern 
  function automatic void fill_block(bit [`size-1:0] address,
                                     ref byte data [],
                                     int unsigned block_length);

      for (int unsigned index = 0; index < block_length; index++)
        begin
        // in case that the memory pointer has rolled over. the new address will be calculated from
        // the following relationship
        // The new address = the actual address - the whole memory size.
        if(address+index > `mem_size-1)
          begin
          register_file[address+index-`mem_size] = data [index];
          end
        else
          begin
          register_file[address+index] = data [index];
          end
        end
  endfunction:fill_block

  // reset_mem routine is a function that fill reset the register file contents to zero
  function void reset_mem();
    for (int unsigned index = 0; index < `mem_size; index++)
      begin
      register_file[index] = 8'b0;
      end
  endfunction:reset_mem

  // read_mem_data routine is a function that load bus with the data content
  function byte read_mem_data(bit [`size-1:0] address);
    return register_file[address];
  endfunction: read_mem_data

  // This routine read adjacent block of memory location into dynamic array of data and the
  // starting address defined by the address input.
  // The point of memory pointer rolling over has been put in the consideration <described above>
  task automatic read_block(input int unsigned data_length,
                            input bit [15:0] address,
                            ref byte data []);
    data = new [data_length];
    for (int unsigned index=0;index<data_length;index++)
      begin
      if (address+index > `mem_size-1)
        begin
        data[index] = read_mem_data(address+index-`mem_size);
        end
      else
        begin
        data[index] = read_mem_data(address+index);
        end
      end
  endtask:read_block 

//-------------------------------------------------------------------------------------------------
//
//                                        MONITOR ROUTINES
//
//-------------------------------------------------------------------------------------------------
  
  // This routine capture both the data and the address of the current transaction across the non-
  // standard interface side.
  // When it is called, it is blocked till the raising edge of int_gnt input. And during the high
  // level of int_gnt input. This routine samples both int_read and int_write inputs every positive
  // edge of the clock signal. If int_read is active, it realizes that the current transaction is
  // read and sample the int_rd_data bus at the current clock tick.
  // If the int_write is active, it realizes that the current transaction is write and sample the
  // int_wr_data bus at the current clock tick.
  // Note : - The transaction address is the address of the first affected memory location.
  //        - It's obvious that one of the signals int_read or int_write at least should be active
  //          when the int_gnt is active. which is implemented through the error alarm below.
  task automatic capture_transaction (output bit [`size-1:0] address,
                                      ref byte data [],
                                      output int unsigned data_length);
    int unsigned index;
    index = 0;
    @(posedge int_gnt);
    while (int_gnt)
      begin
      @(posedge clock);
      if(index == 0)
        begin
        address = int_address;
        end
      if(int_read)
        begin
        data [index] = int_rd_data;
        end
      else if (int_write)
        begin
        data [index] = int_wr_data;
        end
      else
        begin
        $error("Both int_read and int_write is inactive while int_gnt is active");
        end
      index++;
      data_length = index;
      end
  endtask:capture_transaction
endinterface:rf_interface