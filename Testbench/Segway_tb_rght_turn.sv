module Segway_tb();

localparam  PLAT_ERROR = 16'h0200;
localparam MIN_LOAD_SENSOR = 12'h200;  // left_load + rght_load >= 0x200

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
reg signed [15:0] prev_omega_lft;
reg signed [19:0] prev_theta_lft;

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
// This test bench verifies the right load cell by making right turns.
// Load cells must remain within 6.25% of eachother during use.
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
    	prev_omega_lft = 0;
    	prev_theta_lft = 0;
    	repeat(10000) @(posedge clk);

    	// Get the segway into a balance and steering enabled state
    	moveEn();

    	//
    	// START TESTS
    	//

	// Right now lean = 0; lft_load_cell = 0; rght_load_cell = 0;
	// the platform should not be moving a lot, maybe some balancing
	if (abs(iPHYS.theta_platform) > PLAT_ERROR || abs(iPHYS.omega_lft) > PLAT_ERROR || abs(iPHYS.omega_rght) > PLAT_ERROR) begin
		$display("FAIL 1: The platform should not be moving.");
		$stop();
	end

	// Increase the right load cell and lean to simulate a right forward turn
    	// Left wheel should turn and move faster than the right
    	rght_cell_set = 12'h130;
    	rider_lean = 14'h0F00;
	repeat(1000000) @(posedge clk);
	if (iPHYS.omega_lft <= 0 || iPHYS.theta_lft <= 0 || iPHYS.omega_rght >= iPHYS.omega_lft) begin
		$display("FAIL 2: The platform should be making a right turn.");
		$stop();
	end
    	prev_omega_lft = iPHYS.omega_lft;
    	prev_theta_lft = iPHYS.theta_lft;

    	// Increase the right load cell again and lean to simulate a right forward turn
    	// Left wheel should be moving faster than the right
    	// Left wheel should now be moving faster than the previous test
    	rght_cell_set = 12'h190;
    	//rider_lean = 14'h0400;
	repeat(1000000) @(posedge clk);
    	if (iPHYS.omega_lft <= 0 || iPHYS.theta_lft <= 0 || iPHYS.omega_rght >= iPHYS.omega_lft
        	|| iPHYS.omega_lft <= prev_omega_lft || iPHYS.theta_lft <= prev_theta_lft) begin
		$display("FAIL 3: The platform should be making a sharper right turn.");
		$stop();
	end
    	prev_omega_lft = iPHYS.omega_lft;
    	prev_theta_lft = iPHYS.theta_lft;

    	// decrease the right load cell and lean to simulate coming out of a right turn
    	// Left wheel should be moving faster than right, but slower than
    	// in the previous test
    	rght_cell_set = 12'h120;
    	rider_lean = 14'h0800;
    	repeat(2000000) @(posedge clk);
    	if (iPHYS.omega_lft <= 0 || iPHYS.theta_lft <= 0 || iPHYS.omega_rght >= iPHYS.omega_lft
        	|| iPHYS.omega_lft >= prev_omega_lft) begin
        	$display("FAIL 4: The platform should be making a slower right turn.");
        	$stop();
    	end
    	prev_omega_lft = iPHYS.omega_lft;
    	prev_theta_lft = iPHYS.theta_lft;


    	//
    	// Now go backwards
    	//

    	// Set rider_lean so the segway goes backwards with the rght load cell
    	// set to make a right turn. The segway should be slowly making a backwards
    	// right turn.
    	//
    	rght_cell_set = 12'h140;
    	rider_lean = -14'h0800;
    	repeat(5000000) @(posedge clk);
    	if (iPHYS.omega_lft >= 0 || abs(iPHYS.omega_rght) < abs(iPHYS.omega_lft)
        	|| iPHYS.omega_lft >= prev_omega_lft || iPHYS.theta_lft >= prev_theta_lft) begin
        	$display("FAIL 5: The platform should be making a reverse right turn.");
        	$stop();
    	end
    	prev_omega_lft = iPHYS.omega_lft;
    	prev_theta_lft = iPHYS.theta_lft;

	//
    	// Set rider_lean so the segway goes backwards with the rght load cell
    	// set to make a right turn. The segway should be more quickly making a backwards
    	// right turn.
    	//
    	// NOTE: Does iPHYS.theta_lft decrease in value when the wheels go backwards?
    	//
    	rght_cell_set =12'h200;
    	rider_lean = -14'h0F00;
    	repeat(1000000) @(posedge clk);
    	if (iPHYS.omega_lft >= 0 || abs(iPHYS.omega_rght) < abs(iPHYS.omega_lft)
        	|| iPHYS.omega_lft >= prev_omega_lft || iPHYS.theta_lft >= prev_theta_lft) begin
        	$display("FAIL 6: The platform should be making a faster reverse righ turn.");
        	$stop();
    	end
    	prev_omega_lft = iPHYS.omega_lft;
    	prev_theta_lft = iPHYS.theta_lft;


        $display("==========================================");
    	$display("PASS: rght_turn");
        $display("==========================================");
  	     $stop();
end

always begin
  #5 clk = ~clk;
end

function [15:0] abs([15:0] val);
	begin
	abs = (val[15] == 1'b1) ? (~(val) + 1) : val;
	end
endfunction

`include "tb_tasks.v"

endmodule
