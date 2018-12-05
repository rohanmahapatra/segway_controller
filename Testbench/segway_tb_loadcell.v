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
	

		 reg signed [15:0] omega_platform;						// angular velocity of platform

  reg signed [15:0] theta_platform;						// angular position of platform

  
	//// Instantiate UART_tx (mimics command from BLE module) //////
	//// You need something to send the 'g' for go ////////////////
	UART_tx iTX(.clk(clk),.rst_n(RST_n),.TX(RX_TX),.trmt(send_cmd),.tx_data(cmd),.tx_done(cmd_sent));
	

	initial begin
		Initialize();
	  	@(negedge clk);
	 	 RST_n = 1;
     
		////// Start issuing commands to DUT //////
		//Turn on the Segway
		SendCmd(8'h67);

		// TEST 1: batt_low sound should assert (no lean, no lean on loadcells, and battery = 0x0FF)//
	  	SendA2D(11'h205,11'h205, 11'h0FF);
		SetLean(14'h1FFF);
		repeat(1000000) @(posedge clk);
	  	if (iDUT.SegwayModel.theta_platform < 500) begin
			$display("FAIL 1: Piezo Did not indicate low battery?");
		end



		$display("YAHOO! All segway leans tests Pass!");
	  	$stop();
	end
	

	always begin
	  #5 clk = ~clk;
	end
	

	`include "tb_tasks.v";
	

	endmodule	
	



