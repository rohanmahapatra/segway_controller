module A2D_Intf(clk, rst_n, nxt, lft_ld, rght_ld, batt, SS_n, SCLK, MOSI, MISO);
 
//****************************************************//
//************* I/O Ports ****************************//
//****************************************************//
 
input clk,rst_n; //50MHz clock and active low asynch reset
input nxt; // Initiates A2D conversion on next  measurand
output reg [11:0] lft_ld; // Result of last conversion on channel 0 (left load cell)
output reg [11:0] rght_ld; //Result of last conversion on channel 4 (right load cell)
output reg [11:0] batt; // Result of last conversion on channel 5 (battery voltage)
//SPI Interface
output SS_n;
output SCLK;
output MOSI;
input MISO;
 
 
 
 
typedef enum reg [1:0] {IDLE, ONE, PAUSE, TWO} st;
st state, nstate;
//****************************************************//
//************* Internal Registers and Wires *********//
//****************************************************//
 
 
 
 
 
 
//****************************************************//
//************************ Logic *********************//
//****************************************************//
 
logic wrt,  done;               // see why it flags error when declared as wire
wire [15:0] rd_data;
logic [15:0] cmd;
 
logic update, en3, en1, en2;
logic second;
// *************** Round robin counter **************//
reg [1:0] out;
  /*
always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
      out <= 2'b00;
    else if (update)
      out <= out + 1'b1;
  end
*/
 
 
 
 
typedef enum reg [1:0] {INIT, SEQ1, SEQ2, SEQ3} sta;
sta pst, nst;
 
 
 
/////// round robin counter
 
always @ (posedge clk, negedge rst_n) begin
                if (!rst_n) pst <= INIT;
                else pst <= nst;
end
 
always_comb begin
                out = 2'b00;
                case (pst)
                INIT: begin out = 2'b00; if(update) out = 2'b01; nst= SEQ1; end
                SEQ1: begin out = 2'b01; if(update) out = 2'b10; nst= SEQ2;end
                SEQ2: begin out = 2'b10; if(update) out = 2'b11; nst= SEQ3;end
                SEQ3: begin out = 2'b11; if(update) out = 2'b01; nst= SEQ1;end
                default: out = 2'b00;
endcase
end
 
 
 
always_comb begin
              if (done && second) begin
                                case (out)
                                2'b01: begin en1 = 1'b1; en2 = 1'b0; en3 = 1'b0; end
                                2'b10: begin en1 = 1'b0; en2 = 1'b1; en3 = 1'b0; end
                                2'b11: begin en1 = 1'b0; en2 = 1'b0; en3 = 1'b1; end
                                default: begin en1 = 1'b0; en2 = 1'b0; en3 = 1'b0; end
                                endcase
                end        // if
                else begin en1 = 1'b0; en2 = 1'b0; en3 = 1'b0; end             
end // always_comb
 
 
 
always_comb begin
                unique case (out)
                2'b01: begin cmd = {{2{1'b0}},3'b000,{11{1'b0}}} ; end     // sending the same packet next time does not matter as we are interested in receiving data
                2'b10: begin cmd = {{2{1'b0}},3'b100, {11{1'b0}}} ; end    // can be optimized further 
                2'b11: begin cmd = {{2{1'b0}},3'b101,{11{1'b0}}} ; end     
                default: begin cmd = 16'h0000; end
                endcase
                end
 
 
// *************** Registers to hold rd_data **************//
 
always @ (posedge clk, negedge rst_n) begin
 
if (!rst_n) begin lft_ld <= 12'b0; rght_ld  <= 12'b0; batt  <= 12'b0; end
else begin
                if             (en1) lft_ld <= rd_data[11:0];
                else if (en2) rght_ld <= rd_data[11:0];
                else if (en3) batt <= rd_data[11:0];
 
                end // if update_reg_en
end
 
 
// *************** SPI Instantiation **********//
SPI_mstr16 SPI_mstr_inst(.clk(clk),.rst_n(rst_n),.SS_n(SS_n),.SCLK(SCLK),.MISO(MISO),.MOSI(MOSI),.wrt(wrt),.cmd(cmd),.done(done),.rd_data(rd_data));
 
 
// *************** State Machine **********//
 
always @ (posedge clk, negedge rst_n)
                if (!rst_n) state <= IDLE;
                else state <= nstate; 
 
 
always_comb begin
 
 
                wrt = 0;
                update = 0;
                nstate = IDLE;
                second = 0;
                case (state)
 
                IDLE: begin 
                                if (nxt) begin update = 1'b1; wrt = 1'b1; nstate = ONE; end
                                else nstate = IDLE;
                end
                ONE: begin
                               if (done) begin nstate = PAUSE; end
                                else nstate = ONE;
                end
                PAUSE: begin
                                wrt = 1'b1;
                                nstate = TWO;
                                // see if we need to reset some counters
                end        
                TWO: begin 
                                second = 1;
                                if (done) begin nstate = IDLE; end                              // because we get data in this state
                                else nstate = TWO;
                end
                default: nstate = IDLE;
 
                endcase
 
 
 
end // always_comb
 
 
 
 
 
 
 
endmodule