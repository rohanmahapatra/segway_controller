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

  typedef enum reg[1:0] {IDLE,SKIP_1st,WAIT_SSn} state_t;

  ///////////////////////////////////////////////
  // Registers needed in design declared next //
  /////////////////////////////////////////////
  state_t state,nstate;
  reg [15:0] shft_reg_tx;	// SPI shift register for transmitted data
  reg shft_reg_rx;	// SPI shift register for received data
  reg SCLK_ff1,SCLK_ff2;	// used for falling edge detection of SCLK
  

reg [3:0] bit_cnt_reg;
logic bit_cnt;

  /////////////////////////////////////////////
  // SM outputs declared as type logic next //
  ///////////////////////////////////////////
  logic load, shift_tx, shift_rx, clr_done, set_done;
  
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
	    SCLK_ff2 <= 1'b1;
	  end
	else
	  begin
	    SCLK_ff1 <= SCLK;
		SCLK_ff2 <= SCLK_ff1;
	  end  
	  
  /////////////////////////////////////////////////////
  // If SCLK_ff2 is still high, but SCLK_ff1 is low //
  // then a negative edge of SCLK has occurred.    //
  //////////////////////////////////////////////////
  assign SCLK_fall = ~SCLK_ff1 & SCLK_ff2;
  assign SCLK_rise = SCLK_ff1 & ~SCLK_ff2;
  
  //// Implement done as a set/reset flop ////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  done <= 1'b1;
	else if (clr_done)
	  done <= 1'b0;
	else if (set_done)
	  done <= 1'b1;

  //// Infer main SPI shift register ////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  shft_reg_tx <= 16'h0000;
	else if (shift_tx)
	  shft_reg_tx <= {shft_reg_tx[14:0],shft_reg_rx};
	else if (load)				// will transmit what we received next time
	  shft_reg_tx <= cmd;

	assign MOSI = shft_reg_tx[15];
  	assign rd_data = shft_reg_tx[15:0];		// check if this should depend on some signal??

  //// Infer main SPI shift register ////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  shft_reg_rx <= 1'b0;
	else if (shift_rx)
	  shft_reg_rx <= MISO;	

  
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
	load = 0;
	SS_n = 1;
      	shift_tx = 0;
	shift_rx = 0;
        clr_done = 0;
	set_done = 0; 		// check
      	nstate = IDLE;	  
	rst_cnt = 0;
	
      case (state)
        IDLE : begin
          if (wrt) begin
		SS_n = 1'b0;
		clr_done = 1;
		set_done = 0;
		rst_cnt = 1;
		load = 1;
            	nstate = SKIP_1st;
          end
	  else nstate = IDLE;
        end
	
	SKIP_1st : begin
			SS_n = 1'b0;
		 if (SCLK_fall) begin
		   
		   shift_tx = 1;
		   nstate = WAIT_SSn;
			
		end
		  else
		    nstate = SKIP_1st;
		end
	WAIT_SSn : begin
		  /////////////////////////////////////
		  // shift on falling edges of SCLK //
		  // and wait for rise of SS_n     //
		  //////////////////////////////////
		  	SS_n = 1'b0;
		if (bit_cnt==1'b1) begin
			nstate = IDLE;
			set_done = 1;
			shift_tx = 1;
			nstate = IDLE;
			// logic to shift again last time
			end
		  else if (SCLK_rise) begin
			nstate = SKIP_1st;
			SS_n = 1'b1;
			shift_rx = 1;
		  end
		
		end
      endcase
    end


// bit counter
 

always @(posedge clk, negedge rst_n) begin
	if(!rst_n) bit_cnt_reg <= 0;
	else if(shift_tx) bit_cnt_reg <= bit_cnt_reg + 1;
 end

assign bit_cnt = (bit_cnt_reg == 4'b1111) ? 1'b1 : 1'b0 ; 


endmodule  
  
