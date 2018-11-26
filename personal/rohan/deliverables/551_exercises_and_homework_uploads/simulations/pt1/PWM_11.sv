module srff_async_rst(q1,q1_b,r,s,clk,rst_n);
	input rst_n;
	input r,s,clk;
	output reg q1,q1_b;
//	initial
//	begin
//		q1=1'b0;
//		q1_b=1'b1;
//	end
	always_ff @(posedge clk or negedge rst_n)
	/*
Does the use of the always_ff construct ensure the logic will infer a flop?
Answer: 
The always_ff construct helps document the designer's intent to represent flipflop. 	
These construct can prevent modeling issues and enable synthesis tools to verify that design intent
has been met. It flags synthesis warnings when there is a mismatch between the designers intent and 
the systhesized output. These outputs can help designer to recfity any possible coding errors.
Additionaly, these constructs need clock name and/or reset as a part of its sensitivity.


    	*/
	  begin
	if(!rst_n) begin
		q1  <= 1'b0;
		q1_b <= 1'b1;
	end
	else begin
	  case({s,r})
		 {1'b0,1'b0}: begin q1 <= q1;   q1_b <= q1_b; end
		 {1'b0,1'b1}: begin q1 <= 1'b0; q1_b <= 1'b1; end
		 {1'b1,1'b0}: begin q1 <= 1'b1; q1_b <= 1'b0; end
		 {1'b1,1'b1}: begin q1 <= 1'bx; q1_b <= 1'bx; end
	endcase
	end
end
endmodule



module PWM11 (clk, rst_n, duty, PWM_sig);
  
parameter n = 10;
 
input clk; // 50MHz clock
input rst_n; //Active low asynch reset
input [10:0] duty; // Result from balance controller telling how fast to run each motor. 
output PWM_sig; // Output to the H-bridge chip controlling the DC motor.

reg [n:0] count;


logic PWM_sig_n, s, r;

  // Set the initial value
 // initial
  //  count = 0;
 
  // Increment count on clock
  always_ff @(posedge clk or negedge rst_n)
 	begin
	    if (!rst_n)
	      count <= 11'b0;
	    else
	      count <= count + 1;   // broken one of the rule by inferring the comb in non-blocking but since the intent is met, we are fine.
 		// does not take multiple passes to evaluate
	end


always_comb
begin
if (count>=duty)
begin
	s = 0;
	r = 1;
end
else if (count == 0)
begin
	s = 1;
	r = 0;
end
end


//assign block is like always @ * so logically almost the same.

srff_async_rst i_srff  (.q1(PWM_sig) , 
			.q1_b(PWM_sig_n),
			.r(r),
			.s(s),
			.clk(clk),
			.rst_n(rst_n));


endmodule 
