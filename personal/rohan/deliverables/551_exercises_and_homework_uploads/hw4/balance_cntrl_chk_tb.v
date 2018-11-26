module balance_ctrl_chk_tb();

reg [31:0] stim[0:999];
reg [31:0] resp[0:999];
reg [31:0]addr;
reg rst_n,vld,rider_off,en_steer;
reg [11:0]ld_cell_diff;
reg [15:0]ptch;
wire rght_rev, lft_rev;
wire [10:0]rght_spd, lft_spd;
reg clk;

balance_cntrl iDUT(.clk(clk),.rst_n(rst_n),.vld(vld),.ptch(ptch),.ld_cell_diff(ld_cell_diff),
				   .lft_spd(lft_spd),.lft_rev(lft_rev),.rght_spd(rght_spd),.rght_rev(rght_rev),
				   .rider_off(rider_off),.en_steer(en_steer));

initial begin
clk = 0;

$readmemh("balance_cntrl_stim.hex", stim);
$readmemh("balance_cntrl_resp.hex", resp);

  for (addr = 0; addr < 1000 ; addr = addr+1) begin
	rst_n = stim[addr][31];
	vld = stim[addr][30];
	ptch = stim[addr][29:14];
	ld_cell_diff = stim[addr][13:2];
	rider_off = stim[addr][1];
	en_steer = stim[addr][0];
		$display("stim_input = %h" , stim[addr]);
		$display("stim_resp = %h" , {resp[addr][23],resp[addr][22:12],resp[addr][11],resp[addr][10:0]});
		repeat(1) @(negedge clk);
		$display("lft_spd = %h ; rght_spd = %h ; lft_rev = %b ; rght_rev = %b \n" , lft_spd , rght_spd, lft_rev , rght_rev);
	if (lft_rev == resp[addr][23] && lft_spd == resp[addr][22:12] &&  rght_rev == resp[addr][11] && rght_spd == resp[addr][10:0]) 
		$display("Test number - %d passed \n" , addr); 
	else begin
		$display("Test number %d Failed \n" , addr);
		$stop();
	end
  end
$display("YAHOO!! ALL TEST PASSED \n" , addr);
$stop();
end

always #5 clk = ~clk;


endmodule
