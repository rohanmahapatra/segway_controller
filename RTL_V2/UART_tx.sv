module UART_tx(clk, rst_n, trmt, TX, tx_data, tx_done);
input clk, rst_n;
input [7:0]tx_data;			// data input to trnasmitter, this is to be transmitted
input trmt;				// asserted for 1 clock to initiate transmission
output reg TX, tx_done;			// Tx is transmitted data, tx_done is asserted when transmission is done	

logic [8:0]tx_reg;			// transmit register which will be shifted and sent out through output
logic [11:0]baud_cnt;			// determine baud rate 
logic [3:0]bit_cnt;			// determines how many bits have been transmitted
logic clr_baudcnt, clr_bitcnt;		// to clear the counters 	
logic done;				// intermediate bit to set tx_done signal
logic load, start, shift;		// load is asserted when a new data is to be transmitted and concatenated, start is to start transmission and shift for tranferring bits one by one
logic en_cnt;				// for baud counter to save power in idle state

typedef enum reg [1:0] {IDLE, START, TRANSMIT} state_type; 
state_type STATE, nxt_STATE;

// Baud Counter
always_ff @(posedge clk, negedge rst_n) begin		// counts till 12'b101000101100 (12'hA2C) which is one bit period
  if (!rst_n)
	baud_cnt <= 0;
  else if (clr_baudcnt)
	baud_cnt <= 0;
  else if (en_cnt) baud_cnt <= baud_cnt + 1;
  else baud_cnt <= baud_cnt;	
end				


// Bit Counter
always_ff @(posedge clk, negedge rst_n)begin		// counts till 9 (4'b1001) to denote that one transmit is complete
  if (!rst_n)
	bit_cnt <= 0;
  else if (clr_bitcnt)
	bit_cnt <= 4'h0;
  else if (start || shift)
	bit_cnt <= bit_cnt + 1;
end	

// Transmit flip-flop
always_ff @(posedge clk, negedge rst_n)	begin		
	if (!rst_n) 
		TX <= 1'b1;
	else if (tx_done)
		TX <= 1'b1;
	else if (load) begin
		tx_reg <= {1'b1, tx_data};			// concatenate the data with end bit which is one
		TX <= 1'b0;
	end else if (shift)begin
		TX <= tx_reg[0];
		tx_reg <= {1'b1, tx_reg[8:1]} ;			// shift the data right and enter 1 in MSB each time as stop bit
	end	 
end

// State change
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		STATE <= IDLE;
	else STATE <= nxt_STATE;
end	


// Tranmit done flip-flop
always_ff @(posedge clk, negedge rst_n)begin
	if (!rst_n)
		tx_done <= 1'b0;
	else 	tx_done <= done;
end

// Combinational logic
		
always_comb begin
					// set the default conditions for all the controls
nxt_STATE = IDLE;
clr_baudcnt = 1'b0;
clr_bitcnt = 1'b0;
start = 1'b0;
shift = 1'b0;
load = 0;
done = 1'b0;

case (STATE)

	IDLE : begin
		en_cnt = 0;	
		 if (trmt) begin
			nxt_STATE = START;
			done = 1'b0;	
			en_cnt = 1;
		end else nxt_STATE = IDLE;
	       end

	START : begin						// send the start bit and then go to transmit state
			done = 0;
			en_cnt = 1;
			if (baud_cnt <= 12'hA2C)begin
				nxt_STATE = START;
			end else begin
				nxt_STATE = TRANSMIT;
				start = 1;
				clr_baudcnt = 1'b1;
				load = 1;
				clr_bitcnt = 1'b1;
			end
		end

	TRANSMIT : begin
			en_cnt = 1'b1;
		      	if (bit_cnt <= 4'b1001) begin				// keeps sending the data until all 8 bits are transmitted
				if(baud_cnt < 12'hA2C)
					nxt_STATE = TRANSMIT;
				else begin
					shift = 1;
					clr_baudcnt = 1'b1;			// to transmit next bit
				end 
				nxt_STATE = TRANSMIT;
				done = 1'b0;
				
			end	
			else if (trmt) begin					// if another transmission then send to start state again
				nxt_STATE = START;
				done = 1'b1;
			end else begin						// if no then go back to IDLE state
				clr_bitcnt = 1'b1;
				done = 1'b1;
				nxt_STATE = IDLE;
			end
		   end	

	default : begin
			nxt_STATE = IDLE;
		  end	
endcase
end
endmodule
