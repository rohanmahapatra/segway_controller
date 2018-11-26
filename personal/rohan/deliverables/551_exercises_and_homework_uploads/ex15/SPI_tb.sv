module SPI_tb();


  reg clk,rst_n;			// clock and active low asynch reset
  wire SS_n;				// active low slave select , since getting driven from always block hence reg type
  wire SCLK;				// Serial clock
  wire MOSI;				// serial data out from master
  wire MISO;				// serial data in to master
  reg [15:0] cmd;	// parallel data to be loaded to SPI maaster to be transmitted
  wire done;		//Asserted when SPI transaction is complete. Should stay asserted till next wrt  
  wire [15:0] rd_data;	// Data from SPI slave.
  
  reg wrt; 		


SPI_mstr16 iDUT (.clk(clk),.rst_n(rst_n),.SS_n(SS_n),.SCLK(SCLK),.MISO(MISO),
		 .MOSI(MOSI),.wrt(wrt),.cmd(cmd),.done(done),.rd_data(rd_data));
 

ADC128S i_ADC_dut(.clk(clk),.rst_n(rst_n),.SS_n(SS_n),.SCLK(SCLK),.MISO(MISO),.MOSI(MOSI));


initial begin

rst_n = 1;
repeat(2) @(posedge clk);
@(negedge clk) rst_n = 0;
repeat(5) @(negedge clk)
rst_n =1 ;
@(negedge clk) cmd = 15'h5000;

repeat(2) @(posedge clk);
wrt = 1;
repeat(1) @(posedge clk);
wrt = 0;

while (done != 1) begin
repeat(1) @(posedge clk);
end

@(negedge clk) cmd = 15'h5000;

repeat(2) @(posedge clk);
wrt = 1;
repeat(1) @(posedge clk);
wrt = 0;

while (done != 1) begin
repeat(1) @(posedge clk);
end

@(negedge clk) cmd = 15'h4000;

repeat(2) @(posedge clk);
wrt = 1;
repeat(1) @(posedge clk);
wrt = 0;


while (done != 1) begin
repeat(1) @(posedge clk);
end

@(negedge clk) cmd = 15'h4000;

repeat(2) @(posedge clk);
wrt = 1;
repeat(1) @(posedge clk);
wrt = 0;

repeat(100) @(posedge clk);
$stop();

end

initial clk = 0;
always #5 clk = ~clk;


endmodule
