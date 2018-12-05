module piezo_drv(clk, rst_n, moving, ovr_spd, batt_low, audio_o, audio_o_n);

parameter FAST_SIM_O = 0;
// I/O Ports
input clk, rst_n;
input moving, batt_low, ovr_spd;
output reg audio_o, audio_o_n;

localparam BATT_LOW_THRESHOLD = 'h800;

wire batt_l;
assign batt_l = (batt_low < BATT_LOW_THRESHOLD);

//reg clk_1Hz;
//assign clk_1Hz = 1'b0;
reg [27:0] counter;	// 28 bits for 1 Hz and 29 bits for 0.5 hz

always@(posedge clk, negedge rst_n)	begin
	if (!rst_n) begin
    		counter <= 0;
        end

	else counter <= counter + 1;
end

always_comb begin
	if (!FAST_SIM_O) begin
	if (ovr_spd && batt_low) 	audio_o = counter[23];
	else if (ovr_spd) 		audio_o = counter[24];
	else if (batt_low)		audio_o = counter[25];
	else if(moving)			audio_o = counter[26];
	else audio_o = 0;
	end
	else begin
	if (ovr_spd && batt_low) 	audio_o = counter[2];
	else if (ovr_spd) 		audio_o = counter[3];
	else if (batt_low)		audio_o = counter[4];
	else if(moving)			audio_o = counter[5];
	else audio_o = 0;
	end
end

assign audio_o_n = audio_o;

endmodule
