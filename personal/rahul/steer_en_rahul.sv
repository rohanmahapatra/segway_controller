module steer_en(clk,rst_n,lft_ld, rght_ld,ld_cell_diff,en_steer,rider_off);

  input clk;				// 50MHz clock
  input rst_n;				// Active low asynch reset
  input [11:0] lft_ld, rght_ld;		// coming from the A2D interface
  output [11:0] ld_cell_diff;
  output logic en_steer;	// enables steering (goes to balance_cntrl)
  output logic rider_off;	// pulses high for one clock on transition back to initial state
  
 // wires 
  
 logic  tmr_full;			// asserted when timer reaches 1.3 sec
 logic  sum_gt_min;			// asserted when left and right load cells together exceed min rider weight
 logic  sum_lt_min;			// asserted when left_and right load cells are less than min_rider_weight
 logic  diff_gt_1_4;		// asserted if load cell difference exceeds 1/4 sum (rider not situated)
 logic  diff_gt_15_16;		// asserted if load cell difference is great (rider stepping off)
 logic clr_tmr;		// clears the 1.3sec timer
 logic [25:0]cnt;	// 26 bit counter for 1.3sec
  
reg [25:0] count;

localparam MIN_RIDER_WEIGHT = 100;	// to be updated - error

// code begins
//

assign sum_gt_min = ((lft_ld + rght_ld) > MIN_RIDER_WEIGHT) ? 1'b1 : 1'b0;
assign sum_lt_min = ((lft_ld + rght_ld) < MIN_RIDER_WEIGHT) ? 1'b1 : 1'b0;

/*
always @ (posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		count <= 0;
	end
	else if (clr_tmr) count <=0;
	else if (&count) count <= 0;
	else count <= count + 1;
end
*/
wire [11:0] rider_weight, rider_weight_abs;


////////////////////////////////////////////////////// we might need to flop these signals ///////////////////////////////////
assign rider_weight = lft_ld - rght_ld;
assign rider_weight_abs = rider_weight[11] ? ((~rider_weight)+1'b1) : rider_weight;

assign diff_gt_1_4 = (rider_weight_abs > (lft_ld + rght_ld)/4);

assign diff_gt_15_16 = (rider_weight_abs > 15*((lft_ld + rght_ld)/16));

assign ld_cell_diff = rider_weight_abs;


//
// code ends


 
 
 
 // timer implementation - which counts until 1.3 seconds

always @ (posedge clk, negedge rst_n) begin
  if (!rst_n)
	cnt <=  26'h0000000;
  else if (clr_tmr)
	cnt <=  26'h0000000;
  else if (cnt == 26'h3DFD240)
	tmr_full <= 1'b1;
  else cnt <=  cnt + 1;

end

 
 
 // enumerated type to encode states to view properly in waves.
typedef enum reg[1:0] {IDLE, WAIT, STEER_EN} SM_state;
SM_state nxt_state, STATE;
  
  // sequential state logic - using non blocking assignment
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
	STATE <= IDLE;
	else
	STATE <= nxt_state;
	
end



// state change conditions : compbinational logic
always  @(sum_gt_min, sum_lt_min,STATE, diff_gt_1_4, tmr_full, diff_gt_15_16, rst_n) begin
nxt_state = IDLE;
clr_tmr = 0;
en_steer = 0;
if (!rst_n)																					//asserts rider_off to be 0 in beginning and lets it to be 1 when state changes from steer to idle  
	rider_off = 0;
else rider_off = rider_off;
case(STATE)

	IDLE : begin															
		if (!sum_gt_min && sum_lt_min) 		// check if weight exceeds minimum rider weight, if yes then go to WAIT
			nxt_state = IDLE;		// otherwise WAIT in IDLE	
		else begin
			nxt_state = WAIT;
			clr_tmr = 1;
		     end
		end

	WAIT : begin
		if (!sum_gt_min && sum_lt_min)  // if weight drops below threshold go back to IDLE
			nxt_state = IDLE;
		else if (tmr_full) begin	// if timer is full, go to Steer enbale state
			nxt_state = STEER_EN;
			en_steer = 1;
		end else if (diff_gt_1_4) begin	// if rider not situated then wait and restart the timer
			nxt_state = WAIT;
			clr_tmr = 1;
		end else begin
			nxt_state = WAIT;	// WAIT till the timer is full
			clr_tmr = 0;
			end
	 	end
	
	STEER_EN : begin
		if (diff_gt_15_16) begin	// if rider stepping off, go to WAIT and disable steer
			nxt_state = WAIT;
			clr_tmr = 1;
			en_steer = 0;
		
		end else if (!sum_gt_min && sum_lt_min) begin	// check if rider has fallen, go to IDLE if yes
			nxt_state = IDLE;
			en_steer = 0;
			rider_off = 1;
		end
		else begin
			nxt_state = STEER_EN;	
			en_steer = 1;
		end
		end
	
	default : nxt_state = IDLE;
endcase
end		


endmodule
