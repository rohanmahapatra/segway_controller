module piezo_drv(clk, rst_n, moving, ovr_spd, batt_low, audio_o, audio_o_n);


// I/O Ports
input clk, rst_n;
input moving, batt_low, ovr_spd;
output reg audio_o, audio_o_n;
wire pulse;

localparam BATT_LOW_THRESHOLD = 'h800;

wire clk_sec;

reg clk_1Hz = 1'b0;
reg [28:0] counter;	// 28 bits for 1 Hz and 29 bits for 0.5 hz

always@(posedge clk, negedge rst_n)	begin
	if (!rst_n) begin
    		counter <= 0;
        end
	else if (counter == 50_000_000) begin
		counter <= 0;		
	end	
	else counter <= counter + 1;
end


assign clk_sec = ((counter == 10_000_000) || (counter ==20_000_000) || (counter == 30_000_000) || (counter == 40_000_000) || (counter == 50_000_000)) ? 1: 0;
assign clk_1hz_1sec = (counter == 25_000_000 || counter == 50_000_000) ? 1 : 0;
assign clk_0p5hz_2sec = (counter == 50_000_000) ? 1: 0;


always_comb begin

	if (moving && clk_0p5hz_2sec) begin
		audio_o = pulse;
	
	end
	else if ((ovr_spd || (batt_low > BATT_LOW_THRESHOLD)) && clk_sec) begin
		audio_o = pulse; 
	end
	else if (ovr_spd && clk_1hz_1sec) begin
		audio_o = pulse;
	end
	else if ((batt_low > BATT_LOW_THRESHOLD) && clk_1hz_1sec) begin
		audio_o = pulse;
	end


end


assign audio_o_n 	= ~audio_o;


// drive 5Khz pulse to the piezo device at varied periods depending upon the
// input signal

clk_div i_clk_div (.clk(clk),.rst_n(rst_n),.clk_out(pulse));


endmodule



////// Clock divider module
module clk_div
#( 
	parameter WIDTH = 13, 		// Width of the register required; log2(5000)
	parameter N = 5000		// We will divide by 10,000 to get 5Khz clock
)
(clk,rst_n, clk_out);
 
input clk;
input rst_n;
output clk_out;
 
reg [WIDTH-1:0] r_reg;
wire [WIDTH-1:0] r_nxt;
reg clk_track;
 
always @(posedge clk or negedge rst_n)
	 
begin
	if (!rst_n) begin
		r_reg <= 0;
		clk_track <= 1'b0;
        end
       	else if (r_nxt == N) begin
     		r_reg <= 0;
     	     	clk_track <= ~clk_track;
  	end
	else 
		r_reg <= r_nxt;
end
		    
assign r_nxt = r_reg+1;   	      
assign clk_out = clk_track;

endmodule
