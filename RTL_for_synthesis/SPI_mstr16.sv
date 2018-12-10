module SPI_mstr16(clk,rst_n,SS_n,SCLK,MISO,MOSI,wrt,cmd,done,rd_data);
  //////////////////////////////////////////////////|
  //                                  ||
  ///////////////////////////////////////////////////

// I/O Ports for Master
  input clk,rst_n;			// clock and active low asynch reset
  output reg SS_n;				// active low slave select , since getting driven from always block hence reg type
  output SCLK;				// Serial clock
  output MOSI;				// serial data out from master
  input MISO;				// serial data in to master
  input [15:0] cmd;	// parallel data to be loaded to SPI maaster to be transmitted
  output reg done;		//Asserted when SPI transaction is complete. Should stay asserted till next wrt  
  output [15:0] rd_data;	// Data from SPI slave.
  
  input wrt; 			//A high for 1 clock period would initiate a SPI transaction

  typedef enum reg[1:0] {IDLE,SHIFT,WAIT_1, WAIT} state_t;

  ///////////////////////////////////////////////
  // Registers needed in design declared next //
  /////////////////////////////////////////////
  state_t state,nstate;
  reg [15:0] shft_reg;	// SPI shift register for transmitted data
  //reg shft_reg_rx;	// SPI shift register for received data
  reg SCLK_ff1;	// used for falling edge detection of SCLK
  

reg [3:0] bit_cnt_reg;
logic bit_cnt;

  /////////////////////////////////////////////
  // SM outputs declared as type logic next //
  ///////////////////////////////////////////
  logic smpl, wrt, shft, init, clr_done, set_done, MISO_smpl;
  
  wire SCLK_fall,SCLK_rise;
  reg [4:0] sclk_reg;
  logic rst_cnt;
  //// Generate SCLK from clk

always @ (posedge clk, posedge rst_cnt) begin 
	if (rst_cnt) sclk_reg <= 5'b10111;		// controlled by the state machine when the first ss_n goes low
	else sclk_reg <= sclk_reg + 1;
end

assign SCLK = sclk_reg[4]; // generating SCLK

  //// Implement falling edge detection of SCLK ////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  begin
	    SCLK_ff1 <= 1'b1;
	    //SCLK_ff2 <= 1'b1;
	  end
	else
	  begin
	    SCLK_ff1 <= SCLK;
		//SCLK_ff2 <= SCLK_ff1;
	  end  
	  
  /////////////////////////////////////////////////////
  // If SCLK_ff2 is still high, but SCLK_ff1 is low //
  // then a negative edge of SCLK has occurred.    //
  //////////////////////////////////////////////////
  assign SCLK_fall = ~SCLK & SCLK_ff1;
  assign SCLK_rise = SCLK & ~SCLK_ff1;
  
  //// Implement done as a set/reset flop ////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n) begin
	  done <= 1'b1;
	  SS_n <= 1'b1; end
	else if (clr_done) begin
	  done <= 1'b0;
	  SS_n <= 1'b0; end
	else if (set_done) begin
	  done <= 1'b1;
	  SS_n <= 1'b1; end

  //// Infer main SPI shift register ////
  always_ff @(posedge clk, negedge rst_n)
    	if (!rst_n)
	  shft_reg <= 16'h0000;
	else begin 
		casex ({wrt,shft})
		2'b00: shft_reg <= shft_reg;
		2'b01: shft_reg <= {shft_reg[14:0], MISO_smpl};
		2'b1x: shft_reg <= cmd;
		default: shft_reg <= 16'h0000;	
	endcase
	end // else

	//assign MOSI = shft_reg[15];
// if not driving then its z     
assign MOSI = (SS_n) ? 1'bz : shft_reg[15];

  	assign rd_data = shft_reg[15:0];		// check if this should depend on some signal??

  //// Infer main SPI shift register ////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  MISO_smpl <= 1'b0;
	else if (smpl)
	  MISO_smpl <= MISO;	

  
  //// Infer state register next ////
  always @(posedge clk, negedge rst_n)
    if (!rst_n)
	  state <= IDLE;
	else
	  state <= nstate;

  //////////////////////////////////////
  // Implement state tranisiton logic //
  /////////////////////////////////////
  always_comb
    begin
      //////////////////////
      // Default outputs //
      ////////////////////
		// check
      	init = 0;
	shft = 0;
	smpl = 0;
	set_done = 1;
	clr_done = 0;
	nstate = IDLE;	  
	rst_cnt = 0;
	
      case (state)
        IDLE : begin
		rst_cnt = 1;
          	if (wrt) begin
		clr_done = 1;
		set_done = 0;
		nstate = SHIFT;
          	end
	  	else nstate = IDLE;
        end
	
	SHIFT : begin
			set_done = 0;
			clr_done = 1;
			
			if (bit_cnt && SCLK_rise) begin smpl = 1; nstate = WAIT_1; end 
			else if (SCLK_rise) begin 	smpl = 1; init = 1; nstate = SHIFT; end

		 	else if (SCLK_fall && ~(|bit_cnt_reg)) begin nstate = SHIFT; end

			
		 	else if (SCLK_fall) begin	shft = 1; nstate = SHIFT; end

			else nstate = SHIFT;
		   	
		end
	

WAIT_1 : begin
		  /////////////////////////////////////
		  // shift on falling edges of SCLK //
		  // and wait for rise of SS_n     //
		  //////////////////////////////////
		  	set_done = 0;
			clr_done = 1;
			shft = 1;
			nstate = WAIT;
		
			
	end


	WAIT : begin
		  /////////////////////////////////////
		  // shift on falling edges of SCLK //
		  // and wait for rise of SS_n     //
		  //////////////////////////////////
		  	set_done = 0;
			clr_done = 1;
		
			if (&sclk_reg[2:0]) begin
			
			set_done = 1;
			rst_cnt = 1;
			clr_done = 0;
			nstate = IDLE;
			// logic to shift again last time
			end
		  else	nstate = WAIT;
	
		end
      endcase
    end


// bit counter
 

always @(posedge clk, negedge rst_n) begin
	if(!rst_n) bit_cnt_reg <= 0;
	else if (rst_cnt) bit_cnt_reg <= 0;
	else if(init) bit_cnt_reg <= bit_cnt_reg + 1;
 end

assign bit_cnt = (bit_cnt_reg == 4'b1111) ? 1'b1 : 1'b0 ; 


endmodule  
  
