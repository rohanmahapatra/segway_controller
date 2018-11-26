module PB_release (PB, rst_n, clk, released);

input PB, clk, rst_n;
output released;

reg pre_1, pre_2, pre_3;

always_ff @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		pre_1 <= 1'b1;		// since tied high on the board	
		pre_2 <= 1'b1;
		pre_3 <= 1'b1;
	end 
	else begin
		pre_1 <= PB;
		pre_2 <= pre_1;
		pre_3 <= pre_2;
	end

end

assign released = pre_2 + (~pre_3);

endmodule
