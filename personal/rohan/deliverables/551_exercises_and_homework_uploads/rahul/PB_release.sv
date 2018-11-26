module PB_release(PB, released, rst_n, clk);
input PB, clk, rst_n;
output released;
logic q1, q2, q3;

always_ff @ (posedge clk, negedge rst_n) begin		

	if (!rst_n) begin 
		q1 <= 1'b1;		// asynchronous preset
		q2 <= 1'b1;
		q3 <= 1'b1;
	end
	else begin
		q1 <= PB;
		q2 <= q1;
		q3 <= q2;
	end

end

assign released = q3 & (~q2);

endmodule
