module Auth_blk_tb();

reg clk, rst_n;
reg trmt;
wire TX;
reg [7:0]tx_data;
wire tx_done;
wire pwr_up;
reg rider_off;


UART_tx Tx(.clk(clk), .rst_n(rst_n), .trmt(trmt), .TX(TX), .tx_data(tx_data), .tx_done(tx_done));
Auth_blk auth(.clk(clk), .rst_n(rst_n), .pwr_up(pwr_up), .RX(TX), .rider_off(rider_off));

initial begin
clk = 0;
rst_n = 0;
trmt = 0;
rider_off = 0;
tx_data = 8'h00;
repeat(3) @(negedge clk);
rst_n = 1;

/////////////////////////////////// Transmit a GO ////////////////////////////////////////////////
repeat(3) @(negedge clk);
trmt = 1;				// trmt is high for a clock cycle
@(negedge clk);
trmt = 0;

tx_data = 8'h67;

repeat(35000) @(negedge clk);

/////////////////////////////////// Transmit a Stop /////////////////////////////////////////////

trmt =1;
@(negedge clk);
trmt = 0;
tx_data = 8'h73;
repeat(35000) @(negedge clk); 



/////////////////////////////////// Transmit a GO ////////////////////////////////////////////////
repeat(3) @(negedge clk);
trmt = 1;
@(negedge clk);
trmt = 0;

tx_data = 8'h67;

repeat(35000) @(negedge clk);

/////////////////////////////////// Transmit a Stop /////////////////////////////////////////////

trmt =1;
@(negedge clk);
trmt = 0;
tx_data = 8'h73;
repeat(35000) @(negedge clk); 

//////////////////////////////////// Rider Gets off /////////////////////////////////////////////

rider_off = 1;



repeat(3) @(negedge clk);
rider_off = 1'b0;
repeat(3500) @(negedge clk); 
$stop();

end

always #5 clk = ~clk;
endmodule

