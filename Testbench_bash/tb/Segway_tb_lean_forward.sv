module Segway_tb();

localparam  PLAT_ERROR = 16'h0800;
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
reg signed [15:0] prev_omega;
reg signed [19:0] prev_theta;
reg [4:0] step;
reg done;	// Only used for loop iteration display in waveform


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
// This test bench verifies the lean forward and back are working.
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
	prev_omega = 0;
    	prev_theta = 0;
	done = 0;
    	repeat(10000) @(posedge clk);

	// Get segway into good riding state
	moveEn();

	//
	// START TEST
	//

	// Right now lean = 0
	// the platform should not be moving a lot, maybe some balancing
	rider_lean = 14'h0000;
	repeat(1000000) @(posedge clk);
	if (iDUT.i_Digital_core.en_steer_w != 1 || abs(iPHYS.theta_platform) > PLAT_ERROR || abs(iPHYS.omega_lft) > PLAT_ERROR || abs(iPHYS.omega_rght) > PLAT_ERROR) begin
		$display("FAIL 1: The platform should only be balancing.");
		$stop();
	end

	//
	// Increase lean using a step function.
	// will go from 0 lean to 14'h1FFF lean (approx 8000) in steps of 1000 decimal
	//
	for (step = 1; step <= 8; step = step + 1) begin
		rider_lean = (step * 1000);
		// The big theta waveform "bump" is approx 100,000 clk after we set lean
		repeat(100000) @(posedge clk);
    		prev_theta = iPHYS.theta_platform;
		repeat(800000) @(posedge clk);
		done = 1;
		@(posedge clk);
		done = 0;

		// Check that we are converging on 0 and that we are closer to 0 at the end of the test then the beginning
		if (abs(iPHYS.theta_platform) >= abs(prev_theta) || abs(iPHYS.omega_platform) >= PLAT_ERROR || abs(iPHYS.theta_platform) >= PLAT_ERROR) begin
			$display("FAIL: %d The platform should be converging on zero.", step);
            		$display("iPHYS.theta_platform: %d, iPHYS.omega_platform: %d, prev_omega: %d, prev_theta: %d", 
                    		iPHYS.theta_platform, iPHYS.omega_platform, prev_omega, prev_theta);
			$stop();
		end
	end

	
    	$display("==========================================");
	$display("PASS: lean_forward");
    	$display("==========================================");
  	$stop();
end

always begin
  #10 clk = ~clk;
end

function [15:0] abs([15:0] val);
	begin
	abs = (val[15] == 1'b1) ? (~(val) + 1) : val;
	end
endfunction


`include "tb_tasks.v"

endmodule
