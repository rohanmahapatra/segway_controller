module UART_rcv (clk, rst_n, RX, clr_rdy, rx_data, rdy);

//
// Locals
//
localparam CLK_CYCLE = 12'hA2C;
localparam HALF_CLK_CYCLE = 12'h512;
localparam RCV_DONE = 4'hA;

//
// Inputs/Outputs
//
input clk, rst_n, RX, clr_rdy;
output [7:0] rx_data;
output logic rdy;

//
// Internal Signals
//
typedef enum reg {IDLE, RCV} state_t;

logic stable_ff, RX_stable;	// Meta-stable RX data from RX input
logic [3:0] bit_cnt;		// Increments after each bit is receieved
logic [11:0] baud_cnt;		// Holds data in receive for 2604 clk cycles
logic [8:0] rx_shft_reg;	// Received data from RX
wire shift;			// shift signal
state_t state, nxt_state;	// State machine
logic set_rdy, start, receiving;	// state machine outputs
wire rdy_rst;

// Assert shift when baud_cnt finishes counting down
assign shift = (baud_cnt == 0) ? 1'b1 : 1'b0;

assign rx_data = rx_shft_reg[7:0];

// Both start and clr_rdy can deassert rdy
assign rdy_rst = start | clr_rdy;

// Double flop RX data in for meta-stability
always_ff @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		RX_stable <= 1'b1;
		stable_ff <= 1'b1;
	end else begin
		stable_ff <= RX;
		RX_stable <= stable_ff;
	end
end

// Receive data for 2604 clk cycles
// Shifts data every 2604 clk cycles after an initial shift of 2604/2.
// This ensures the data is received in the middle of a trasmit cycle.
always_ff @ (posedge clk) begin
	if (start == 1)
		baud_cnt <= HALF_CLK_CYCLE;
	else if (shift == 1)
		baud_cnt <= CLK_CYCLE;
	else if (receiving == 1)
		baud_cnt <= baud_cnt - 1'b1;
	else 
		baud_cnt <= baud_cnt;
end

// receive complete counter
always_ff @ (posedge clk) begin
	if (start == 1)
		bit_cnt <= 4'h0;
	else if (shift == 1)
		bit_cnt <= bit_cnt + 1'b1;
	else
		bit_cnt <= bit_cnt;
end

// receive register 
always_ff @ (posedge clk) begin
	if (shift == 1)
		rx_shft_reg <= {RX_stable, rx_shft_reg[8:1]};
	else
		rx_shft_reg <= rx_shft_reg;
end

// Receive Done flop 
// flop type: Set Reset
always_ff @ (posedge clk, negedge rst_n) begin
	if(!rst_n)
		rdy <= 1'b0;
	else begin
		case({set_rdy, rdy_rst})
			{1'b0, 1'b0}: begin rdy <= rdy; end
			{1'b0, 1'b1}: begin rdy <= 1'b0; end
			{1'b1, 1'b0}: begin rdy <= 1'b1; end
			{1'b1, 1'b1}: begin rdy <= 1'b0; end
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
	start = 0;
	receiving = 0;
	set_rdy = 1;
	nxt_state = IDLE;

	case (state)
		RCV: if(bit_cnt == RCV_DONE) begin
			start = 0;
			receiving = 0;
			set_rdy = 1;
			nxt_state = IDLE;
		end else begin
			start = 0;
			receiving = 1;
			set_rdy = 0;
			nxt_state = RCV;
		end
		// default case = IDLE
		default: if (!RX_stable) begin
			start = 1;
			receiving = 0;
			set_rdy = 0;
			nxt_state = RCV;
		end else begin
			start = 0;
			receiving = 0;
			set_rdy = 0;
			nxt_state = IDLE;
		end
	endcase
end

endmodule