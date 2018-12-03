module inert_intf_tb();



reg clk, rst_n;

wire [15:0] ptch;

wire vld;



inert_intf inst_inert_intf(.clk(clk), .rst_n(rst_n), .vld(vld),  .ptch(ptch), .SS_n(SS_n), .MOSI(MOSI),

			    .SCLK(SCLK), .MISO(MISO), .INT(INT));



SegwayModel inst_segwaymodel (.clk(clk),.RST_n(rst_n),.SS_n(SS_n),.SCLK(SCLK),.MISO(MISO),

		.MOSI(MOSI),.INT(INT),.PWM_rev_rght(1'b0),.PWM_frwrd_rght(1'b0),

                   .PWM_rev_lft(1'b0),.PWM_frwrd_lft(1'b0),.rider_lean(16'h0100));

  //////////////////////////////////////////////////

 



initial begin

	clk = 0;

	rst_n = 1;

	@(posedge clk);

	rst_n = 0;

	@(posedge clk);

	@(negedge clk);

	rst_n = 1;



	repeat(200000) @(posedge clk);

	$stop();

end



always #5 clk = ~clk;



endmodule
