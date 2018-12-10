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


	initial begin
		Initialize();
	  	@(negedge clk);
	 	 RST_n = 1;

		////// Start issuing commands to DUT //////

		// TEST 1:No signals  (no weight on loadcells and battery//
	  	SendCmd(8'h67);
		repeat(100000) @(posedge clk);
	  	if (iDUT.i_piezo_drv.batt_low ==1 || iDUT.i_piezo_drv.moving == 1 || iDUT.i_piezo_drv.ovr_spd == 1) begin
			$display("FAIL 1: Nothing should assert?");
			$stop();
		end

	     	// TEST 2: batt_low sound should assert (no weight on loadcells and battery = 0x855)//
     		SendA2D(12'h000,12'h000,12'h855);
     		SendCmd(8'h67);
     		repeat(100000) @(posedge clk);
         	if (iDUT.i_piezo_drv.batt_low == 1 || iDUT.i_piezo_drv.moving == 1 || iDUT.i_piezo_drv.ovr_spd == 1) begin
            		$display("FAIL 2: Piezo should not indicate low battery?");
     		end

     		//TEST 3: norm_mode sound should assert (Battery is not low and the rider is turning Left)//
     		SendA2D(12'h208, 12'h201,12'h855);
     		repeat(100000) @(posedge clk);
        	if (iDUT.i_piezo_drv.moving ==  0|| iDUT.i_piezo_drv.batt_low == 1 || iDUT.i_piezo_drv.ovr_spd == 1 ) begin
             		$display("FAIL 3: Piezo Did  not indicate moving?");
     		end

     		//TEST 4: norm_mode sound should assert (Battery is not low and the rider is turning Right)//
     		SendA2D(12'h201, 12'h208,12'h855);
     		repeat(100000) @(posedge clk);
    		if (iDUT.i_piezo_drv.moving == 0 || iDUT.i_piezo_drv.batt_low == 1 || iDUT.i_piezo_drv.ovr_spd == 1 ) begin
     			$display("FAIL 4: Piezo Did not indicate moving?");
			$stop();
     		end

		//TEST 5: norm_mode sound should assert (Battery is not low and the rider is moving forward)//
     		SendA2D(12'h205, 12'h205,12'h855);
		SetLean(14'h000F);
     		repeat(100000) @(posedge clk);
        	if (iDUT.i_piezo_drv.moving == 0 || iDUT.i_piezo_drv.batt_low == 1 || iDUT.i_piezo_drv.ovr_spd == 1 ) begin
             		$display("FAIL 5: Piezo Did not indicate moving?");
     		end

     		//TEST 6: norm_mode sound should assert (Battery is not low and the rider is moving in reverse)//
     		SendA2D(12'h205, 12'h205,12'h855);
		SetLean(14'hFFF0);
     		repeat(100000) @(posedge clk);
    		if (iDUT.i_piezo_drv.moving == 0 || iDUT.i_piezo_drv.batt_low == 1 || iDUT.i_piezo_drv.ovr_spd == 1 ) begin
     			$display("FAIL 6: Piezo Did not indicate moving?");
			$stop();
     		end

		//TEST 7: norm_mode sound should assert (Battery is not low and the rider is moving forward and right)//
     		SendA2D(12'h201, 12'h208,12'h855);
		SetLean(14'h000F);
     		repeat(100000) @(posedge clk);
        	if (iDUT.i_piezo_drv.moving == 0 || iDUT.i_piezo_drv.batt_low == 1 || iDUT.i_piezo_drv.ovr_spd == 1 ) begin
             		$display("FAIL 7: Piezo Did not indicate moving?");
			$stop();
     		end

     		//TEST 8: norm_mode sound should assert (Battery is not low and the rider is moving forward and left)//
     		SendA2D(12'h208, 12'h201,12'h855);
		SetLean(14'h000F);
     		repeat(100000) @(posedge clk);
    		if (iDUT.i_piezo_drv.moving == 0 || iDUT.i_piezo_drv.batt_low == 1 || iDUT.i_piezo_drv.ovr_spd == 1 ) begin
     			$display("FAIL 8: Piezo Did not indicate moving?");
			$stop();
     		end

		//TEST 9: norm_mode sound should assert (Battery is not low and the rider is moving in reverse and right)//
     		SendA2D(12'h201, 12'h208,12'h855);
		SetLean(14'hFFF0);
     		repeat(100000) @(posedge clk);
        	if (iDUT.i_piezo_drv.moving == 0 || iDUT.i_piezo_drv.batt_low == 1 || iDUT.i_piezo_drv.ovr_spd == 1 ) begin
             		$display("FAIL 9: Piezo Did not indicate moving?");
			$stop();
     		end

     		//TEST 10: norm_mode sound should assert (Battery is not low and the rider is moving in reverse and left)//
     		SendA2D(12'h208, 12'h201,12'h855);
		SetLean(14'hFFF0);
     		repeat(100000) @(posedge clk);
    		if (iDUT.i_piezo_drv.moving == 0 || iDUT.i_piezo_drv.batt_low == 1 || iDUT.i_piezo_drv.ovr_spd == 1 ) begin
     			$display("FAIL 10: Piezo Did not indicate moving?");
			$stop();
     		end

		//TEST 11: ovr_spd sound should assert (Battery is not low and the rider is moving to big lean forward)//
     		SendA2D(12'h205, 12'h205,12'h855);
		SetLean(14'h1FFF);
     		repeat(100000) @(posedge clk);
    		if (iDUT.i_piezo_drv.moving == 0 || iDUT.i_piezo_drv.batt_low == 1 || iDUT.i_piezo_drv.ovr_spd ==0 ) begin
     			$display("FAIL 11: Piezo Did not indicate over speed?");
			$stop();
     		end

		//TEST 12: ovr_spd sound should assert (Battery is not low and the rider is moving to big lean backward)//
     		SendA2D(12'h205, 12'h205,12'h855);
		SetLean(14'h2000);
     		repeat(100000) @(posedge clk);
    		if (iDUT.i_piezo_drv.moving == 0 || iDUT.i_piezo_drv.batt_low == 1 || iDUT.i_piezo_drv.ovr_spd ==0 ) begin
     			$display("FAIL 12: Piezo Did not indicate over speed?");
			$stop();
     		end

		//TEST 13: ovr_spd and battert low sound should assert (Battery is low and the rider is moving with a big lean foward)//
     		SendA2D(12'h205, 12'h205,12'h055);
		SetLean(14'h1FFF);
     		repeat(36000) @(posedge clk);
    		if (iDUT.i_piezo_drv.moving == 0 || iDUT.i_piezo_drv.batt_low == 0 || iDUT.i_piezo_drv.ovr_spd == 0) begin
     			$display("FAIL 13: Piezo Did not indicate over speed and battery low?");
			$stop();
     		end





		$display("==========================================");
		$display("PASS: piezo_drv");
		$display("==========================================");
		$stop();
	end


	always begin
	  #10 clk = ~clk;
	end


	`include "tb_tasks.v";


	endmodule
