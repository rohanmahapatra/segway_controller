module piezo_drv(clk, rst_n, moving, ovr_spd, batt_low, audio_o, audio_o_n);


// I/O Ports
input clk, rst_n;
input moving, batt_low, ovr_spd;
output audio_o, audio_o_n;


localparam BATT_LOW_THRESHOLD = 0x800;

// Wires

// generating 100 Hz pulse from 50 Mhz - but need to check and make it
// appropriate freq

reg [18:0] count_reg;
reg out_100hz = 0;

always @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		count_reg <= 0;
		out_100hz <= 0;
	end
	else begin
		out_100hz <= 0;
		if (count_reg < 499999) begin
			count_reg <= count_reg + 1;
		end else begin
			count_reg <= 0;
			out_100hz <= ~out_100hz;
		end
	end


end


always_comb begin

	if (moving) begin
		audio = out_100hz;
	
	end
	else if (ovr_spd || (batt_low > BATT_LOW_THRESHOLD)) begin
		audio_o = out_100hz;

	end


end


assign audio_o_n 	= ~audio_o;



endmodule
