module piezo_tb();

reg clk, rst_n;
reg moving, batt_low, ovr_spd;
wire audio_o, audio_o_n;

piezo_drv i_pieze_drv (.clk(clk), .rst_n(rst_n), .moving(moving), .ovr_spd(ovr_spd), .batt_low(batt_low), .audio_o(audio_o), .audio_o_n(audio_o_n));

initial begin

	repeat(1) @(negedge clk)
	rst_n = 1;

	repeat(2) @(negedge clk)
	rst_n = 0;
	repeat(5) @(negedge clk)
	rst_n = 1;
	repeat(100) begin
	@(negedge clk)
	ovr_spd = 1;
	end
	repeat(100) begin 
	@(negedge clk)
	ovr_spd = 0;
	batt_low = 1;
	end
	repeat(100) begin
	@(negedge clk)
	batt_low = 0;
	moving = 1;
	end
	repeat(100) begin
	@(negedge clk)
	moving = 0;
	end
	

	repeat(100)  begin
	@(negedge clk);	
	batt_low = 1;
	ovr_spd = 1;
	end
	repeat(100) @(negedge clk)
	$stop();
end



initial clk = 0;
always #5 clk = ~clk;


endmodule
