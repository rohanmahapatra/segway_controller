// SM drawing is fairly accurate
// spi trans -> 1 state to kill 1 clock cycle -> read data back
// count 0,1,2 for round robin

module A2D_Intf(clk, rst_n, nxt, lft_ld, rght_ld, batt, SS_n, SCLK, MOSI, MISO);

input clk, rst_n;
input nxt;		// Used to initiate A2D conversion on next measurand
input MISO;		// SPI

output SCLK, SS_n, MOSI;	// SPI
output reg [11:0] lft_ld, rght_ld, batt;

wire [15:0] cmd;
wire done;
wire [15:0] rd_data;
wire lft_en, rght_en, batt_en;
reg [1:0] rr_cnt;	// round robin counter
wire [2:0] channel;

// SM types
typedef enum reg [2:0]{IDLE, TRANS, KILL, RECV, WAIT} state_t;
state_t state, nxt_state;
reg update;
reg wrt;
reg update_rd_data;

// Init spi master interface
SPI_mstr16 spi_mstr(.clk(clk), .rst_n(rst_n), .wrt(wrt), .cmd(cmd), .SS_n(SS_n), .done(done), 
		.rd_data(rd_data), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO));

assign lft_load = lft_en && update_rd_data;
assign rght_load = rght_en && update_rd_data;
assign batt_load = batt_en && update_rd_data;

always @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		lft_ld <= 12'h000;
	else if (lft_load)
		lft_ld <= rd_data[11:0];
	else
		lft_ld <= lft_ld;
end

always @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		rght_ld <= 12'h000;
	else if (rght_load)
		rght_ld <= rd_data[11:0];
	else
		rght_ld <= rght_ld;
end

always @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		batt <= 12'hFFF;
	else if (batt_load)
		batt <= rd_data[11:0];
	else
		batt <= batt;
end

always @ (posedge clk, negedge rst_n) begin
	if (!rst_n)
		rr_cnt <= 2'b00;
	else if (update)
		rr_cnt <= (rr_cnt == 2'b10) ? 2'b00 : rr_cnt + 1;
end

assign lft_en = (rr_cnt == 2'b00);
assign rght_en = (rr_cnt  == 2'b01);
assign batt_en = (rr_cnt   == 2'b10);
assign channel = (lft_en) ? 3'b000 :
		 (rght_en) ? 3'b100: 3'b101;
assign cmd =  {2'b00, channel[2:0] ,11'h000};

// State machine ff
always_ff @ (posedge clk, negedge rst_n) begin
	if (!rst_n)
		state <= IDLE;
	else
		state <= nxt_state;
end

always_comb begin
	wrt = 0;
	update = 0;
	nxt_state = IDLE;
	update_rd_data = 0;

	case(state)
		IDLE:
			if (nxt) begin
				wrt = 1;

				nxt_state = TRANS;
			end else 
				nxt_state = IDLE;
		TRANS:
			if (done) begin
				nxt_state = KILL;
			end else 
				nxt_state = TRANS;
		KILL:begin
			nxt_state = RECV;
			wrt = 1;
			
		end
		RECV:
			if (done) begin
				update_rd_data = 1;
				nxt_state = WAIT;
			end else 
				nxt_state = RECV;
		WAIT:
			begin
				update = 1;
				nxt_state = IDLE;
			end
		default:
			nxt_state = IDLE;
	endcase;
end

endmodule 