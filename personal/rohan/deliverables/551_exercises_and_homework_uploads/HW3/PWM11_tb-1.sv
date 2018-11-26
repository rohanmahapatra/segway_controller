`timescale 10ns/1ps
module PWM11_tb();

reg clk, rst_n;
reg [10:0] duty;
wire PWM_sign;

PWM11 i_dut (.clk(clk), .rst_n(rst_n), .duty(duty), .PWM_sig(PWM_sig));

initial begin

clk = 0;
rst_n = 0;
duty = 11'b0;

repeat(2) @(posedge clk);
#1; 		// to model async rst
rst_n = 1;	// deassert reset
@(posedge clk) duty = 11'h001;
repeat(2047)@(posedge clk);



@(posedge clk) duty = 11'h00f;
repeat(2047)@(posedge clk);

@(posedge clk) duty = 11'h010;
repeat(2047)@(posedge clk);

@(posedge clk) duty = 11'h0f0;
repeat(2047)@(posedge clk);

@(posedge clk) duty = 11'h0ff;
repeat(2047)@(posedge clk);

@(posedge clk) duty = 11'h100;
repeat(2047)@(posedge clk);

@(posedge clk) duty = 11'hf00;
@(posedge clk);

@(posedge clk) duty = 11'hf0f;
@(posedge clk);

@(posedge clk) duty = 11'hfff;
@(posedge clk);


repeat(2) @(posedge clk);
$stop();



end

always
  #2 clk = ~clk;
// should have been 25000 with the current timescale but this //period will be huge and for simulation purpose, restricting to //higher frequency
endmodule