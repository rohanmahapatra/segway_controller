// Name : Rohan Mahapatra & Rahul Singh 
module balance_cntrl(clk,rst_n,vld,ptch,ld_cell_diff,lft_spd,lft_rev,
                     rght_spd,rght_rev,rider_off, en_steer);
								
  input clk,rst_n;
  input vld;						// tells when a new valid inertial reading ready
  input signed [15:0] ptch;			// actual pitch measured
  input signed [11:0] ld_cell_diff;	// lft_ld - rght_ld from steer_en block
  input rider_off;					// High when weight on load cells indicates no rider
  input en_steer;
  output [10:0] lft_spd;			// 11-bit unsigned speed at which to run left motor
  output lft_rev;					// direction to run left motor (1==>reverse)
  output [10:0] rght_spd;			// 11-bit unsigned speed at which to run right motor
  output rght_rev;					// direction to run right motor (1==>reverse)
  
  ////////////////////////////////////
  // Define needed registers below //
  //////////////////////////////////
  
  
  ///////////////////////////////////////////
  // Define needed internal signals below //
  /////////////////////////////////////////

  /////////////////////////////////////////////
  // local params for increased flexibility //
  ///////////////////////////////////////////
  localparam P_COEFF = 5'h0E;
  localparam D_COEFF = 6'h14;				// D coefficient in PID control = +20 
    
  localparam LOW_TORQUE_BAND = 8'h46;	// LOW_TORQUE_BAND = 5*P_COEFF
  localparam GAIN_MULTIPLIER = 6'h0F;	// GAIN_MULTIPLIER = 1 + (MIN_DUTY/LOW_TORQUE_BAND)
  localparam MIN_DUTY = 15'h03D4;		// minimum duty cycle (stiffen motor and get it ready)
  
  //// You fill in the rest ////
  
  /// P term calculations ////
 
wire signed [9:0] ptch_err_sat;

wire signed [14:0] ptch_p_term;
//assign ptch_err_sat = ptch[15] ? (&ptch[14:9] ? {ptch[15],ptch[8:0]} : 10'h200 ) : (|ptch[14:9]) ? 10'h1ff : {ptch[15],ptch[8:0]}  ; 
assign ptch_p_term = $signed(P_COEFF) * ptch_err_sat;		// could have been 1 extra bit while type casting.  


assign ptch_err_sat = (ptch[15] && ~&ptch[14:9]) ?  10'h200 :  (~ptch[15] && | ptch[14:9]) ? 10'h1FF : ptch[9:0];

// I calculations //
wire [17:0] ptch_err_sat_ex;
wire [18:0] accum_ptch_err_sat;			// is this required to be signed?
reg [17:0] integrator;				// only bits 17:6 are consumed later when P,I and D terms are combined
wire overflow_accum;
wire [17:0] mux_i1_out, mux_i2_out;				// need not be 19 bits as depending oin the overflow itself we are moving forward 


assign ptch_err_sat_ex = {{8{ptch_err_sat[9]}}, ptch_err_sat[9:0]}; 		// sign extending ptch_err_sat to 18 bits
assign accum_ptch_err_sat = ptch_err_sat_ex + integrator;
assign overflow_accum = (!ptch_err_sat_ex[17] & !integrator[17]) & accum_ptch_err_sat[17]  | (ptch_err_sat_ex[17] & integrator[17]) & !accum_ptch_err_sat[17];
assign and_o = vld & !overflow_accum;
assign  mux_i1_out = and_o ? accum_ptch_err_sat : integrator ;
assign mux_i2_out = rider_off ? 18'h00000 : mux_i1_out ;

always @ (posedge clk, negedge rst_n) begin
	if (!rst_n) integrator <= 18'h00000;
	else integrator <= mux_i2_out;
end

// D calculations //

wire [9:0] D_net1, ptch_d_diff;
wire signed [6:0]  ptch_d_diff_sat; 
reg [9:0] D_reg1, D_reg2;


wire signed [12:0] ptch_d_term;
always @ (posedge clk, negedge rst_n) begin

	if(!rst_n) begin
		D_reg1 <= 10'h000;
		D_reg2 <= 10'h000;
	end
	else if (vld) begin
		D_reg1 <= ptch_err_sat;
		D_reg2 <= D_reg1;
	end

end

// 2'compkliment of previous ptch erro term

