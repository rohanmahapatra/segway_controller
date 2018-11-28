reg clk;
reg cmd_sent;
reg RST_n;
reg [7:0] cmd;					// command host is sending to DUT
reg send_cmd;					// asserted to initiate sending of command
reg [13:0] rider_lean;	// forward/backward lean (goes to SegwayModel)
reg [11:0] batt_set, lft_cell_set, rght_cell_set;


task Initialize;
/*
	input clk;
	input cmd_sent;
	input RST_n;
	input [7:0] cmd;					// command host is sending to DUT
	input send_cmd;					// asserted to initiate sending of command
	input [13:0] rider_lean;	// forward/backward lean (goes to SegwayModel)
	input [11:0] batt_set, lft_cell_set, rght_cell_set;
*/
	begin;
		clk = 0;
		RST_n = 0;
		cmd = 8'h00;
		send_cmd = 0;	
		rider_lean = 14'h0000;
		batt_set = 12'h000;
		lft_cell_set = 12'h000;
		rght_cell_set = 12'h000;	
	end;
endtask
// Set the UART tx_data input to the data we want to send and
// hold trmt for 1 clock cycle. We know the tranmittion is finished
// when tx_done is asserted.
/*
task SendCmd;
    input [7:0] snd_data;

    begin
        @(negedge clk);
        cmd = snd_data;
        send_cmd = 1;
        @(negedge clk);
        @(negedge clk);
        send_cmd = 0;
        @(posedge cmd_sent);
    end
endtask
*/




