/*
task Initialize;
	begin
		clk = 0;
		RST_n = 0;
		cmd = 8'h00;
		send_cmd = 0;
		rider_lean = 14'h0000;
		batt_set = 12'h900;
		lft_cell_set = 12'h000;
		rght_cell_set = 12'h000;
	end
endtask

// Set the UART tx_data input to the data we want to send and
// hold trmt for 1 clock cycle. We know the tranmittion is finished
// when tx_done is asserted.
// 0x67 = "g"
// 0x73 = "s"
task SendCmd;
    input [7:0] send_data;
    begin
        @(negedge clk);
        cmd = send_data;
        send_cmd = 1;
        @(negedge clk);
        @(negedge clk);
        send_cmd = 0;
        @(posedge cmd_sent);
    end
endtask

// This task gets the segway into a state where balance and steering are enabled
//
// When powered the Segway is always in a "balance state"
// Steering should be disabled until both feet on. rider_off will then
// deassert to signal the rider is on
task moveEn;
	begin
    SendCmd(8'h67);
    rght_cell_set = 12'h105;
    lft_cell_set = 12'h105;
    @(posedge iDUT.moving_w);
	end
endtask

task test_rider_off;
	begin
		lft_cell_set = 12'h700;
		rght_cell_set = 12'h700;
	end
endtask

task SendA2D;
	input [11:0] send_lft_cell_set;
	input [11:0] send_rght_cell_set;
	input [11:0] send_batt_set;	
	begin
        	lft_cell_set = send_lft_cell_set;
        	rght_cell_set = send_rght_cell_set;
        	batt_set = send_batt_set;
    	end
endtask


task SetLean;
	input [13:0] lean;
	begin
		rider_lean = lean;
	end
endtask

/*
// Is this kind of task actually helpful?
task getPlatformTheta;
	output [15:0] model_theta_platform;
    begin
        model_theta_platform = iPHYS.theta_platform;
    end
endtask
*/

task Initialize;

  begin
    send_cmd = 0;
clr_peak_mins_n = 1;
rider_lean = 16'h0000;
clk = 0;
    RST_n = 0; // assert reset
ld_cell_lft = 12'h000;
ld_cell_rght = 12'h000;
batt = 12'hA00;
    repeat (2) @(posedge clk);
    @(negedge clk); // on negedge REF_CLK after a few REF clocks
    RST_n = 1; // deasert reset
    repeat (500) @(negedge clk);
  end
endtask

task SendCmd;
  ///////////////////////////////////////////////////
  // Passed a 24-bit command to send over the UART// 
  // (command from host).  It initiates the      //
  // transfer and waits for the cmd_sent signal //
  ///////////////////////////////////////////////
  
  input [7:0] cmd_to_send;

  begin
    cmd = cmd_to_send;
    @(posedge clk);
    send_cmd = 1;
    @(posedge clk);
    send_cmd = 0;
    //////////////////////////////////////
    // Now wait for command to be sent //
    ////////////////////////////////////
    @(posedge cmd_sent);
    @(posedge clk);
  end
endtask

function out_of_range (input signed [15:0] in_val,expected, input [15:0] bound);
  out_of_range = ((in_val>$signed(expected + bound)) || (in_val<$signed(expected - bound))) ? 1'b1 : 1'b0;
endfunction
