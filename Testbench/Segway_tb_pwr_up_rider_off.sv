module Segway_tb();

localparam GO = 8'h67;
localparam STOP = 8'h73;

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
// Power up and rider off conditions
//
// 1. rider off, send GO to power on "balance state"
// 2. rider goes on, steering should not enabled yet because we need to wait for some time
// 3. send STOP with rider on, pwr should not deassert
// 4. rider min weight is not meet so pwr off
// 5. Go back to riding state, rider steps off and STOP is received. Go directly to pwr off
// 6. Go back to riding state, rider falls off, en_steer should disable but keep pwr on
// 7. Rider steps back on and steering is enabled.
//
initial begin
	Initialize();
  	@(negedge clk);
 	 RST_n = 1;
	////// Start issuing commands to DUT //////

	// Currently rider is off; rider_off = 1 should not affect pwr_up going high
	// pwr_up should assert
  	SendCmd(GO);
	repeat(1000) @(posedge clk);
  	if (iDUT.i_Auth_blk.pwr_up != 1) begin
		$display("FAIL 1: pwr_up from AUTH_blk not asserted");
		$stop();
	end

	// Rider goes on board
	lft_cell_set = 12'h105;
	rght_cell_set = 12'h105;
	@(negedge iDUT.i_Digital_core.i_steer_en.rider_off);


	// Steering should not be enabled yet, need to wait until stable (1.3 seconds in real world)
  	if (iDUT.i_Digital_core.en_steer_w != 0) begin
		$display("FAIL 2: steering should not be enabled yet.");
		$stop();
	end

	// wait for steering to enable
	@(posedge iDUT.i_Digital_core.en_steer_w);

	// pwr_up should not desserted if we send 's' because rider is still on
	SendCmd(STOP);
	repeat(50000) @(posedge clk);
  	if (iDUT.i_Auth_blk.pwr_up != 1) begin
		$display("FAIL 3: pwr_up from AUTH_blk should still be asserted because rider is on");
		$stop();
	end

	// pwr_up should deassert
	lft_cell_set = 12'h080;
	rght_cell_set = 12'h105;
	repeat(50000) @(posedge clk);
  	if (iDUT.i_Auth_blk.pwr_up != 0 || iDUT.i_Digital_core.en_steer_w != 0) begin
		$display("FAIL 4: pwr_up from AUTH_blk should not be asserted because rider stepped off");
		$stop();
	end

	// Go back to power on state with rider on
	lft_cell_set = 12'h110;
	rght_cell_set = 12'h105;
	SendCmd(GO);
	repeat(50000) @(posedge clk);

	// rider is off and 's' is recieved. Go directly to off
	lft_cell_set = 12'h110;
	rght_cell_set = 12'h005;
	SendCmd(STOP);
	repeat(50000) @(posedge clk);
  	if (iDUT.i_Auth_blk.pwr_up != 0 || iDUT.i_Digital_core.en_steer_w != 0) begin
		$display("FAIL 5: pwr_up from AUTH_blk should not be asserted because rider is on and 's' was sent.");
		$stop();
	end

	// Go back to power on state with rider on
	lft_cell_set = 12'h110;
	rght_cell_set = 12'h105;
	SendCmd(GO);
	repeat(50000) @(posedge clk);

	// rider falls off; en_steer should be 0 and pwr should be on
	lft_cell_set = 12'h110;
	rght_cell_set = 12'h003;
	repeat(50000) @(posedge clk);
  	if (iDUT.i_Auth_blk.pwr_up != 1 || iDUT.i_Digital_core.en_steer_w != 0) begin
		$display("FAIL 6: pwr_up from AUTH_blk should be asserted, but steering should be enabled. \"balancing state\".");
		$stop();
	end

	// rider gets back on the segway to enable steering after falling off
	lft_cell_set = 12'h110;
	rght_cell_set = 12'h110;
	repeat(50000) @(posedge clk);
  	if (iDUT.i_Auth_blk.pwr_up != 1 || iDUT.i_Digital_core.en_steer_w != 1) begin
		$display("FAIL 7: pwr_up from AUTH_blk should be asserted as well as steering.");
		$stop();
	end


    $display("==========================================");
	$display("PASS: pwr_up_rider_off");
    $display("==========================================");
  	$stop();
end

always begin
  #5 clk = ~clk;
end

`include "tb_tasks.v"

endmodule
