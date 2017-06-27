//-------------------------------------------------------------------------------------------------
//
//				                             UART2BUS VERIFICATION
//
//-------------------------------------------------------------------------------------------------
// CREATOR    : HANY SALAH
// PROJECT    : UART2BUS UVM TEST BENCH
// UNIT       : ANALYSIS
//-------------------------------------------------------------------------------------------------
// TITLE      : UART SCOREBOARD 
// DESCRIPTION: SCOREBOARD IS RESPONSIBLE FOR DOING COMPARISONS BETWEEN THE TRANSACTION CREATED IN
//							THE SEQUENCE AND THE TRANSACTION CAPTURED BY THE MONITOR.
//-------------------------------------------------------------------------------------------------
// LOG DETAILS
//-------------
// VERSION      NAME        DATE        DESCRIPTION
//    1       HANY SALAH    22012016    FILE CREATION
//		2 			HANY SALAH		28012016		ADD BINARY COMMAND CHECKING
//		3				HANY SALAH		18022016		IMPROVE BLOCK DESCRIPTION & ADD COMMENTS
//-------------------------------------------------------------------------------------------------
// ALL COPYRIGHTS ARE RESERVED FOR THE PRODUCER ONLY .THIS FILE IS PRODUCED FOR OPENCORES MEMBERS 
// ONLY AND IT IS PROHIBTED TO USE THIS MATERIAL WITHOUT THE CREATOR'S PERMISSION
//-------------------------------------------------------------------------------------------------

