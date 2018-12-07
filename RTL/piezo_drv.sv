module piezo_drv(clk, rst_n, moving, ovr_spd, batt_low, audio_o, audio_o_n);

// I/O Ports
input clk, rst_n;
input moving, batt_low, ovr_spd;
output reg audio_o;
output audio_o_n;

// TODO: where is BATT_LOW set? Does it use the threshold?
//localparam BATT_LOW_THRESHOLD = 'h800;

reg [26:0] counter;	// 27 bits with bit 0 toggles at 25 MHz

always@(posedge clk, negedge rst_n)	begin
	if (!rst_n)
		counter <= 0;
	else 
		counter <= counter + 1;
end

//
// over speed should be most alerting and battery low the seocnd most alerting.
// Both over speed and battery can occur at the same time. Moving should occur
// approx. every ~2 seconds and be short bursts.
// 
// Bit 26 toggles at 2.68 seconds
// Piezo is audible bits 12-16
//
always_comb begin
	if (ovr_spd && counter[23])
		audio_o = counter[13];
	else if (batt_low && counter[24])
		audio_o = counter[14];
	else if(moving && &(counter[26:23]) && !ovr_spd && !batt_low)
		audio_o = counter[16];
	else 
		audio_o = 0;
end

assign audio_o_n = ~audio_o;

endmodule
