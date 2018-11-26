module mtr_drv_tb();


// Input Output Ports
reg clk, rst_n; // in 50MHz clock, and active low asynchreset
reg [10:0] lft_spd; //in Left motor duty cycle
reg lft_rev; // in If highleft motor should be driven in reverse
wire PWM_rev_lft; 
wire PWM_frwrd_lft ; //out 11-bit PWM signal (2048 divisions/period) goto H-Bridge controller chip
reg [10:0] rght_spd; // in Left motor duty cycle 
reg rght_rev; //in If highleft motor should be driven in reverse
wire PWM_rev_rght;
wire PWM_frwrd_rght; //out 11-bit PWM signal (2048 divisions/period) goto H-Bridge controller chip


mtr_drv iDut (.clk(clk), .rst_n(rst_n), .lft_spd(lft_spd), .lft_rev(lft_rev), 
	     .PWM_rev_lft(PWM_rev_lft),.PWM_frwrd_lft(PWM_frwrd_lft), .rght_spd(rght_spd), 
	     .rght_rev(rght_rev), .PWM_rev_rght(PWM_rev_rght), .PWM_frwrd_rght(PWM_frwrd_rght)); 


initial begin

clk = 0;
rst_n = 0;

repeat(2) @(posedge clk);
#1; 		// to model async rst
rst_n = 1;	// deassert reset
@(posedge clk) lft_spd = 11'h00f;
		lft_rev = 0;
		rght_spd = 11'h00f;
		rght_rev = 0;
repeat(2047)@(posedge clk);

@(posedge clk) lft_spd = 11'h0ff;
		lft_rev = 1;
		rght_spd = 11'h0ff;
		rght_rev = 1;
repeat(2047)@(posedge clk);

@(posedge clk) lft_spd = 11'h0ff;
		lft_rev = 0;
		rght_spd = 11'h0ff;
		rght_rev = 1;
repeat(2047)@(posedge clk);

@(posedge clk) lft_spd = 11'hf00;
		lft_rev = 1;
		rght_spd = 11'hf00;
		rght_rev = 0;
repeat(2047)@(posedge clk);



repeat(2) @(posedge clk);
$stop();


end

always
  #5 clk = ~clk;

endmodule