class uart_scoreboard extends uvm_scoreboard;
	
	// TLM fifo which buffers the trasaction captured by the monitor.
	uvm_tlm_analysis_fifo #(uart_transaction)	mon_fifo;

	// TLM port connected to the monitor.
	uvm_analysis_export #(uart_transaction) scbd_mon;

	// TLM fifo which buffers the trasaction drived from the driver.
	uvm_tlm_analysis_fifo #(uart_transaction) drv_fifo;

	// TLM port connected to the driver.
	uvm_analysis_export #(uart_transaction) scbd_drv;

	uart_transaction			frm_drv,frm_drv_tmp;

	uart_transaction			frm_mon,frm_mon_tmp;

        int                                     match=0;
   
	`uvm_component_utils_begin(uart_scoreboard)
	   `uvm_field_int(match,UVM_ALL_ON)
	`uvm_component_utils_end

	function new (string name , uvm_component parent);
		super.new(name,parent);
	endfunction:new

	extern function void build_phase (uvm_phase phase);

	extern function void connect_phase (uvm_phase phase);

	extern task run_phase (uvm_phase phase);

        extern function void extract_phase (uvm_phase phase);

	extern function void ack_checker ();
endclass:uart_scoreboard


function void uart_scoreboard::build_phase (uvm_phase phase);
	super.build_phase(phase);

	frm_drv 		= uart_transaction::type_id::create("frm_drv");
	frm_drv_tmp	= uart_transaction::type_id::create("frm_drv_tmp");

	frm_mon 		= uart_transaction::type_id::create("frm_mon");
	frm_mon_tmp = uart_transaction::type_id::create("frm_mon_tmp");
	
	mon_fifo = new ("mon_fifo",this);
	scbd_mon = new ("scbd_mon",this);

	drv_fifo = new ("drv_fifo",this);
	scbd_drv = new ("scbd_drv",this);

endfunction:build_phase

function void uart_scoreboard::connect_phase (uvm_phase phase);
	scbd_mon.connect(mon_fifo.analysis_export);
	scbd_drv.connect(drv_fifo.analysis_export);
endfunction:connect_phase

// Run Phase 
task uart_scoreboard::run_phase (uvm_phase phase);

	forever
		begin
		drv_fifo.get(frm_drv_tmp);
		$cast(frm_drv,frm_drv_tmp.clone());
		mon_fifo.get(frm_mon_tmp);
		$cast(frm_mon,frm_mon_tmp.clone());
		if (frm_drv._mode != frm_mon._mode)
			begin
			`uvm_fatal("Testbench Bug",$sformatf("Modes aren't similiar .. It was requested to use %p mode and the applied mode is %p \n ",frm_drv._mode,frm_mon._mode))
			end
		
		else if (frm_drv._mode inside {wrong_mode_text,wrong_mode_bin})
			begin
			if (frm_drv._data == frm_mon._data)
				begin
				`uvm_error("Failed UART Undefined Command","DUT responds to undefined Prefix \n")
				end
			else
				begin
				`uvm_info("Passed UART Undefined Command","DUT doesn't respond to undefined Prefix \n",UVM_HIGH)
				   match++;
				end
			end
		
		else if (frm_drv._command inside {invalid_read,invalid_write})
			begin
			if (frm_drv._data == frm_mon._data)
				begin
				`uvm_error("Failed UART Invalid Command","DUT responds to invalid binary command \n")
				end
			else
				begin
				`uvm_info("Passed UART Invalid Command","DUT doesn't respond to invalid binary command \n",UVM_HIGH)
				   match++;
				end
			end
		
		else
			begin
			case (frm_drv._mode)
				text:
					begin
					if(frm_drv._command != frm_mon._command)
						begin
						`uvm_fatal("Testbench Bug",$sformatf("Commands aren't identical .. It was requested to drive %p command and the applied command is %p \n",frm_drv._command,frm_mon._command))
						end
					else
						begin
						case(frm_drv._command)
							read:
								begin
								if (frm_drv._spacetype1 == wrong_space || frm_drv._eoltype == wrong_eol)
									begin
									if (frm_drv._data == frm_mon._data)
										begin
										`uvm_error("Failed Wrong Read Command","DUT responds to stimulus with wrong white space or eol charachters \n")
										end
									else
										begin
										`uvm_info("Passed Wrong Read Command",$sformatf("Dut was requested to read the data of the address %h with wrong white spaces or eol character \n",frm_mon.address),UVM_HIGH)
										   match++;
										end
									end
								else if (frm_drv._data != frm_mon._data)
									begin
									`uvm_error("Failed Read Text Mode",$sformatf("Data fields aren't identical ,, It was requested to drive %b and dut reply with the data %b \n",frm_drv._data,frm_mon._data))
									end
								else if((frm_drv._data 				== frm_mon._data)	&&
												(frm_drv.address 			== frm_mon.address) &&
												(frm_drv._spacetype1 	== frm_mon._spacetype1) &&
												(frm_drv._eoltype			== frm_mon._eoltype) &&
												(frm_drv._chartype		== frm_mon._chartype))
									begin
									`uvm_info("Passed Read Text Mode",$sformatf("Data fields are identical ,, It was requested to read from the address %h and dut reply with the data %p using white space = %p and %p prefix character and %p as end of line character \n",frm_drv.address,frm_mon._data,frm_drv._spacetype1,frm_drv._chartype,
										frm_drv._eoltype),UVM_HIGH)
									   match++;
									end
								else 
									begin
									`uvm_error("Failed Read Text Mode",$sformatf("It is Requested to request to read data = %p address of %h with character prefix : %p using white space = %p and end of line character %p .. and found data = %p and address=%h with character prefix : %p using white space = %p and end of line character %p \n",frm_drv._data,frm_drv.address,frm_drv._chartype,frm_drv._spacetype1,frm_drv._eoltype,
									 frm_mon._data,frm_mon.address,frm_mon._chartype,frm_mon._spacetype1,frm_mon._eoltype))
									end
								end
							write:
								begin
								if (frm_drv._spacetype1 == wrong_space || frm_drv._spacetype2 == wrong_space || frm_drv._eoltype == wrong_eol)
									begin
									if (frm_drv._data == frm_mon._data)
										begin
										`uvm_error("Failed Wrong Write Command","DUT responds to stimulus with wrong white space or eol charachters \n")
										end
									else
										begin
										`uvm_info("Passed Wrong Write Command",$sformatf("Dut was requested to read the data of the address %h with wrong white spaces or eol character \n",frm_mon.address),UVM_HIGH)
										   match++;
										end
									end
								else if (frm_drv._data != frm_mon._data)
									begin
									`uvm_error("Failed Write Text Mode",$sformatf("Data fields aren't identical ,, It was requested to drive %p and dut register the data %p \n",frm_drv._data,frm_mon._data))
									end
								else if((frm_drv._data 				== frm_mon._data)	&&
												(frm_drv.address	 		== frm_mon.address) &&
												(frm_drv._spacetype1 	== frm_mon._spacetype1) &&
												(frm_drv._spacetype2 	== frm_mon._spacetype2) &&
												(frm_drv._eoltype			== frm_mon._eoltype) &&
												(frm_drv._chartype		== frm_mon._chartype))
									begin
									`uvm_info("Passed write Text Mode",$sformatf("Data fields are identical ,, It was requested to write to the address %h and dut register the data %p using white space = %p and %p prefix character and %p as end of line character \n",frm_drv.address,frm_mon._data,frm_drv._spacetype1,frm_drv._chartype,
										frm_drv._eoltype),UVM_HIGH)
									   match++;
									end
								else 
									begin
									`uvm_error("Failed write Text Mode",$sformatf("It is Requested to request to write data = %p address of %h with character prefix : %p using white space = %p and end of line character %p .. and found data = %p and address=%h with character prefix : %p using white space = %p and end of line character %p \n",frm_drv._data,frm_drv.address,frm_drv._chartype,frm_drv._spacetype1,frm_drv._eoltype,
									 frm_mon._data,frm_mon.address,frm_mon._chartype,frm_mon._spacetype1,frm_mon._eoltype))
									end
								end
							default:
								begin
								`uvm_fatal("Testbench Bug",$sformatf("It isn't allowablt to drive %p command through text mode \n",frm_drv._command))
								end
						endcase
						end
					end
				binary:
					begin
					if (frm_drv._command != frm_mon._command)
						begin
						`uvm_fatal("Testbench Bug",$sformatf("Commands aren't identical .. It was requested to drive %p command and the applied command is %p \n",frm_drv._command,frm_mon._command))
						end
					else if (frm_drv._command inside {read,write})
						begin
						if (frm_drv._reqack 		== frm_mon._reqack &&
								frm_drv._reqinc 		== frm_mon._reqinc &&
								frm_drv.address 		== frm_mon.address &&
								frm_drv.length_data == frm_mon.length_data &&
								frm_drv._data 			== frm_mon._data)
							begin
							`uvm_info($sformatf("Passed Binary %p Command",frm_drv._command),$sformatf("Dut is requested to %p command to start address=%h with data = %p and data length = %0d \n",frm_drv._command,frm_drv.address,frm_drv._data,frm_drv.length_data),UVM_HIGH)
							   match++;
							ack_checker();
							end
						else
							begin
							`uvm_error("Failed Binary Command",$sformatf("Dut is requested to %p command to start address=%h with data = %p, data length = %0d and dut reply with start address = %h and data = %p, length_data=%0d \n",
								frm_drv._command,frm_drv.address,frm_drv._data,frm_drv.length_data,
																 frm_mon.address,frm_mon._data,frm_mon.length_data))
							end
						end
					else if (frm_drv._command == nop)
						begin
						`uvm_info("NOP Command",$sformatf("Dut is requested to %p command \n",frm_drv._command),UVM_HIGH)							
						   match++;
						ack_checker();
						end
					end
				default:
					begin
					`uvm_fatal("Testbench Bug",$sformatf("Mode is undefined = %p \n",frm_drv._mode))
					end
			endcase
			end // else: !if(frm_drv._command inside {invalid_read,invalid_write})

		end
endtask:run_phase

function void uart_scoreboard::extract_phase(uvm_phase phase);
   uvm_resource_db#(int)::write_by_name("Reporting","matched_packets",match);
endfunction // extract_phase


function void uart_scoreboard::ack_checker();
	
	if(frm_drv._reqack == yes && frm_mon.acknowledge != 8'h5A)
		begin
		`uvm_error("Undefined Acknowledge",$sformatf("DUT reply with %h  as acknowledge character \n",frm_mon.acknowledge))
		end
	else if (frm_drv._reqack == no && frm_mon.acknowledge != 8'h00)
		begin
		`uvm_error("Wrong Response","Command doesn't request Acknowledge and DUT forward acknowledge character \n")
		end
	else
		begin
		`uvm_info("Accepted Acknowledge","Acknowledge is the defined as standard \n",UVM_HIGH)
		end	

endfunction:ack_checker
