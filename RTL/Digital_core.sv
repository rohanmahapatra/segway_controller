module Digital_core(clk,rst_n,pwr_up,whl_spd_lft,whl_spd_rght, lft_ld, rght_ld, batt, nxt, lft_spd, rght_spd, lft_rev, rght_rev, moving, ovr_spd, batt_low, SS_n, SCLK, MOSI, MISO, INT);



//****************** I/O Ports **************************//
//*******************************************************//
input pwr_up; 	// coming from auth blk
input whl_spd_lft, whl_spd_rght;	// from optical sensors
input [11:0] lft_ld, rght_ld, batt;	// to and from A2D interface
output nxt;

output [11:0] lft_spd, rght_spd;	// to mtr_drv
output lft_rev, rght_rev;

output moving, ovr_spd, batt_low;	// to piezo drv

output SS_n, SCLK, MOSI;	// from and to inertial sensor
input MISO, INT; 

input clk, rst_n;	// clk and async rst signal




//************* Wires, Regs & Logics*********************//
//*******************************************************//

logic rider_off_w, en_steer_w, vld_w;
logic [15:0] ptch_w;
logic [11:0] ld_cell_diff_w;


//******************** Submodules ***********************//
//*******************************************************//


//****************** I/O Ports **************************//
//*******************************************************//


//*******************************************************//




steer_en i_steer_en(.clk(clk), .rst_n(rst_n), .lft_ld(lft_ld),.rght_ld(rght_ld), .ld_cell_diff(ld_cell_diff_w), .en_steer(en_steer_w), .rider_off(rider_off_w) ); 
// lft_ld, rght_ld - input ; ld_cell_diff, en_steer, rider_off - output

inert_intr i_inert_intr (.clk(clk), .rst_n(rst_n), .vld(vld_w), .ptch(ptch_w), .MOSI(MOSI), .SCLK(SS_n), .MISO(MISO), .INT(INT));  
// vld, ptch, SS_n, MOSI, SCLK -output ; MISO,INT - input

 
balance_cntrl i_balance_cntr (.clk(clk), .rst_n(rst_n),.vld(vld_w),.ptch(ptch_w),.ld_cell_diff(ld_cell_diff_w),.lft_spd(lft_spd),.lft_rev(lft_rev),
		              .rght_spd(rght_spd),.rght_rev(rght_rev),.rider_off(rider_off_w), .en_steer(en_steer_w));
// vld, rider_off, en_steer - input ; ptch, ld_cell_diff - signed input;
// lft_spd, rght_spd, lft_rev, rght_rev - output


endmodule