// D_flipflop module
module dff(
    input D,
    input clk,
    input rst,
    output reg Q
    );
 
always @ (posedge(clk), posedge(rst))
begin
    if (rst == 1)
        Q <= 1'b0;
    else
            Q <= D;
end
 
endmodule

// UART Transmitter
module UART_tx(clk, rst_n, trmt, tx_data, tx_done, TX);
	input clk, rst_n;	// clock and reset inputs
	input trmt;		// signal to indicate start of transmission
	input[7:0] tx_data;	// the 8 bit tx data which is to be serially shifted for transmission
	output TX;		// feedback to host
	output reg tx_done;	// assert when done transmitting
	logic load, transmitting, shift, set_done, clr_done; 	// internal logic for sequential circuit
	logic [3:0] bit_cnt;		// 1st counter to count the 9 bits including the start bit
	
typedef enum reg[1:0] {IDLE, TRANSMITTING, SHIFT} state_t;		// using this so that its easy to debug signals in the waves
	state_t state, nxt_state;
	reg [11:0] baud_cnt;			// Baud rate of 2064 which is 2^11. So we need 11 bits
	reg [9:0] tx_shift_reg;			// shft reg to read and shift the values

	always @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			bit_cnt <= 0;
		else
			casex ({load, shift})
				2'b00: bit_cnt <= bit_cnt;
				2'b01: bit_cnt <= bit_cnt + 1;
				2'b1x: bit_cnt <= 0;
				default: bit_cnt <= 0;
			endcase
	end
	
	
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			baud_cnt <= 0;
		else
			casex ({shift, transmitting})
				2'b0_0: baud_cnt <= baud_cnt;
				2'b0_1: baud_cnt <= baud_cnt + 1;
				2'b1_x: baud_cnt <= 0;
				default: bit_cnt <= 0;
			endcase
	end
	assign shift = (baud_cnt > 2603) ? 1 : 0;
	
	// Code for TX shift logic
	always @(posedge clk, negedge rst_n) begin
		if (!rst_n)
			tx_shift_reg <= 9'h1ff; 	// because we need to pull low to indicate the start bit as per the protocol
		else begin
			casex({load, shift})
				2'b0_0: tx_shift_reg <= tx_shift_reg;
				2'b0_1: tx_shift_reg <= tx_shift_reg >> 1;
				2'b1_x: tx_shift_reg <= {1'b1, tx_data, 1'b0};
				default: tx_shift_reg <= 0;
			endcase
		end
	end
	assign TX = (transmitting) ? tx_shift_reg[0] : 1;	// finally the serial output which is sent to the receiver
	
	// code to detect the tx_done
	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			tx_done <= 0;
		end
		else begin
			tx_done <= set_done & !clr_done;
		end
	end

// state machine using SV construct - always_ff
	always_ff @(posedge clk, negedge rst_n)
		if(!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;
	
	always_comb begin
		nxt_state = IDLE;
		load = 1'b0;
		clr_done = 1'b0;
		transmitting = 1'b0;
		set_done = 1'b0;
		case(state)
			IDLE: begin
				if (trmt) begin
					nxt_state = TRANSMITTING;
					load = 1'b1;
					clr_done = 1'b1;
					transmitting = 1'b1;
				end
				else
					nxt_state = IDLE;
			end
			TRANSMITTING: begin
				if (shift) begin
					nxt_state = SHIFT;
					if (bit_cnt < 9)
						transmitting = 1'b1;
				end
				else begin
					nxt_state = TRANSMITTING;
					transmitting = 1'b1;
				end
			end
			SHIFT: begin
				if (bit_cnt < 10) begin
					nxt_state = TRANSMITTING;
					transmitting = 1'b1;
				end
				else begin
					nxt_state = IDLE;
					set_done = 1'b1;
				end
			end
		endcase
	end
	


endmodule

