module Segway_tb();

localparam MIN_LOAD_SENSOR = 12'h200;  // left_load + rght_load >= 0x200
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
// This test bench verifies steering is disabled until load cell and pwr_up conditions are met.
// load cells must remain within 6.25% of eachother during use. and must be within 25% of each other
// for >1.3 secs before steering is enabled.
//
//
//reg signed [15:0] omega_lft,omega_rght;				// angular velocities of wheels
//reg signed [19:0] theta_lft,theta_rght;				// amount wheels have rotated since start
//reg signed [15:0] omega_platform;						// angular velocity of platform
//reg signed [15:0] theta_platform;						// angular position of platform
//
initial begin
	Initialize();
  	@(negedge clk);
	RST_n = 1;
    	repeat(1000) @(posedge clk);

	//
    	// START TESTS
    	//


    	// Send go to the segway. Only balancing should be enabled
	SendCmd(GO);

	// Check that pwr is on. wheels should be equal (no steering)
	rider_lean = 14'h0080;
	repeat(100000) @(posedge clk);
  	if (iDUT.i_Auth_blk.pwr_up != 1 || iPHYS.omega_lft != iPHYS.omega_rght
		|| iPHYS.theta_lft != iPHYS.theta_rght) begin
		$display("FAIL 1: The segway should be powered with no steering.");
		$stop();
	end

	// Check that steering is disabled since we are under min weight
	lft_cell_set = 12'h100;
	rght_cell_set = 12'h050;
	// Check that pwr is on. wheels should be equal (no steering)
	repeat(100000) @(posedge clk);
  	if (iDUT.i_Auth_blk.pwr_up != 1 || iPHYS.omega_lft != iPHYS.omega_rght
		|| iPHYS.theta_lft != iPHYS.theta_rght) begin
		$display("FAIL 2: The segway should be powered with no steering.");
		$stop();
	end

	// Check that steering is disabled (must stay under min_rider_weight when setting cells)
	lft_cell_set = 12'h0F0;
	rght_cell_set = 12'h100;
	// Check that pwr is on. wheels should be equal (no steering)
	repeat(100000) @(posedge clk);
  	if (iDUT.i_Auth_blk.pwr_up != 1 || iPHYS.omega_lft != iPHYS.omega_rght
		|| iPHYS.theta_lft != iPHYS.theta_rght) begin
		$display("FAIL 3: The segway should be powered with no steering.");
		$stop();
	end

	// Now enable steering and check that wheels move at different speeds
	lft_cell_set = 12'h110;
	rght_cell_set = 12'h100;
	rider_lean = 14'h0800;
	repeat(300000) @(posedge clk);
  	if (iDUT.i_Auth_blk.pwr_up != 1 || iPHYS.omega_lft == iPHYS.omega_rght
		|| iPHYS.theta_lft == iPHYS.theta_rght) begin
		$display("FAIL 4: The segway should be powered and turning.");
		$stop();
	end

	// Now make the load cells greater than 6.25% of each other. Steering should disable, but power should be on.
	lft_cell_set = 12'h200;
	rght_cell_set = 12'h004;
	rider_lean = 14'h0800;
	repeat(100000) @(posedge clk);
  	if (iDUT.i_Auth_blk.pwr_up != 1 || iDUT.i_Digital_core.en_steer_w) begin
		$display("FAIL 5: The segway should be powered with no steering.");
		$stop();
	end

    $display("==========================================");
	$display("PASS: steering_en");
    $display("==========================================");
	$stop();
end

always begin
  #5 clk = ~clk;
end

`include "tb_tasks.v"

endmodule
