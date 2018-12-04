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

task test_rider_off;
    begin
        lft_cell_set = 12'h700;
		rght_cell_set = 12'h700;
    end
endtask


