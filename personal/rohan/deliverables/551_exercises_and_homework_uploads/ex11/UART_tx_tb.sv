module UART_tx_tb();
	reg clk, rst_n, trmt;
	reg[7:0] tx_data;
	wire tx_done, TX;

UART_tx DUT(.clk(clk), .rst_n(rst_n), .trmt(trmt), .tx_data(tx_data), .tx_done(tx_done), .TX(TX));
	
	
	initial begin
		clk = 0;
		rst_n = 0;
		trmt = 0;
		tx_data = 0;
		#10;
		rst_n = 1;
		tx_data = 8'h75;
		#10;
		trmt = 1;
		#10
		trmt = 0;
		#350000;
		tx_data = 8'h42;
		trmt = 1;
		#10;
		trmt = 0;
		#350000;
		tx_data = 8'hf0;
		trmt = 1;
		#10;
		trmt = 0;
		#350000;
		$stop;
	end
	

always begin
		#5 clk = ~clk;
	end	

endmodule
