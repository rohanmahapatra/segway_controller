
module duty_tb();
 
reg signed [6:0] ptch_D_diff_sat;              // 7-bit signed number (represents derivative of error)
reg signed [9:0] ptch_err_sat;     // 10-bit pitch error term (signed)
reg signed [9:0] ptch_err_I;         // 10-bit integral of the error term (signed)
wire rev;                                              //Rev means we are driving motor in reverse (1=>reverse, 0=>forward)
wire [10:0] mtr_duty;
 
duty inst_duty(.ptch_D_diff_sat(ptch_D_diff_sat), .ptch_err_sat(ptch_err_sat), .ptch_err_I(ptch_err_I), .rev(rev), .mtr_duty(mtr_duty));
 
 
initial begin
 
ptch_D_diff_sat = 7'b000_0000;
ptch_err_sat = 10'b00_0000_0000;
ptch_err_I           = 10'b0000000000;
 
#1;
 
ptch_D_diff_sat = 7'b000_0001; 
ptch_err_sat = 10'b00_0000_0001;
ptch_err_I           = 10'b00_0000_0001;
 
#1;
 
ptch_D_diff_sat = 7'b000_1000; 
ptch_err_sat = 10'b00_0000_0010;
ptch_err_I           = 10'b00_0001_0000;
 
 
#1;
 
ptch_D_diff_sat = 7'b100_1000;
ptch_err_sat = 10'b00_0000_0010;
ptch_err_I           = 10'b00_0001_0000;
 
#1;
 
ptch_D_diff_sat = 7'b000_1111;
ptch_err_sat = 10'b00_0010_0000; 
ptch_err_I           = 10'b10_0000_0011;
 
 
#1;
 
ptch_D_diff_sat = 7'b100_1000;
ptch_err_sat = 10'b10_0000_0001; 
ptch_err_I           = 10'b10_0001_0000;


#1;
 
ptch_D_diff_sat = 7'b100_1000;
ptch_err_sat = 10'b10_0000_0001; 
ptch_err_I           = 10'b00_0001_0000;
 

#30;
$stop();
 
end
 
/*
 
  reg signed [3:0] a = 3;
  reg [3:0] ua = 3;
  reg signed [4:0] b = 4;
  reg [4:0] ub = 4;
  wire signed [8:0] c;
  wire [8:0] uc;
  assign c = a*b;
  assign uc = ua * ub;
  reg [2:0] x = 3'b010;
  reg [2:0] xx = 3'b110;
  reg signed [5:0] y,yy;
  reg signed [2:0] z = 3'b010;
  reg signed [6:0] zz;
  reg signed [5:0] zz1;
  reg [3:0] ab;
  reg [4:0] ab1;
reg signed [4:0] ab4 = 5'b010;
initial
begin
    #1       $display("c= %d", c);
               $display("a= %d", a);
                $display("b= %d", b);
                $display("ua= %d", ua);
                $display("ub= %d", ub);
                $display("uc= %d", uc);
 
                #1;
        assign y = $signed(x);
                assign yy = $signed(xx);
 
                $display("y= %b", y);
                $display("yy= %b", yy);
 
                $display("x= %b", x);
                $display("xx= %b", xx);
  #1;
    a = 7;
ua = 7;
    b = 4;
ub = 4;
                #1;
 
 
#1;
 
$display("exp");
 
assign zz = z * {1'b0,$signed('d5)};
assign zz1 = z * {1'b0,$signed('d5)};
 
                $display("z= %d", z);
               $display("zz= %d", zz);
                $display("zz1= %d", zz1);
 
assign ab = ABS(ab4);
assign ab1= ABS(ab4);
               $display("abv= %d", ab4);
                $display("ab= %d", ab);
               $display("ab1= %d", ab1);
                
                
 
#1;
 
                $display("c= %d", c);
               $display("a= %d", a);
                $display("b= %d", b);
                $display("ua= %d", ua);
                $display("ub= %d", ub);
                $display("uc= %d", uc);
  #1;
 
 
end
  */

endmodule