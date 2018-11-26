module SPI_master16(clk, rst_n, SS_n, SCLK, MOSI, MISO , wrt, cmd, done, rd_data);

input clk, rst_n;
output reg SS_n, SCLK, MOSI;			// SPI protocol signals
input wrt;					// A high for 1 clock period would initiate a SPI transaction
input [15:0]cmd;				// Data (command) being sent to inertial sensoror A2D converter.
output reg done;					// Asserted when SPI transaction is complete. Should stay asserted till next wrt
output [15:0]rd_data;				// Data from SPI slave. For inertialsensor we will only ever use [7:0] for A2D converter we will use bits [11:0]
input MISO;
//////////////// wires and internal connections //////////////////////

logic [4:0]cnt;
logic cnt_en;
logic [15:0]cmd_int, rd_data_int; 
logic [4:0]MISO_bit_cnt, MOSI_bit_cnt;



//////////////// state machine variable and  Transition /////////////////////////////////////////////////////////

typedef enum reg {IDLE, TRANSACTION} state_t;
state_t nxt_STATE, STATE;

  always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		STATE <= IDLE;
	else 
		STATE <= nxt_STATE;
  end

//////////////// 5 bit Counter to know the rising edge of SCLK /////////////////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		cnt <= 5'h00;
	else if (cnt_en) 
 		cnt <= cnt + 1;
	else cnt <= 5'h00;
  end

  assign SCLK = (MISO_bit_cnt == 5'h10 && MOSI_bit_cnt == 5'h10) ? 1'b1 : ~cnt[4];	// SCLK changes with MSB of 5 bit counter or its default value is high

//////////////// shift register for MOSI ////////////////////////////////////////////////////////////////////////

  always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		MOSI <= 1'b0;
		MOSI_bit_cnt <= 5'h00;
	end else if (wrt) begin			// loads the value into intermediate register when write signal arrives
		cmd_int <= cmd;
		MOSI_bit_cnt <= 5'h00;
	end else if (SS_n) MOSI <= 1'bz;
	else if (cnt == 5'b10000 && !SS_n) begin	
		MOSI <= cmd_int[15];
		cmd_int <= {cmd_int[14:0],1'b0};
		MOSI_bit_cnt <= MOSI_bit_cnt + 1;
	end
  end

///////////// shift register for MISO ////////////////////////////////////////////////////////////////////////////
  
  always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		rd_data_int <= 16'h0000;
		MISO_bit_cnt <= 5'h00;
	end else if (wrt) MISO_bit_cnt <= 5'h00;
	else if (!SS_n && cnt == 5'b00000 && MOSI_bit_cnt != 4'h0) begin
		rd_data_int <= {rd_data_int[14:0],MISO};
		MISO_bit_cnt <= MISO_bit_cnt + 1;
	end
  end

  assign rd_data = (SS_n) ? rd_data_int : 16'h0000;

/////////////  combinational block //////////////////////////////////////////////////////////////////////////////

  always_comb begin
  
  done = 1'b0;
  SS_n = 1'b1;
  nxt_STATE = IDLE;
  cnt_en = 1'b0;
 

  case (STATE)
	
	IDLE : begin 
		if (wrt)
			nxt_STATE = TRANSACTION;
		else nxt_STATE = IDLE;
		end

	TRANSACTION : begin
		if (!wrt) begin
		SS_n = 1'b0;
		cnt_en = 1'b1;
		if (MISO_bit_cnt == 5'h10 && MOSI_bit_cnt == 5'h10 && cnt == 5'b10000) begin	// for the end of transaction when all bits transferred
			cnt_en = 1'b0;
			SS_n = 1'b1;
			nxt_STATE = IDLE;
			done = 1'b1;
		end else nxt_STATE = TRANSACTION;
		end else nxt_STATE = TRANSACTION;
	end default : nxt_STATE = IDLE;
			

  endcase
  end
endmodule

