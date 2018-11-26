module SPI_mstr_16_tb();


  reg clk,rst_n;			// clock and active low asynch reset
  wire SS_n;				// active low slave select , since getting driven from always block hence reg type
  wire SCLK;				// Serial clock
  wire MOSI;				// serial data out from master
  wire MISO;				// serial data in to master
  reg [15:0] cmd;	// parallel data to be loaded to SPI maaster to be transmitted
  wire done;		//Asserted when SPI transaction is complete. Should stay asserted till next wrt  
  wire [15:0] rd_data;	// Data from SPI slave.
  
  reg wrt; 		


  reg [15:0] expected_resp[3:0];

SPI_mstr16 iDUT (.clk(clk),.rst_n(rst_n),.SS_n(SS_n),.SCLK(SCLK),.MISO(MISO),
		 .MOSI(MOSI),.wrt(wrt),.cmd(cmd),.done(done),.rd_data(rd_data));
 

ADC128S i_ADC_dut(.clk(clk),.rst_n(rst_n),.SS_n(SS_n),.SCLK(SCLK),.MISO(MISO),.MOSI(MOSI));

initial begin


rst_n = 1;
repeat(2) @(posedge clk);
@(negedge clk) rst_n = 0;
repeat(5) @(negedge clk)
rst_n =1 ;

// Sending the first packet
@(negedge clk) cmd = 15'h2800;

repeat(2) @(posedge clk);
wrt = 1;
repeat(1) @(posedge clk);
wrt = 0;
repeat(10) @(posedge clk);

while (done != 1) begin
repeat(1) @(posedge clk);
end


if (done == 1) begin
	if (rd_data == 16'hc00)
		$display("Received packet correct");
	else begin $display("received packet mismatch - exiting"); $stop(); end
end

@(negedge clk) cmd = 15'h2800;

repeat(2) @(posedge clk);
wrt = 1;
repeat(1) @(posedge clk);
wrt = 0;

repeat(10) @(posedge clk);
while (done != 1) begin
repeat(1) @(posedge clk);
end


if (done == 1) begin
	if (rd_data == 16'hc05)
		$display("Received packet correct");
	else begin $display("received packet mismatch - exiting"); $stop(); end
end


@(negedge clk) cmd = 15'h2000;

repeat(2) @(posedge clk);
wrt = 1;
repeat(1) @(posedge clk);
wrt = 0;

repeat(10) @(posedge clk);
while (done != 1) begin
repeat(1) @(posedge clk);
end



if (done == 1) begin
	if (rd_data == 16'hbf5)
		$display("Received packet correct");
	else begin $display("received packet mismatch - exiting"); $stop(); end
end

@(negedge clk) cmd = 15'h2000;

repeat(2) @(posedge clk);
wrt = 1;
repeat(1) @(posedge clk);
wrt = 0;




repeat(10) @(posedge clk);
while (done != 1) begin
repeat(1) @(posedge clk);
end



if (done == 1) begin
	if (rd_data == 16'hbf4)
		$display("Received packet correct");
	else begin $display("received packet mismatch - exiting"); $stop(); end
end



// intentianally reading wrong channel to generate error
$display("Intentiolally reading wrong channel");
@(negedge clk) cmd = 15'h3800;

repeat(2) @(posedge clk);
wrt = 1;
repeat(1) @(posedge clk);
wrt = 0;




repeat(10) @(posedge clk);
while (done != 1) begin
repeat(1) @(posedge clk);
end




$display("Intentiolally reading wrong channel");

// intentianally reading wrong channel to generate error
@(negedge clk) cmd = 15'h3800;

repeat(2) @(posedge clk);
wrt = 1;
repeat(1) @(posedge clk);
wrt = 0;




repeat(10) @(posedge clk);
while (done != 1) begin
repeat(1) @(posedge clk);
end




repeat(500) @(posedge clk);
$stop();

end

initial clk = 0;
always #5 clk = ~clk;


endmodule
