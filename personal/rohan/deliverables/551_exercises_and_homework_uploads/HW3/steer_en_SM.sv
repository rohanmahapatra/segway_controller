module steer_en_SM(clk,rst_n,tmr_full,sum_gt_min,sum_lt_min,diff_gt_1_4,
                   diff_gt_15_16,clr_tmr,en_steer,rider_off);

  input clk;				// 50MHz clock
  input rst_n;				// Active low asynch reset
  input tmr_full;			// asserted when timer reaches 1.3 sec
  input sum_gt_min;			// asserted when left and right load cells together exceed min rider weight
  input sum_lt_min;			// asserted when left_and right load cells are less than min_rider_weight
 
  input diff_gt_1_4;		// asserted if load cell difference exceeds 1/4 sum (rider not situated)
  input diff_gt_15_16;		// asserted if load cell difference is great (rider stepping off)
  output logic clr_tmr;		// clears the 1.3sec timer
  output logic en_steer;	// enables steering (goes to balance_cntrl)
  output logic rider_off;	// pulses high for one clock on transition back to initial state
  
// enumerated type to encode states to view properly in waves.
typedef enum reg[1:0] {IDLE, WAIT, STEER_EN} SM_state;
SM_state nxt_state, state;
  
  // sequential state logic - using non blocking assignment
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
	state <= IDLE;
	else
	state <= nxt_state;
	
end


// combinational logic to generate the next state logic
always_comb begin
//assigning to reset values to avoid latches
nxt_state = IDLE;
clr_tmr = 0; 
rider_off = 0;
en_steer = 0; 
case (state)
	IDLE: if (sum_gt_min) begin  nxt_state = WAIT; clr_tmr = 1; end 
	      else nxt_state = IDLE;
	WAIT: begin
//		
		if (sum_lt_min) begin nxt_state = IDLE; rider_off = 1 ; end
	        else if (diff_gt_1_4) begin
			nxt_state = WAIT;
			clr_tmr = 1;
		end
		else if (tmr_full) begin
			nxt_state = STEER_EN;
			en_steer = 1;
		end
       		else nxt_state = WAIT;
	       end
	STEER_EN: begin
		  if (sum_lt_min) begin  nxt_state = IDLE; rider_off = 1; end
		  else if (diff_gt_15_16) begin nxt_state = WAIT; clr_tmr = 1; end 
		  else begin  nxt_state = STEER_EN; en_steer = 1; end
end
endcase
end
endmodule
