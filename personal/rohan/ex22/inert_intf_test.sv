module inert_intf_test(clk, RST_n, LED, MISO, MOSI, SS_n, SCLK, INT);

input clk, RST_n, MISO, INT;

output MOSI, SS_n, SCLK;

output [7:0] LED;

wire rst_n;

inert_intf i_inert_intf(.clk(clk), .rst_n(rst_n), .vld(),  .ptch(LED), .SS_n(SS_n), .MOSI(MOSI), .SCLK(SCLK), .MISO(MISO), .INT(INT));

reset_synch i_reset_synch (.RST_n(RST_n), .rst_n(rst_n), .clk(clk));


endmodule