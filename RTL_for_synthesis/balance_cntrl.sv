module balance_cntrl#(parameter fast_sim = 0)(clk,rst_n,vld,ptch,ld_cell_diff,lft_spd,lft_rev,
                     rght_spd,rght_rev,rider_off, en_steer, pwr_up, too_fast);
								
  input clk,rst_n;
  input vld;						// tells when a new valid inertial reading ready
  input signed [15:0] ptch;			// actual pitch measured
  input signed [11:0] ld_cell_diff;	// lft_ld - rght_ld from steer_en block
  input rider_off;					// High when weight on load cells indicates no rider
  input en_steer;
  input pwr_up;					// enables the entire module
  //input fast_sim;				// use faster integration
  output [10:0] lft_spd;			// 11-bit unsigned speed at which to run left motor
  output lft_rev;					// direction to run left motor (1==>reverse)
  output [10:0] rght_spd;			// 11-bit unsigned speed at which to run right motor
  output rght_rev;					// direction to run right motor (1==>reverse)
  output too_fast;				// is asserted when lft_spd or rght_spd exceed 1536
  
  ////////////////////////////////////
  // Define needed registers below //
  //////////////////////////////////
  reg [17:0]integrator_reg;
  reg [9:0]ptch_err_sat_delay;
  reg [9:0]prev_ptch_err;
  ///////////////////////////////////////////
  // Define needed internal signals below //
  /////////////////////////////////////////
  wire signed [9:0]ptch_err_sat;
  wire signed [14:0]ptch_P_term_wire;
  reg signed [14:0]ptch_P_term;
  wire [11:0] integrator;				// ptch_I_term
  wire [17:0]ptch_err_sat_sgn_ext;			// sgn_ext - sign extended
  wire [17:0]integrator_reg_input;
  wire ov;
  wire [17:0]sum_I_term;
  wire signed [9:0] ptch_D_diff_wire;
  reg signed [9:0] ptch_D_diff;
  wire signed [6:0]ptch_D_diff_sat;
  wire [12:0]ptch_D_term;
  wire [15:0]ptch_P_term_sgn_ext;
  wire [15:0]ptch_D_term_sgn_ext;
  wire [15:0]integrator_sgn_ext;
  wire [15:0]ld_cell_diff_sgn_ext;
  wire [15:0]PID_cntrl;
  wire signed[15:0]lft_torque;
  wire signed[15:0]rght_torque;
  wire [15:0]lft_torque_abs;
  wire [15:0]rght_torque_abs;
  wire lft_duty_mux;				// to choose between GAIN_MULTIPLIER option or MIN_DUTY
  wire rght_duty_mux;
  wire [15:0]lft_shaped;			
  wire [15:0]rght_shaped;
  wire [15:0]lft_shaped_abs;
  wire [15:0]rght_shaped_abs;


  /////////////////////////////////////////////
  // local params for increased flexibility //
  ///////////////////////////////////////////

  localparam P_COEFF = 5'h0E;
  localparam D_COEFF = 6'h14;				// D coefficient in PID control = +20 
    
  localparam LOW_TORQUE_BAND = 8'h46;	// LOW_TORQUE_BAND = 5*P_COEFF
  localparam GAIN_MULTIPLIER = 6'h0F;	// GAIN_MULTIPLIER = 1 + (MIN_DUTY/LOW_TORQUE_BAND)
  localparam MIN_DUTY = 15'h03D4;		// minimum duty cycle (stiffen motor and get it ready)
  
  //// You fill in the rest ////

  //// P of PID

  // saturating the input to 10 bit signed no. and calculating P term
  assign ptch_err_sat = (ptch[15] && ~&ptch[14:9]) ?  10'h200 : (~ptch[15] && | ptch[14:9]) ? 10'h1FF : ptch[9:0];
  assign ptch_P_term_wire = ptch_err_sat * $signed(P_COEFF);
  
  always @ (posedge clk, negedge rst_n) begin
	if (!rst_n) ptch_P_term <= 15'b0;
	else ptch_P_term <= ptch_P_term_wire;
  end


  //// I of PID
  
  assign ptch_err_sat_sgn_ext = {{8{ptch_err_sat[9]}},ptch_err_sat};
  assign sum_I_term = integrator_reg + ptch_err_sat_sgn_ext;		// adding to the previous sum, integrator adds and accumulates
 
 // if there is no overflow, sum is valid and should be accumulated through a flop

  assign ov = (integrator_reg[17] && ptch_err_sat_sgn_ext[17] && ~sum_I_term[17]) ? 1 : (~integrator_reg[17] && ~ptch_err_sat_sgn_ext[17] && sum_I_term[17]) ? 1 : 0;

