module mtr_drv (clk, rst_n, lft_spd, lft_rev, PWM_rev_lft,PWM_frwrd_lft, rght_spd, rght_rev, PWM_rev_rght, PWM_frwrd_rght); 

// Input Output Ports
input clk, rst_n; // in 50MHz clock, and active low asynchreset
input [10:0] lft_spd; //in Left motor duty cycle
input lft_rev; // in If highleft motor should be driven in reverse
output PWM_rev_lft; 
output PWM_frwrd_lft ; //out 11-bit PWM signal (2048 divisions/period) goto H-Bridge controller chip
input [10:0] rght_spd; // in Left motor duty cycle 
input rght_rev; //in If highleft motor should be driven in reverse
output PWM_rev_rght;
output PWM_frwrd_rght; //out 11-bit PWM signal (2048 divisions/period) goto H-Bridge controller chip

reg lft_PWM_sig, rght_PWM_sig;

// instantiating PWM model twice for the left and the right motor.

PWM11 lft_inst (.clk(clk), .rst_n(rst_n), .duty(lft_spd), .PWM_sig(lft_PWM_sig));

PWM11 rght_inst (.clk(clk), .rst_n(rst_n), .duty(rght_spd), .PWM_sig(rght_PWM_sig));

// assigning either forward or reverse direction of PWM output depending on the below logic.
assign PWM_rev_lft = lft_rev ? lft_PWM_sig : 0;
assign PWM_frwrd_lft = !lft_rev ? lft_PWM_sig : 0;

assign PWM_rev_rght = rght_rev ? rght_PWM_sig : 0;
assign PWM_frwrd_rght = !rght_rev ? rght_PWM_sig : 0;


endmodule