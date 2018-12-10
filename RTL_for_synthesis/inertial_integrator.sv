////////////////////////////// Rahul Singh & Rohan Mahapatra ////////////////////////////////////////////////////////

module inertial_integrator(clk, rst_n, vld, ptch_rt, AZ, ptch);
//////////////////////////////////////// IO Ports ////////////////////////////////////////////////////////////////////
input clk, rst_n;
input vld;
input [15:0]ptch_rt;
input [15:0]AZ;
output signed [15:0]ptch;

//////////////////////////////////////// Internal Registers ////////////////////////////////////////////////////////////

logic signed[26:0]ptch_int;			// Pitch integrating accumulator. This is the register ptch_rtis summed into
logic signed[26:0]ptch_int_wire;			// Pitch integrating accumulator. This is the register ptch_rtis summed into
logic signed[15:0]ptch_rt_comp;
logic signed[25:0]ptch_acc_product;
logic signed[26:0]fusion_ptch_offset;
logic signed [15:0]AZ_comp;
logic signed [15:0]AZ_comp_sub;
logic signed[15:0]ptch_acc;
  /////////////////////////////////////////////
  // local params for increased flexibility //
  ///////////////////////////////////////////

localparam PTCH_RT_OFFSET = 16'h03C2;
localparam AZ_OFFSET = 16'hFE80;




///////////////////////////////////////// Digital Logic /////////////////////////////////////////////////////////////////


assign ptch_rt_comp = ptch_rt - PTCH_RT_OFFSET;		// to compensate the offset of inertial sensor

always @ (posedge clk, negedge rst_n) begin
  if (!rst_n)
	ptch_int <= 27'h0000000;
  else if(vld) 
	ptch_int <= ptch_int_wire;
end

assign ptch_int_wire =	 ptch_int - {{11{ptch_rt_comp[15]}}, ptch_rt_comp} + fusion_ptch_offset;
assign ptch = ptch_int[26:11];


////////// PITCH Fusion ///////////////////////////

assign AZ_comp_sub = AZ - AZ_OFFSET;	


always @ (posedge clk, negedge rst_n)
	if(!rst_n) AZ_comp <= 16'b0;
	else AZ_comp <= AZ_comp_sub; 

assign ptch_acc_product= AZ_comp * $signed(327); 		//327 is fudge factor
assign ptch_acc = {{3{ptch_acc_product[25]}},ptch_acc_product[25:13]};  		// pitch angle calculated from accel only
//rohan comment and added above
//assign AZ_comp = AZ - AZ_OFFSET;				


always_comb begin
  if (ptch_acc > ptch)		// if pitch calculated from accel> pitch calculated from gyro
	fusion_ptch_offset= 27'h0000400;
  else
	fusion_ptch_offset= 27'h7fffC00;
end
endmodule
