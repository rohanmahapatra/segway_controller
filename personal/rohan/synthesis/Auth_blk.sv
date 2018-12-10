module Auth_blk(clk, rst_n, pwr_up, RX, rider_off);

input clk, rst_n;
input RX, rider_off;
output reg pwr_up;

reg clr_rdy;
wire rdy;
wire [7:0]rx_data;



//////////////////////////////////// STATE Variable //////////////////////////////////////////////////////////////////////

typedef enum reg [1:0] {OFF, PWR1, PWR2} state_t;
state_t nxt_STATE, STATE;


/////////////////////////////////// UART RX instantiation /////////////////////////////////////////////////////////////////


UART_rcv rx(.clk(clk), .rst_n(rst_n), .RX(RX), .rdy(rdy), .rx_data(rx_data), .clr_rdy(clr_rdy));
 

//////////////////////////////////// State change flip flop ///////////////////////////////////////////////////////////////
always_ff @ (posedge clk, negedge rst_n) begin
  if (!rst_n)
	STATE <= OFF;
  else STATE <= nxt_STATE;
end

/////////////////////////////////// Combinational logic ////////////////////////////////////////////////////////////////////

  always_comb begin
    pwr_up = 1'b0;
    clr_rdy = 1'b0;

    case (STATE)

	OFF : begin
		  if (rdy && rx_data == 8'h67) begin
			nxt_STATE = PWR1;
			pwr_up = 1'b1;
			clr_rdy = 1'b1;
		  end else nxt_STATE = OFF;
		end

	PWR1: begin
		if (rdy && rx_data == 8'h73 && rider_off) begin
			nxt_STATE = OFF;
			pwr_up = 1'b0;
			clr_rdy = 1'b1;
		end else if (rdy && rx_data == 8'h73 && !rider_off) begin
			nxt_STATE = PWR2;
			pwr_up = 1'b1;
			clr_rdy = 1'b1;
		end else begin
			nxt_STATE = PWR1;
			pwr_up = 1;
			
		end
		end
	PWR2 : begin
		if (rdy && rx_data == 8'h67) begin
			nxt_STATE = PWR1;
			pwr_up = 1'b1;
			clr_rdy = 1'b1;
		end else if (rider_off) begin
			nxt_STATE = OFF;
			pwr_up = 1'b0;
			clr_rdy = 1'b1;
		end else begin
			nxt_STATE = PWR2;
			pwr_up = 1;
			
		end
	      end
	default : nxt_STATE = OFF;
    endcase
  end
endmodule
