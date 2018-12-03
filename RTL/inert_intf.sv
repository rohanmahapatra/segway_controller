
module inert_intf(clk, rst_n, vld,  ptch, SS_n, MOSI, SCLK, MISO, INT);



// **************** PORTS ***************** //

// *****************************************//



input clk, rst_n;			//50MHzclock and active low asynchreset	

output vld;			//asserted from SM inside inert_intf.Consumed in inertial_integrator, but also an output to balance_cntrl.

output [15:0] ptch;		//This is the primary output of inert_intf.It is the fusion corrected pitch of the ?Segway? platform.

output SS_n, MOSI, SCLK;	//SPI interface to inertial sensor

input MISO;

input INT; 			//Interrupt signal from inertial sensor, informing that a new measurement is ready to be read(active high).



// **** WIRES and REGs and LOGICs ********* //

// *****************************************//

reg [15:0] timer;

reg int_ff1, int_ff2;

reg [7:0] ptchl, ptchh, azl, azh;

logic [15:0] ptch_rt, az;

logic wrt, vldw;

logic [15:0] cmd;

logic [15:0] rd_data;

logic ptchlw, ptchhw, azlw, azhw, done;

logic ready;
// ************ State Variables************ //

// *****************************************//

typedef enum reg [3:0] { INIT1, INIT2, INIT3, INIT4, PTCHL,PTCHL_INIT, PTCHH, AZL, AZH } state_t;

state_t ns, ps;



// **************** PORTS ***************** //

// *****************************************//



assign vld = vldw; 

// *************** TIMER  ***************** //

// *****************************************//

always @ (posedge clk, negedge rst_n) begin

	if(!rst_n) timer <= 16'hff0;

	else timer <= timer + 1;

end



// ********* Double Sync for INT ********** //

// *****************************************//

always @ (posedge clk, negedge rst_n)

	if(!rst_n) begin

		int_ff1 <= 0;

		int_ff2 <= 0;

	end

	else begin

		int_ff1 <= INT;

		int_ff2 <= int_ff1;

	end







// *************** TIMER  ***************** //

// *****************************************//

// *************** TIMER  ***************** //

// *****************************************//

// *************** TIMER  ***************** //

// *****************************************//

// ************* State Machine ************ //

// *****************************************//



always @(posedge clk, negedge rst_n)

      	if (!rst_n)

	      	  ps <= INIT1;

	else

		  ps <= ns;





always_comb begin

	// assigining outputs to default values

	wrt = 0;

	ns = INIT1;

	vldw = 0;

	ptchlw = 0; ptchhw = 0; azlw = 0; azhw = 0;
	cmd = 16'h0000;
	ready = 0;
	case (ps)

         	INIT1: 		if (&timer) begin cmd = 16'h0D02; ns = INIT2; wrt = 1; end

		INIT2: 		if (&timer[9:0]) begin cmd =16'h1053 ; ns = INIT3; wrt = 1; end else  ns = INIT2;

		INIT3: 		if (&timer[9:0]) begin cmd =16'h1150 ; ns = INIT4; wrt = 1; end else ns = INIT3;

		INIT4: 		if (&timer[9:0]) begin cmd =16'h1460 ; ns = PTCHL_INIT; wrt = 1; end else ns = INIT4;

		PTCHL_INIT: 	if (int_ff2==1) begin cmd = 16'hA2xx; wrt = 1; ns =PTCHL; end else ns = PTCHL_INIT;

		PTCHL: 		if(done) begin ptchlw = 1; cmd = 16'hA3xx; wrt = 1; ns = PTCHH;  end 		else ns = PTCHL;



		PTCHH: 		if (done) begin ptchhw=1; cmd = 16'hACxx; wrt =1 ;ns = AZL;end 		else ns = PTCHH;		

		

		AZL: 		if (done) begin azlw = 1; cmd = 16'hADxx; wrt = 1; ns = AZH; end 		else ns = AZL;

		

		AZH:  		if (done) begin azhw = 1; ns = PTCHL_INIT; vldw = 1; ready = 1; end else ns = AZH;

		default: 	ns = INIT1;

// if done is high, I can write to the wrt and combine the states.



	endcase

end








// Holding Registers for read data

always @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		ptchl <= 8'b0;
		ptchh <= 8'b0;
		azl <=  8'b0;
		azh <=  8'b0;
	end
	else begin
	if(ptchlw==1'b1) ptchl <= rd_data[7:0] ;
	if (ptchhw==1'b1) ptchh <= rd_data[7:0] ;
	if (azlw==1'b1) azl <= rd_data[7:0];
	if (azhw==1'b1) azh <= rd_data[7:0];
	end
end


always @ (posedge clk, negedge rst_n) begin

	if (!rst_n) begin
		ptch_rt <= 0;
		az <= 0;
	end
	else
	if (ready) begin
		ptch_rt <= {ptchh, ptchl};
		az <= {azh, azl};
	end
end




//assign ptch_rt = (ptchlw == 1'b1) ? {ptchh, ptchl} : ptch_rt;

//assign az = (azh == 1) ? {azh,azl} : az;



SPI_mstr16 inst_SPI (.clk(clk),.rst_n(rst_n),.SS_n(SS_n),.SCLK(SCLK),.MISO(MISO),.MOSI(MOSI),

		     .wrt(wrt),.cmd(cmd),.done(done),.rd_data(rd_data));

inertial_integrator inst_inert_integrator (.clk(clk), .rst_n(rst_n), .vld(vldw ), .ptch_rt(ptch_rt), .AZ(az), .ptch(ptch));



	   



endmodule
