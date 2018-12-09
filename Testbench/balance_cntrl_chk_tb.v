module balance_cntrl_chk_tb();

reg clk;

// Used to interate over the stimulus
reg [9:0] counter;

// stimulus in register
reg [31:0] stim;

// stimulus memory
reg [31:0] stimMem [0:999];

// stimulus expected response memory
reg [23:0] expResp [0:999];

// response wires
wire [23:0] resp;
wire too_fast;

//////////////////////
// Instantiate DUT //
////////////////////
balance_cntrl iDUT(.clk(clk),.rst_n(stim[31]),.vld(stim[30]),.ptch(stim[29:14]),
					.ld_cell_diff(stim[13:2]), .rider_off(stim[1]),.en_steer(stim[0]),
				  .lft_spd(resp[22:12]),.lft_rev(resp[23]),.rght_spd(resp[10:0]),.rght_rev(resp[11]), .pwr_up(1), .too_fast(too_fast));

// read in test stimulus and check against expected responses
initial begin
	// Read in stimulus and expected results
	$readmemh("./Testbench/balance_cntrl_stim.hex", stimMem);
	$readmemh("./Testbench/balance_cntrl_resp.hex", expResp);

	clk = 0;
	
	for (counter = 0; counter < 1000; counter = counter + 1) begin
		stim = stimMem[counter];
		@(posedge clk);
		#1;
		if (resp != expResp[counter]) begin
			$display("Failure: stim: %h, resp: %h, expResp: %h, counter: %d",
							stim, resp, expResp[counter], counter);
			$display("		rst_n: %b, vld: %b, ptch: %h ld_cell_diff: %h, rider_off: %b, en_steer: %b",
							stim[31], stim[30], stim[29:14], stim[13:2], stim[1], stim[0]);
			$stop();
		end else begin
			$display("Success: stim: %h, resp: %h, expResp: %h, counter: %d",
					stim, resp, expResp[counter], counter);
		end
	end
	$display("Test Passed!");
	$stop();

end


always
	#5 clk = ~clk;

endmodule
