module UART_rcv(clk, rst_n, RX, clr_rdy, cmd, rdy);

// ****** I/O Ports *******
input clk,rst_n; 	// 50MHz systemclock & active low reset
input RX; 		// Serialdata input
input clr_rdy; 		// Knocks down rdy when asserted
//output [7:0] rx_data;	//out Byte received
output rdy; 		//out Asserted when byte received. Stays high till start bit of next byte starts, or until clr_rdyasserted.

// ******* Internal Wires/Regs ******

reg clr_busy; 
reg busy, ready;
output reg [7:0] cmd;
reg [9:0] shift_reg;
reg rx_meta_in1, rx_meta_in2;

logic receiving, start, shift;
logic [3:0] bit_cnt;
logic [12:0] baud_cnt; 	// we need 12 bits but for 1st RX bit we need to wait for 1.5 times.
logic set_rdy;
//parameter baud = ;

typedef enum reg[1:0] {IDLE, WAIT, SHIFT} state_t;
state_t state, nxt_state;
 
// logic to synchronize the incoming RX signal to avoid metastability
always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			rx_meta_in1 <= 0;	// could have been 1 but we have another signal to detect any incoming data.
			rx_meta_in2 <= 0;
		end
		else begin
			rx_meta_in1 <= RX;
			rx_meta_in2 <= rx_meta_in1;
		end	
	end


// counter to count the baud rate. We have baud of 19,200 with 50Mhz clock so we need 12 bits (log base 2 of 2064 )
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			baud_cnt <= 0;
		else
			casex({shift, receiving})
				2'b0_0: baud_cnt <= baud_cnt;
				2'b0_1: baud_cnt <= baud_cnt + 1;
				2'b1_x: baud_cnt <= 0;
			endcase
	end

// counter to count the bits received
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			bit_cnt <= 0;
		else
			casex({start, shift})
				2'b0_0: bit_cnt <= bit_cnt;
				2'b0_1: bit_cnt <= bit_cnt + 1;
				2'b1_x: bit_cnt <= 0;
				default: bit_cnt <= 0;
			endcase
	end
	
	
	// shift logic since receiver is a bit complex 
	always_comb begin
		// Wait for 1.5 cycles when receiving the 1st bit i.,e when line becomes low
		if(bit_cnt == 0) 	// to detect the 1st bit
			if(baud_cnt == 3906)
				shift = 1;
			else	
				shift = 0;
		// Wait for 1 cycle
		else
			if(baud_cnt == 2604)
				shift = 1;
			else
				shift = 0;
	end	
	
	// rotater for rx shift reg
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			shift_reg <= 0;
		else	
			casex(shift)
				1'b0: shift_reg <= shift_reg;
				1'b1: shift_reg <= {RX, shift_reg[9:1]};
			endcase			
	end
	
	// cmd logic
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			cmd <= 0;
		else
			casex(bit_cnt)
				9: cmd <= shift_reg[8:1];
				default: cmd <= cmd;
			endcase
	end
	
	// logic to detect if receiver is busy and control the state machine
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			busy <= 0;
		else if(rx_meta_in2 & !rx_meta_in1)
			busy <= 1;
		else if (clr_busy)
			busy <= 0;
		else
			busy <= busy;
	end
	
	
	
	// set ready and clear ready generation
	always @(posedge clk, negedge rst_n) begin
		if (!rst_n)
			ready <= 0;
		else if(clr_rdy)
			ready <= 0;
		else if(set_rdy)
			ready <= 1;
		else
			ready <= ready;
	end
	

// state machine
// sequential logic to assign next state
always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;
end

// combinational logic
	always_comb begin
		nxt_state = IDLE;
		receiving = 0;
		clr_busy = 0;
		start = 0;
		set_rdy = 0;
		case(state)
			IDLE: begin
				if(busy) begin
					nxt_state = WAIT;
					start = 1;
					receiving = 1;
				end
				else begin
					nxt_state = IDLE;
				end
			end
			WAIT: begin
				if(shift) begin
					nxt_state = SHIFT;
				end
				else begin
					nxt_state = WAIT;
					receiving = 1;
				end
			end
			SHIFT: begin
				if(bit_cnt < 9) begin
					nxt_state = WAIT;
					receiving = 1;
				end
				else begin
					nxt_state = IDLE;
					set_rdy = 1;
					clr_busy = 1;
				end
			end
		endcase
	end



endmodule