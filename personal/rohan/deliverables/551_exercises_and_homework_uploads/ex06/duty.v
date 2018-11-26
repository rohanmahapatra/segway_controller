
module duty(ptch_D_diff_sat, ptch_err_sat, ptch_err_I, rev, mtr_duty);
 

localparam MIN_DUTY = 15'h03D4;
input signed [6:0] ptch_D_diff_sat;          // 7-bit signed number (represents derivative of error)
input signed [9:0] ptch_err_sat;                 // 10-bit pitch error term (signed)
input signed [9:0] ptch_err_I;     // 10-bit integral of the error term (signed)
output reg rev;                                  //Rev means we are driving motor in reverse (1=>reverse, 0=>forward)
output reg [11:0] mtr_duty;                        // Duty cycle of PWM drive to motor
 
reg [11:0] ptch_D_term;
reg [10:0] ptch_PID_abs;
reg [9:0] ptch_P_term;
reg [9:0] ptch_I_term;
reg [10:0] ptch_PID;
//reg [10:0] abs_in, abs_out;
 
 
//reg signed [5:0] x;
 
always@(*)
begin
//x = {1'b0,$signed('d9)};		// should be fine as well since we manually ensure this to be signed
//ptch_D_term = ptch_D_diff_sat * x;     	//where ptch_D_termis an internal signal (a multi-bit wide wire). How wide does ptch_D_termneed to be? 
					//How do you convince it to perform a signed multiplication?
ptch_D_term = ptch_D_diff_sat * $signed('d9);
 
ptch_P_term =  (ptch_err_sat>>>1) + (ptch_err_sat>>>2); //Where ptch_P_termis an internal signal. Hmmm ¾ = ½ + ¼ ?can I get that result without using a multiplier?

ptch_I_term = ptch_err_I>>>1;   //Where ptch_I_termis an internal signal. Arithmetic right shift, ptch_err_I still signed.
 
ptch_PID = ptch_P_term + ptch_I_term + ptch_D_term;
 
//task ABS;
//  begin
//   assign abs_out = abs_in[10] ? ((~abs_in) + 1) : abs_in; 
//  end
//endtask
 
//The most significant bit of ptch_PID will form the output rev. If ptch_PIDis negative we will be driving the motor backwards.
//5. ptch_PID_abs= ABS(ptch_PID)
//Make yet another internal signal which is the absolute value of ptch_PID
 
//ABS(ptch_PID, ptch_PID_abs);
ptch_PID_abs = ptch_PID[10] ? ((~ptch_PID) + 1) : ptch_PID; 
 
rev = ptch_PID[10];
//Finally form the output mtr_duty(which is an unsigned number) and represents how hard the motor should be driven (either in forward or reverse).
//6. mtr_duty= MIN_DUTY+ ptch_PID_abs
 
mtr_duty = MIN_DUTY + ptch_PID_abs;  // should be 12:0 but since MIN_DUTY is defined in such a way that this does not overflow. 
 
 
end
 
endmodule
 