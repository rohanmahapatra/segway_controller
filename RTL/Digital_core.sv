module Digital_core #(parameter fast_sim = 0)(clk,rst_n,pwr_up, lft_ld, rght_ld,
			batt, nxt, lft_spd, rght_spd, lft_rev, rght_rev, moving,
			ovr_spd, batt_low, SS_n, SCLK, MOSI, MISO, INT, rider_off_w);

localparam BATT_LOW_THRESHOLD = 12'h800;

//****************** I/O Ports **************************//
//*******************************************************//
input pwr_up; 	// coming from auth blk
input [11:0] lft_ld, rght_ld, batt;	// to and from A2D interface
//input fast_sim;		// Used to speed up simulation time
output nxt;

output [10:0] lft_spd;	// to mtr_drv
output [10:0] rght_spd;	// to mtr_drv
output lft_rev;
output rght_rev;

output moving, ovr_spd, batt_low;	// to piezo drv
output rider_off_w;
output SS_n, SCLK, MOSI;	// from and to inertial sensor
input MISO, INT;

input clk, rst_n;	// clk and async rst signal




//************* Wires, Regs & Logics*********************//
//*******************************************************//

logic en_steer_w, vld_w;
logic [15:0] ptch_w;
logic [11:0] ld_cell_diff_w;

//reg [18:0] cnt_val;
//******************** Submodules ***********************//
//*******************************************************//


//****************** I/O Ports **************************//
//*******************************************************//


//*******************************************************//

// To the piezo
assign moving = en_steer_w;

// batt_low enables the batt_low piezo sound
assign batt_low = (batt < BATT_LOW_THRESHOLD) ? 1'b1 : 1'b0;

// Get new A2D conversion when we get an inertial interrupt
assign nxt = INT;

steer_en #(.fast_sim(fast_sim)) i_steer_en (.clk(clk), .rst_n(rst_n), .lft_ld(lft_ld),.rght_ld(rght_ld), .ld_cell_diff(ld_cell_diff_w), .en_steer(en_steer_w), .rider_off(rider_off_w));
// lft_ld, rght_ld - input ; ld_cell_diff, en_steer, rider_off - output

inert_intf i_inert_intr (.clk(clk), .rst_n(rst_n), .vld(vld_w), .ptch(ptch_w), .SS_n(SS_n), .MOSI(MOSI), .SCLK(SCLK), .MISO(MISO), .INT(INT));
// vld, ptch, SS_n, MOSI, SCLK -output ; MISO,INT - input


balance_cntrl #(.fast_sim(fast_sim)) i_balance_cntr(.clk(clk), .rst_n(rst_n),.vld(vld_w),.ptch(ptch_w),.ld_cell_diff(ld_cell_diff_w),.lft_spd(lft_spd),.lft_rev(lft_rev),
		              .rght_spd(rght_spd),.rght_rev(rght_rev),.rider_off(rider_off_w), .en_steer(en_steer_w), .pwr_up(pwr_up), .too_fast(ovr_spd));
// vld, rider_off, en_steer - input ; ptch, ld_cell_diff - signed input;
// lft_spd, rght_spd, lft_rev, rght_rev - output

endmodule
