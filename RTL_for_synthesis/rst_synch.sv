// Asynchronous reset

module rst_synch(RST_n, rst_n, clk);
input RST_n, clk;
output reg rst_n;
logic q1;					// intermediate between two flops

always_ff @(negedge clk, negedge RST_n) begin

	if (!RST_n) begin 			// two flops for metastability purposes
		q1 <= 1'b0;			// asynchronous reset of two flops
		rst_n <= 1'b0;			
	end 
	else begin
		q1 <= 1'b1;			// at negative edge the reset is de-asserted
		rst_n <= q1;
	end	
end
endmodule
