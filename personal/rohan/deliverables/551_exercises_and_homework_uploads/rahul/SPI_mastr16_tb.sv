module SPI_tb();

reg clk, rst_n;
reg [15:0]cmd;
reg wrt;
wire [15:0]rd_data;
wire SS_n, SCLK, MISO, MOSI;

SPI_master16 master(.clk(clk), .rst_n(rst_n), .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO) , .wrt(wrt), .cmd(cmd), .done(done), .rd_data(rd_data));
ADC128S slave(.clk(clk), .rst_n(rst_n) , .SS_n(SS_n), .SCLK(SCLK), .MISO(MISO), .MOSI(MOSI));

initial begin
  rst_n = 0;
  clk = 0;
  wrt = 0;
  cmd = 16'h0000; 
 
  repeat (2) @(negedge clk);

  rst_n = 1;
 
  wrt = 1;
  cmd = {2'b00,3'b101,11'h000};			// channel 5
  repeat (1) @(negedge clk);
  wrt = 0;

  repeat (600) @(negedge clk);			// wait for 600 cycles to complete the transactions
 if (rd_data == 12'hc00) 			
	$display("First transaction correct\n"); // check if the values are correct
  else begin 
	$display("First transaction Failed\n");
	$stop();
  end
  repeat (600) @(negedge clk);

  wrt = 1;
  cmd = {2'b00,3'b101,11'h000};			// channel 5
  repeat (1) @(negedge clk);
  wrt = 0;
 
  repeat (600) @(negedge clk);							// wait for 600 cycles to complete the transactions
  if (rd_data == 12'hc05) 
	$display("Second transaction correct\n");			// check if the values are correct
  else begin 
	$display("Second transaction Failed\n");
	$stop();
  end
  repeat (600) @(negedge clk);



  wrt = 1;
  cmd = {2'b00,3'b100,11'h000};			// channel 4
  repeat (1) @(negedge clk);
  wrt = 0;

  repeat (600) @(negedge clk);						// wait for 600 cycles to complete the transactions
  if (rd_data == 12'hbf5) 
	$display("Third transaction correct\n");			// check if the values are correct
  else begin 
	$display("Third transaction Failed\n");
	$stop();
  end
  repeat (600) @(negedge clk);


  wrt = 1;
  cmd = {2'b00,3'b100,11'h000};			// channel 4
  repeat (1) @(negedge clk);
  wrt = 0;

  repeat (600) @(negedge clk);									// wait for 600 cycles to complete the transactions
  if (rd_data == 12'hbf4) 
	$display("Fourth transaction correct\n");				// check if the values are correct
  else begin 
	$display("Fourth transaction Failed\n");
	$stop();
  end
  repeat (600) @(negedge clk);


//  $display("All transactions correct\n");		
  $stop();
end
  always #5 clk = ~clk;
endmodule
