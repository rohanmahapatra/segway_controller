module UART_tb();

reg clk,rst_n; 	
reg RX; 	
reg clr_rdy; 		
wire [7:0] cmd;	 // CMD
wire rdy; 		

//reg trmt;		
reg [7:0] tx_data;	
		
wire tx_done;	
logic load, transmitting, shift, set_done, clr_done; 	
logic [3:0] bit_cnt;

logic channel, chn_1;
reg trmt;



//instantiating UART Transmitter
UART_tx idut_tx(.clk(clk), .rst_n(rst_n), .trmt(trmt), .tx_data(tx_data), .tx_done(tx_done), .TX(channel));

//instantiating UART Receiver
UART_rcv idut_rcv(.clk(clk), .rst_n(rst_n), .RX(channel), .clr_rdy(clr_rdy), .cmd(cmd), .rdy(rdy));


	
	initial begin
		clk = 0;
		rst_n = 0;
		trmt = 0;
		tx_data = 0;
		#10;
		rst_n = 1;
		tx_data = 8'h75;
		repeat(1) @(negedge clk);
		trmt = 1;
		repeat(1) @(negedge clk);
		trmt = 0;
		
		repeat(350000) begin 
			@(negedge clk); 
			if(!channel) begin
			clr_rdy = 1;
			end 
		end
		if(tx_data == cmd) begin
		$display("Data Matched - successful");		
		end
		else begin $display("Data mismatch"); $stop(); end
		tx_data = 8'h42;
		trmt = 1;
		#10;
		trmt = 0;
		repeat(350000) @(negedge clk);
		tx_data = 8'hf0;
		trmt = 1;
		#10;
		trmt = 0;
		repeat(350000) @(negedge clk);
		$stop;
	end
	

always begin
		#5 clk = ~clk;
	end	

endmodule