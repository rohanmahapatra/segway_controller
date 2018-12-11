// Adam Czech & Jacob Hulten
module inertial_integrator(clk, rst_n, vld, ptch_rt, AZ, ptch);

localparam AZ_OFFSET = 16'hFE80;
localparam PTCH_RT_OFFSET = 16'h03C2;

// Inputs
input clk, rst_n;
input vld;
input signed [15:0] ptch_rt;
input [15:0] AZ;

// Outputs
output signed [15:0] ptch;

// Internals
reg [26:0] ptch_int;
reg [26:0] fusion_ptch_offset;
wire signed [25:0] ptch_acc_product;
wire [15:0] AZ_comp;
wire signed [15:0] ptch_acc;
wire signed [15:0] ptch_rt_comp;

assign AZ_comp = AZ - AZ_OFFSET;
assign ptch_acc_product = AZ_comp * $signed(327);			// 327 is fudge value
assign ptch_acc = {{3{ptch_acc_product[25]}},ptch_acc_product[25:13]}; // pitch angle calc from accel only
assign ptch_rt_comp = ptch_rt - PTCH_RT_OFFSET;

// assign ptch output
assign ptch = ptch_int[26:11];

// if (ptch from accel) > (ptch calc from gyro) set to 512
// otherwise set -512
always @ (posedge clk, negedge rst_n) begin
	if (!rst_n)
		fusion_ptch_offset <= 27'h0000000;
	else if (ptch_acc > ptch)
		fusion_ptch_offset <= 1024;
	else
		fusion_ptch_offset <= -1024;
end

// Add fusion_ptch_offset into the next integration of ptch_int on every
// valid reading from the inertial sensor. ptch_rt_comp is also integrated into
// ptch_int on every valid reading.
always @ (posedge clk, negedge rst_n) begin
	if (!rst_n)
		ptch_int <= 27'h0000000;
	else if(vld)
		ptch_int <= ptch_int - {{11{ptch_rt_comp[15]}}, ptch_rt_comp} + fusion_ptch_offset;
	else
		ptch_int <= ptch_int;
end


endmodule
