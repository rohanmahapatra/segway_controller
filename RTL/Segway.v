module Segway(clk,RST_n,LED,INERT_SS_n,INERT_MOSI,
              INERT_SCLK,INERT_MISO,A2D_SS_n,A2D_MOSI,A2D_SCLK,
			  A2D_MISO,PWM_rev_rght,PWM_frwrd_rght,PWM_rev_lft,
			  PWM_frwrd_lft,piezo_n,piezo,INT,RX);

  input clk,RST_n;
  input INERT_MISO;						// Serial in from inertial sensor
  input A2D_MISO;						// Serial in from A2D
  input INT;							// Interrupt from inertial indicating data ready
  input RX;								// UART input from BLE module


  output [7:0] LED;						// These are the 8 LEDs on the DE0, your choice what to do
  output A2D_SS_n, INERT_SS_n;			// Slave selects to A2D and inertial sensor
  output A2D_MOSI, INERT_MOSI;			// MOSI signals to A2D and inertial sensor
  output A2D_SCLK, INERT_SCLK;			// SCLK signals to A2D and inertial sensor
  output PWM_rev_rght, PWM_frwrd_rght;  // right motor speed controls
  output PWM_rev_lft, PWM_frwrd_lft;	// left motor speed controls
  output piezo_n,piezo;					// diff drive to piezo for sound

  ////////////////////////////////////////////////////////////////////////
  // fast_sim is asserted to speed up fullchip simulations.  Should be //
  // passed to both balance_cntrl and to steer_en.  Should be set to  //
  // 0 when we map to the DE0-Nano.                                  //
  ////////////////////////////////////////////////////////////////////
  localparam fast_sim = 1;	// asserted to speed up simulations.

  ///////////////////////////////////////////////////////////
  ////// Internal interconnecting sigals defined here //////
  /////////////////////////////////////////////////////////
  wire rst_n;                           // internal global reset that goes to all units

  wire pwr_up_w;	// needed in authentication block
  wire nxt_w;		// needed in A2D interface and digital core drives these
  wire [11:0] lft_ld_w, rght_ld_w, batt_w;
  wire [10:0] lft_spd_w;
  wire [10:0] rght_spd_w; // for mtr_drv
  wire lft_rev, rght_rev;
  wire audio_o_w, audio_o_n_w, moving_w, ovr_spd_w, batt_low_w; // in piezo friver from digital core
  wire rider_off_w;

  /////////////////////////////////////
  // Instantiate reset synchronizer //
  ///////////////////////////////////
  rst_synch iRST(.clk(clk),.RST_n(RST_n),.rst_n(rst_n));

  /////////////////////////////////////
  // Authentication Block //
  /////////////////////////////////////

  Auth_blk i_Auth_blk (.clk(clk), .rst_n(rst_n), .pwr_up(pwr_up_w), .RX(RX), .rider_off(rider_off_w) ); // connect rider_off

  /////////////////////////////////////
  // A2D Interface //
  /////////////////////////////////////
  //to connect - nxt comes from digital core
  A2D_Intf i_A2D_intf ( .clk(clk), .rst_n(rst_n), .nxt(nxt_w), .lft_ld(lft_ld_w), .rght_ld(rght_ld_w), .batt(batt_w),
			.SS_n(A2D_SS_n), .SCLK(A2D_SCLK), .MOSI(A2D_MOSI), .MISO(A2D_MISO));

  /////////////////////////////////////
  // Digital Core //
  /////////////////////////////////////

  Digital_core i_Digital_core    (.clk(clk),.rst_n(rst_n),.pwr_up(pwr_up_w),.whl_spd_lft(), 		// ask Prof where is this coming form
				.whl_spd_rght(), .lft_ld(lft_ld_w), .rght_ld(rght_ld_w), .batt(batt_w), .nxt(nxt_w), .lft_spd(lft_spd_w), .rght_spd(rght_spd_w),
				.lft_rev(lft_rev_w), .rght_rev(rght_rev_w), .moving(moving_w), .ovr_spd(ovr_spd_w), .batt_low(batt_low_w),
				.SS_n(INERT_SS_n), .SCLK(INERT_SCLK), .MOSI(INERT_MOSI), .MISO(INERT_MISO), .INT(INT), .rider_off_w(rider_off_w));

  /////////////////////////////////////
  // Piezo Driver //
  /////////////////////////////////////
 
  piezo_drv i_peizo_drv (.clk(clk), .rst_n(rst_n), .moving(moving_w), .ovr_spd(ovr_spd_w), .batt_low(batt_low_w), .audio_o(audio_o_w), .audio_o_n(audio_o_n_w));

  /////////////////////////////////////
  // MTR_DRV //
  /////////////////////////////////////

  // lft_spd etc coming from digital core
  mtr_drv i_mtr_drv (.clk(clk), .rst_n(rst_n), .lft_spd(lft_spd_w), .lft_rev(lft_rev_w), .PWM_rev_lft(PWM_rev_lft), .PWM_frwrd_lft(PWM_frwrd_lft),
	 .rght_spd(rght_spd_w), .rght_rev(rght_rev), .PWM_rev_rght(PWM_rev_rght), .PWM_frwrd_rght(PWM_frwrd_rght));



endmodule
