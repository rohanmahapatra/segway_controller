module rst_synch (RST_n, clk, rst_n);

input RST_n,clk;
output reg rst_n;


reg rst_w;

always_ff @ (negedge clk) begin
	if (!RST_n) begin			
		rst_w  <= 1'b1;
		rst_n  <= rst_w;
	end
end
	

endmodule
