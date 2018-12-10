module Segway_tb();

//// Interconnects to DUT/support defined as type wire /////
wire SS_n,SCLK,MOSI,MISO,INT;				// to inertial sensor
wire A2D_SS_n,A2D_SCLK,A2D_MOSI,A2D_MISO;	// to A2D converter
wire RX_TX;
wire PWM_rev_rght, PWM_frwrd_rght, PWM_rev_lft, PWM_frwrd_lft;
wire piezo,piezo_n;

////// Stimulus is declared as type reg ///////
reg clk, RST_n;
reg [7:0] cmd;					// command host is sending to DUT
reg send_cmd;					// asserted to initiate sending of command
reg signed [13:0] rider_lean;	// forward/backward lean (goes to SegwayModel)
reg [11:0] batt_set, lft_cell_set, rght_cell_set;	// Set the data we want to get from the A2D


/////// declare any internal signals needed at this level //////
wire cmd_sent;



////////////////////////////////////////////////////////////////
// Instantiate Physical Model of Segway with Inertial sensor //
//////////////////////////////////////////////////////////////
SegwayModel iPHYS(.clk(clk),.RST_n(RST_n),.SS_n(SS_n),.SCLK(SCLK),
                  .MISO(MISO),.MOSI(MOSI),.INT(INT),.PWM_rev_rght(PWM_rev_rght),
				  .PWM_frwrd_rght(PWM_frwrd_rght),.PWM_rev_lft(PWM_rev_lft),
				  .PWM_frwrd_lft(PWM_frwrd_lft),.rider_lean(rider_lean));

/////////////////////////////////////////////////////////
// Instantiate Model of A2D for load cell and battery //
///////////////////////////////////////////////////////
ADC128S iA2D(.clk(clk), .rst_n(RST_n), .SS_n(A2D_SS_n), .SCLK(A2D_SCLK), .MISO(A2D_MISO),
		.MOSI(A2D_MOSI), .batt_set(batt_set), .lft_cell_set(lft_cell_set), .rght_cell_set(rght_cell_set));


////// Instantiate DUT ////////
Segway iDUT(.clk(clk),.RST_n(RST_n),.LED(),.INERT_SS_n(SS_n),.INERT_MOSI(MOSI),
            .INERT_SCLK(SCLK),.INERT_MISO(MISO),.A2D_SS_n(A2D_SS_n),
			.A2D_MOSI(A2D_MOSI),.A2D_SCLK(A2D_SCLK),.A2D_MISO(A2D_MISO),
			.INT(INT),.PWM_rev_rght(PWM_rev_rght),.PWM_frwrd_rght(PWM_frwrd_rght),
			.PWM_rev_lft(PWM_rev_lft),.PWM_frwrd_lft(PWM_frwrd_lft),
			.piezo_n(piezo_n),.piezo(piezo),.RX(RX_TX));


//// Instantiate UART_tx (mimics command from BLE module) //////
//// You need something to send the 'g' for go ////////////////
UART_tx iTX(.clk(clk),.rst_n(RST_n),.TX(RX_TX),.trmt(send_cmd),.tx_data(cmd),.tx_done(cmd_sent));


//
// This test bench verifies the A2D converter receiving the correct data for the correct channel
//
initial begin
	Initialize();
  	@(negedge clk);
	RST_n = 1;
    	repeat(1000) @(posedge clk);
	SendCmd(8'h67);

	//
    	// START TESTS
    	//

	//
	SendA2D(12'h001, 12'h005, 12'h015);	// left_cell, right_cell, batt
	repeat(4) @(posedge iDUT.nxt_w);
  	if (iDUT.lft_ld_w != lft_cell_set || iDUT.rght_ld_w != rght_cell_set || iDUT.batt_w!= batt_set) begin
		$display("FAIL 1: A2D data does not match.");
		$stop();
	end

	SendA2D(12'h018, 12'h0FF, 12'h123);	// left_cell, right_cell, batt
	repeat(10) @(posedge iDUT.nxt_w);
  	if (iDUT.lft_ld_w != lft_cell_set || iDUT.rght_ld_w != rght_cell_set || iDUT.batt_w!= batt_set) begin
		$display("FAIL 1: A2D data does not match.");
		$stop();
	end

    	$display("==========================================");
	$display("PASS: A2D intf");
    	$display("==========================================");
  	$stop();
end

always begin
  #10 clk = ~clk;
end

`include "tb_tasks.v"

endmodule
