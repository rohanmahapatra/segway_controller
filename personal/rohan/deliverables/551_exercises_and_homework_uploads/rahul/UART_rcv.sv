module UART_rcv(clk, rst_n, RX, rdy, rx_data, clr_rdy);
input clk, rst_n;			// clk - 50 MHz and active low asynchronous reset
input RX;				// 1 bit data line coming from transmitter
input clr_rdy;				// to clear the data ready signal 
output reg rdy;				// is asserted when data is ready
output reg [7:0] rx_data;		// final 8 bit data recieved
logic [8:0] int_data;
logic set_rdy;				// to assert the ready bit 1 when the entire data packet is received
logic start, shift;			// to denote whether the data receiving has started or we have to shift the register
logic [11:0]baud_cnt;			// determine baud rate 
logic [3:0]bit_cnt;			// to maintain the no. of bits received
logic clr_baudcnt, clr_bitcnt;		// to clear the counters
logic en_cnt;				// to enable the baud counter
logic clr_rdy_int;			// internal clear ready signal

typedef enum reg [1:0] {IDLE, START, RECEIVE} state_type; 
state_type STATE, nxt_STATE;

// State change
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		STATE <= IDLE;
	else STATE <= nxt_STATE;
end	


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
  else bit_cnt <= bit_cnt;	
end	

// Received data
always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
	int_data <= 8'h00;
  else if (shift)
	int_data <= {RX, int_data[8:1]};	// reads in RX and keeps shifting it until completion
  else int_data <= int_data;
end

assign rx_data = {int_data[8:1]};		// takes in most significant 8 bits of int_data as the lsb is always 0, (starting of transmission)


// Ready flop
always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
	rdy <= 1'b0;
  else if (clr_rdy || clr_rdy_int)		// to check if external or internal clr_rdy is high
	rdy <= 1'b0;
  else if (set_rdy)
	rdy <= 1'b1;
 // else rdy <= rdy;
end

// state machine
always_comb begin
nxt_STATE = IDLE;			//default states and vaules of controls
start = 1'b0;
shift = 1'b0;
clr_baudcnt = 1'b0;
clr_bitcnt = 1'b0;
set_rdy = 1'b0;
clr_rdy_int = 1'b0;
en_cnt = 1'b0;

case (STATE)
	
	IDLE : begin
		clr_baudcnt = 1;
		if (!RX) begin
			en_cnt = 1'b1;
			nxt_STATE = START;	
			clr_rdy_int = 1'b1;		
		end
		end
	
	START : begin
		en_cnt = 1'b1;
		 if (baud_cnt <= 12'hA2A && !RX) 		// check if the start bit lasts one baud period
			nxt_STATE = START;			// if yes, then next state is receiving 
		else if ((baud_cnt <= 12'hA2A) && (RX)) begin
			nxt_STATE = IDLE;
			en_cnt = 1'b0;
			end
		else begin
			nxt_STATE = RECEIVE;
			start = 1;
			clr_baudcnt = 1;
			shift = 1'b1;
		end
		end

	RECEIVE : begin
			en_cnt = 1'b1;
			if (bit_cnt < 4'b1001) begin
				if (baud_cnt > 12'hA2A) begin		// continue to receive the data untill all 8 bits are received
					nxt_STATE = RECEIVE;		// once the receive is complete the state changes to IDLE
					shift = 1'b1;
					clr_baudcnt = 1;
				end else nxt_STATE = RECEIVE;
			end else if (bit_cnt == 4'b1001) begin
				shift = 1'b0;
				if (baud_cnt > 12'hA2A) begin
					clr_bitcnt = 1'b1;
					clr_baudcnt = 1'b1;
					nxt_STATE = IDLE;
					set_rdy = 1'b1;
				end else nxt_STATE = RECEIVE;
			end


		end

	default : nxt_STATE = IDLE;	
endcase
end
endmodule