assign D_net1 = ~D_reg2 + 1;
assign ptch_d_diff = D_net1 + ptch_err_sat;
// check if these numbers has to be explicitely signed?
//assign ptch_d_diff_sat = ptch_d_diff[9] ? (&ptch_d_diff[8:7] ? {ptch_d_diff[9],ptch_d_diff[5:0]} : 7'h40) : (|ptch_d_diff[8:7] ? (7'h3f) : ({ptch_d_diff[9],ptch_d_diff[5:0]}));  
assign ptch_d_diff_sat = (ptch_d_diff[9] && ~&ptch_d_diff[8:6]) ? 7'h40 :(~ptch_d_diff[9]&& |ptch_d_diff[8:6]) ? 7'h3f : ptch_d_diff[6:0] ;
assign ptch_d_term = ptch_d_diff_sat * $signed(D_COEFF);


// PID Math - putting all together //

wire signed [15:0] PID_cntrl;
assign PID_cntrl = {ptch_p_term[14],ptch_p_term} + {{4{integrator[17]}},integrator[17:6]} + {{3{ptch_d_term[12]}},ptch_d_term[12:0]};
 	//input signed [11:0] ld_cell_diff;	// lft_ld - rght_ld from steer_en block

//wire [15:0] ld_cell_diff;


wire [15:0] lft_torque_w, rght_torque_w, lft_torque, rght_torque ;
wire [15:0] ld_cell_diff_ex; 		// since 1/8, so we ignore the lower 3 bits


//assign load_diff = load_cell_left – load_cell_right;
assign ld_cell_diff_ex = {{8{ld_cell_diff[11]}},ld_cell_diff[11:3]};
assign lft_torque_w = PID_cntrl + (~ld_cell_diff_ex + 1'b1);
assign rght_torque_w = PID_cntrl +  ld_cell_diff_ex;

assign lft_torque = en_steer ? lft_torque_w : PID_cntrl;
assign rght_torque = en_steer ? rght_torque_w : PID_cntrl; 

// shaping desired torque to form duty cycle

wire [15:0] lft_torque_abs, rght_torque_abs;
wire [15:0] lft_torque_gain, rght_torque_gain;	// we dont need to increase the width since we multiply small numbers only
wire lft_comparator, rght_comparator;

wire [15:0] lft_torque_acc, rght_torque_acc;	// accumulator outputs


assign lft_torque_abs = lft_torque[15] ? (~lft_torque + 1'b1) : lft_torque;
assign rght_torque_abs = rght_torque[15] ? (~rght_torque + 1'b1) : rght_torque;

assign lft_comparator = ( lft_torque_abs >= LOW_TORQUE_BAND ) ? 1'b1 : 1'b0;
assign rght_comparator = ( rght_torque_abs >= LOW_TORQUE_BAND ) ? 1'b1 : 1'b0;

assign lft_torque_gain = lft_torque * $signed(GAIN_MULTIPLIER);
assign rght_torque_gain = rght_torque * $signed(GAIN_MULTIPLIER);

//assign lft_torque_acc = lft_torque[15] ? (MIN_DUTY + (~lft_torque + 1'b1)) : (MIN_DUTY + lft_torque);
//assign rght_torque_acc = rght_torque[15] ? (MIN_DUTY + (~rght_torque + 1'b1)) : (MIN_DUTY + rght_torque);

assign lft_torque_acc = lft_torque[15] ? ((~MIN_DUTY + 1'b1) + (lft_torque)) : (MIN_DUTY + lft_torque);
assign rght_torque_acc = rght_torque[15] ? ((~MIN_DUTY +1'b1 ) + (rght_torque)) : (MIN_DUTY + rght_torque);


wire [15:0] rght_shaped, lft_shaped;

assign lft_shaped = lft_comparator ? lft_torque_acc : lft_torque_gain;
assign rght_shaped = rght_comparator ? rght_torque_acc : rght_torque_gain;


wire [15:0] rght_shaped_abs, lft_shaped_abs;
assign lft_shaped_abs = lft_shaped[15] ? (~lft_shaped + 1'b1): lft_shaped ;
assign rght_shaped_abs = rght_shaped[15] ? (~rght_shaped + 1'b1): rght_shaped ;

assign lft_rev = lft_shaped[15];		// to tell the direction to run the motor
assign rght_rev = rght_shaped[15];

assign lft_spd = (|lft_shaped_abs[15:11]) ? 11'h7ff : lft_shaped_abs[10:0];
assign rght_spd = (|rght_shaped_abs[15:11])? 11'h7ff : rght_shaped_abs[10:0];

endmodule 
