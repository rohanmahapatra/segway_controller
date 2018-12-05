task Initialize;
	begin
		clk = 0;
		RST_n = 0;
		cmd = 8'h00;
		send_cmd = 0;
		rider_lean = 14'h0000;
		batt_set = 12'h000;
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
    rght_cell_set = 12'h100;
    lft_cell_set = 12'h100;
    @(!iDUT.rider_off_w);
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
