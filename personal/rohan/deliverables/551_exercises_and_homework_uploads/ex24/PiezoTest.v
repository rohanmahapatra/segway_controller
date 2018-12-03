module PiezoTest(clk,RST_n,en_steer,ovr_spd,batt_low,piezo,piezo_n);

input clk,RST_n;
input en_steer;		// make short periodic sound when steering enabled
input ovr_spd; 		// make longer abnoxious sound when too_fast asserted
input batt_low;		// should be able to make too_fast and batt_low sounds simultaneously if requested

output piezo;		// drives piezo
output piezo_n;		// drive is differential to increase volume

wire rst_n;

  ////// instantiate your piezo block here /////
 pieze_drv i_piezo_drv (.clk(clk), .rst_n(rst_n), .moving(en_steer), .ovr_spd(ovr_spd), .batt_low(batt_low), .audio_o(piezo), .audio_o_n(piezo_n)) ;
  reset_synch iRST(.clk(clk),.RST_n(RST_n),.rst_n(rst_n)); 
  endmodule