// if rider is off, integrator term should be 0 
 
	assign integrator_reg_input = (rider_off || !pwr_up) ? 18'h00000 : ((vld && ~ov) ? sum_I_term : integrator_reg);
  always @(posedge clk, negedge rst_n) begin				// FF to accumulate 
  if (!rst_n)
	integrator_reg <= 18'h00000;
  else integrator_reg <= integrator_reg_input;
  end 

  assign integrator = integrator_reg[17:6];

  //// D of PID 

  always @ (posedge clk, negedge rst_n) begin			// delay flops to get previous ptch error value
 	 if (!rst_n) begin
		ptch_err_sat_delay <= 10'h000;
		prev_ptch_err <= 10'b000;
	  end
 	 else if (vld) begin
		ptch_err_sat_delay <= ptch_err_sat;
		prev_ptch_err <= ptch_err_sat_delay;
 	 end
  end

  
  assign ptch_D_diff_wire = ptch_err_sat - prev_ptch_err;
  
  always @ (posedge clk, negedge rst_n) begin
	if (!rst_n) 
		ptch_D_diff <= 10'b0;
	else
		ptch_D_diff <= ptch_D_diff_wire;
  end 
  
  
  
  
  
  assign ptch_D_diff_sat = (ptch_D_diff[9] && ~&ptch_D_diff[8:6]) ? 7'h40 : (~ptch_D_diff[9] && |ptch_D_diff[8:6]) ? 7'h3F : ptch_D_diff[6:0]; 
  assign ptch_D_term = ptch_D_diff_sat * $signed(D_COEFF); 


  //// PID MATH - Summing all the terms and calculating torque by adding / subtracting load cell difference
  assign ptch_P_term_sgn_ext = {ptch_P_term[14], ptch_P_term};
  assign ptch_D_term_sgn_ext = {{3{ptch_D_term[12]}}, ptch_D_term};
  assign integrator_sgn_ext = (fast_sim) ? integrator_reg[17:2] : {{4{integrator[11]}} ,integrator};
  assign ld_cell_diff_sgn_ext = {{7{ld_cell_diff[11]}},ld_cell_diff[11:3]};
  assign PID_cntrl = ptch_P_term_sgn_ext + ptch_D_term_sgn_ext + integrator_sgn_ext;	// sum of all 3 PID terms
  assign lft_torque = en_steer ? (PID_cntrl - ld_cell_diff_sgn_ext) : PID_cntrl;	// if no steering then output is directly PID cntrol
  assign rght_torque = en_steer ? (PID_cntrl + ld_cell_diff_sgn_ext) : PID_cntrl;
  
  //// TORQUE and DUTY CYCLE
  assign lft_torque_abs = lft_torque[15] ? -lft_torque : lft_torque;			
  assign rght_torque_abs = rght_torque[15] ? -rght_torque : rght_torque;
  assign lft_duty_mux = (lft_torque_abs >= LOW_TORQUE_BAND) ? 1 : 0;			// check if torque lies in LOW_TORQUE_BAND
  assign rght_duty_mux = (rght_torque_abs >= LOW_TORQUE_BAND) ? 1 : 0;

  // if the torue lies in low band then it needs to be multiplied by GAIN_MULTIPLIER otherwise we add/sub MIN_DUTY to it.
  // if torque is positive we add MIN_DUTY to it otherwise subtract

  assign lft_shaped = lft_duty_mux ? (lft_torque[15] ? (lft_torque - MIN_DUTY) : (MIN_DUTY + lft_torque)) :
					lft_torque * $signed(GAIN_MULTIPLIER);
  assign rght_shaped = rght_duty_mux ? (rght_torque[15] ? (rght_torque - MIN_DUTY) : (MIN_DUTY + rght_torque)) :
					rght_torque * $signed(GAIN_MULTIPLIER);
  assign lft_rev = lft_shaped[15];
  assign rght_rev = rght_shaped[15];
  assign lft_shaped_abs = lft_shaped[15] ? -lft_shaped : lft_shaped;
  assign rght_shaped_abs = rght_shaped[15] ? -rght_shaped : rght_shaped;
  assign lft_spd = (pwr_up) ? (|lft_shaped_abs[14:11]) ? 11'h7FF : lft_shaped_abs[10:0] : 11'h000;
  assign rght_spd =(pwr_up) ? (|rght_shaped_abs[14:11]) ? 11'h7FF : rght_shaped_abs[10:0] : 11'h000;
  assign too_fast = (lft_spd > 12'h600 || rght_spd > 12'h600) ? 1'b1 : 1'b0;

endmodule 
