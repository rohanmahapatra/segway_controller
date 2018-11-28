module SPI_mstr_16_tb();

localparam READ_1 = 15'h0C00;
localparam READ_2 = 15'h0C05;
localparam READ_3 = 15'h0BF5;
localparam READ_4 = 15'h0BF4;
localparam READ_5 = 15'h0BE4;

reg clk, rst_n;
reg wrt, MISO;
reg [15:0] cmd;

wire done, SS_n, SCLK;
wire [15:0] rd_data;

// DUTs
SPI_mstr16 iDUT_m(.clk(clk), .rst_n(rst_n), .wrt(wrt), .cmd(cmd), .SS_n(SS_n),
									.done(done), .rd_data(rd_data), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO));

ADC128S iDUT_s(.clk(clk), .rst_n(rst_n), .SS_n(SS_n), .SCLK(SCLK), .MISO(MISO), .MOSI(MOSI));

initial begin
	clk = 0;
	wrt = 0;
	rst_n = 0;
	@(negedge clk);
	@(negedge clk);
	rst_n = 1;

	repeat(20)
		@(negedge clk);
		
	// Read channel 5
	cmd = {2'b00, 3'b101, 11'h000};
	wrt = 1;
	@(posedge clk);
	wrt = 0;
	// wait for done to assert
	@(posedge done);
	if (rd_data != READ_1) begin
		$display("FAIL: expected: %h received: %h", READ_1, rd_data);
		$stop();
	end

	@(posedge clk);

	// Read channel 5
	cmd = {2'b00, 3'b101, 11'h000};
	wrt = 1;
	@(posedge clk);
	// wait for done to assert
	wrt = 0;
	@(posedge done);
	if (rd_data != READ_2) begin
		$display("FAIL: expected: %h received: %h", READ_2, rd_data);
		$stop();
	end
		
	@(posedge clk);

	// Read channel 4
	cmd = {2'b00, 3'b100, 11'h000};
	wrt = 1;
	@(posedge clk);
	wrt = 0;
	// wait for done to assert
	@(posedge done);
	if (rd_data != READ_3) begin
		$display("FAIL: expected: %h received: %h", READ_3, rd_data);
		$stop();
	end

	@(posedge clk);

	// Read channel 4
	cmd = {2'b00, 3'b100, 11'h000};
	wrt = 1;
	@(posedge clk);
	wrt = 0;
	// wait for done to assert
	@(posedge done);
	if (rd_data != READ_4) begin
		$display("FAIL: expected: %h received: %h", READ_4, rd_data);
		$stop();
	end

	@(posedge clk);
	
	// Read channel 4
	cmd = {2'b00, 3'b100, 11'h000};
	wrt = 1;
	@(posedge clk);
	wrt = 0;
	// wait for done to assert
	@(posedge done);
	if (rd_data != READ_5) begin
		$display("FAIL: expected: %h received: %h", READ_5, rd_data);
		$stop();
	end


	$display("PASSED!");
	$stop();
end

always begin
	#5 clk = ~clk;
end


endmodule
