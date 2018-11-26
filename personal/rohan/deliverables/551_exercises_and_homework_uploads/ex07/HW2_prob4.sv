/*

****************** Q4 Part A  *******************
module latch(d,clk,q);
input d, clk;
output reg q;
always @(clk)
if (clk)
q <= d;
endmodule

Q. Is this code correct? If so why does it correctly infer and model 
	a latch? If not, what is wrong with it?
Answer: No, the implementation of the latch is not correct because it does not satisfy
the basic property of a latch i.e., a latch is transparent when the clock is high. In other words,
the output of the latch should reflect the input value when clock is high but in the code this is not
the case because the sensitivity list in always does not contain the input. 

For example: if D is low during simulation 
Clk 	D	Q
1	0	0
1	1	0 (because always block is not triggered when value of D changes)
0	1	0
1	1	1
		 
*/

/*  

*************** Q4 Part B ****************
Model of a D-FF with an active high synchronous reset

*/
module D_FF_syn_rst (D, Q,clk,rst); 
input D;
input clk;
input rst;
output reg Q;

always_ff @ (posedge clk)
begin
	if(rst)	// active high sync reset
	 Q <= 1'd0;
	else
	 Q <= D; 
end

endmodule
 
/*  

*************** Q4 Part C ****************
Model of a D-FF with asynchronous active low reset and an active high enable.

*/
module D_FF_async_rst (d,q,clk,rst_n,en);

input d;
input clk;
input rst_n;
input en;
output reg q;

always_ff @ (posedge clk or negedge rst_n)
//always_ff @ (posedge clk or negedge rst_n)  // Can be written like this in System Verilog
begin
    if (!rst_n) begin
        q <= 0;
    end 
    else if (en) begin
        q <= d;
    end
end                
endmodule

/*  

*************** Q4 Part C ****************
Model of a SR FF with active low asynchronous reset.
SR meaning it has a S input that will set the flop, 
and a R input that will reset the flop, and it maintains state
if neither S or R are high. It also has active low async reset. 
This is a handy style flop that we will use frequently.

*/

module srff_async_rst(q1,q1_b,r,s,clk,rst_n);
	input rst_n;
	input r,s,clk;
	output reg q1,q1_b;
//	initial
//	begin
//		q1=1'b0;
//		q1_b=1'b1;
//	end
	
	/*
Q. Does the use of the always_ff construct ensure the logic will infer a flop?
Answer: 
The always_ff construct helps document the designer's intent to represent flipflop. 	
These construct can prevent modeling issues and enable synthesis tools to verify that design intent
has been met. It flags synthesis warnings when there is a mismatch between the designers intent and 
the systhesized output. These outputs can help designer to recfity any possible coding errors.
Additionaly, these constructs need clock name and/or reset as a part of its sensitivity.


    	*/
 //always @(posedge clk or negedge rst_n)
always_ff @(posedge clk or negedge rst_n)

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



