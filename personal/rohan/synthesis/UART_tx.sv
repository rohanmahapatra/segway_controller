// 9 bit reg to transmit start/stop and data
//shift 10 times even though its a 9 bit reg
// should have a preset of all 1 (idle)
//
//shift after counter fills all 12 bits 2604
//
// 4 bit counter to count to 10 for data
//	tells us when set_done should be set
//
// code state machine in this file. always block for each state
// should only need 2 states
//

module UART_tx (clk, rst_n, trmt, tx_data, TX, tx_done);

//
// Locals
//
localparam CLK_CYCLES = 12'hA2C;
localparam TRAN_DONE = 4'hA;

//
// Inputs/Outputs
//
input clk, rst_n, trmt;
input [7:0] tx_data;		// Data to be transmitted
output TX;
output logic tx_done;		// goes to 1 when transmit is complete

//
// Internal
//
typedef enum reg {IDLE, TRANS} state_t;
logic [3:0] bit_cnt;		// Increments after each bit is sent
logic [11:0] baud_cnt;		// Holds data in transmit for 2604 clk cycles
logic [8:0] tx_shft_reg; 	// Holds the data being transmitted
logic load;			// Load signal flop
wire shift;			// shift signal
logic trans;			// transmitting signal
state_t state, nxt_state;	// State machine
logic set_done, clr_done; 	// state machine tx_done outputs

// Assert shift when baud_cnt reaches 2604 clk cycles
assign shift = (baud_cnt == CLK_CYCLES) ? 1'b1 : 1'b0;

// Send TX data
assign TX = tx_shft_reg[0];

// Hold data in transmit for 2604 clk cycles
always_ff @ (posedge clk) begin
	if (load == 1 || shift == 1)
		baud_cnt <= 1'b0;
	else if (trans == 1)
		baud_cnt <= baud_cnt + 1'b1;
	else 
		baud_cnt <= baud_cnt;
end

// Transmit complete counter
always_ff @ (posedge clk) begin
	if (load == 1)
		bit_cnt <= 4'h0;
	else if (shift == 1)
		bit_cnt <= bit_cnt + 1'b1;
	else
		bit_cnt <= bit_cnt;
end

// Transmit register
// Shifts data every 2604 clk cycles
always_ff @ (posedge clk, negedge rst_n) begin
	if (!rst_n)
		tx_shft_reg <= 9'h1FF;
	else if (load == 1)
		tx_shft_reg <= {tx_data, 1'b0};
	else if (shift == 1)
		tx_shft_reg <= {1'b1, tx_shft_reg[8:1]};
	else
		tx_shft_reg <= tx_shft_reg;
end

// TX Done flop 
// flop type: Set Reset
always_ff @ (posedge clk, negedge rst_n) begin
	if(!rst_n)
		tx_done <= 1'b0;
	else begin
		case({set_done, clr_done})
			{1'b0, 1'b0}: begin tx_done <= tx_done; end
			{1'b0, 1'b1}: begin tx_done <= 1'b0; end
			{1'b1, 1'b0}: begin tx_done <= 1'b1; end
			{1'b1, 1'b1}: begin tx_done <= 1'b0; end
		endcase
	end
end

// State machine
always_ff @ (posedge clk, negedge rst_n) begin

	if(!rst_n)
		state <= IDLE;
	else
		state <= nxt_state;
end

// State machine logic
always_comb begin
	//default outputs
	load = 0;
	clr_done = 0;
	set_done = 0;
	trans = 0;
	nxt_state = IDLE;

	case (state)
		TRANS: if(bit_cnt == TRAN_DONE) begin
			load = 0;
			trans = 0;
			set_done = 1;
			nxt_state = IDLE;
		end else begin
			load = 0;
			trans = 1;
			set_done = 0;
			clr_done = 0;
			nxt_state = TRANS;
		end
		// default case = IDLE
		default: if (trmt) begin
			load = 1;
			trans = 1;
			clr_done = 1;
			set_done = 0;
			nxt_state = TRANS;
		end else begin
			load = 0;
			trans = 0;
			clr_done = 0;
			set_done = 0;
			nxt_state = IDLE;
		end
	endcase
end

endmodule
