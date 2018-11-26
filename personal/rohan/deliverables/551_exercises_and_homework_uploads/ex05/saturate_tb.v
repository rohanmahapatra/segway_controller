module saturate_tb();
 
reg [15:0] unsigned_err;               //            in16-bitunsignederror term to be reduced/saturated to 10-bits
wire [9:0] unsigned_err_sat;       //out10-bit saturated version of unsigned_err[15:0].   How wouldunsigned saturation to a 10-bit value work?
reg [15:0] signed_err;                     // in16-bit signednumber to be reduced/saturated to 10-bits. 
wire [9:0] signed_err_sat;            //out10-bit saturated version of signed_err[15:0]. If result is positive and greater than 0x1FF then it saturates to 0x1FF.  If result is morenegative than 0x200 then it saturates to 0x200
reg [9:0] signed_D_diff; //in10-bit signed version of a difference term used for derivative calculation
wire [6:0] signed_D_diff_sat;      //out7-bit signed saturated version of signed_D_diff[9:0]
 
saturate iDUT (unsigned_err, unsigned_err_sat, signed_err, signed_err_sat, signed_D_diff, signed_D_diff_sat);
 
initial begin
                
unsigned_err = 16'hfff0;
signed_err = 16'h7ff0;
signed_D_diff = 10'h1f0;
 
#5;
 
unsigned_err = 16'h00f0;
signed_err = 16'h0ff0;
signed_D_diff = 10'h0f0;
 
#5;
 
unsigned_err = 16'h0111;
signed_err = 16'h8000;
signed_D_diff = 10'h200;
 
#5;

unsigned_err = 16'h0001;
signed_err = 16'ha000;
signed_D_diff = 10'h300;


end  
 
 
 
//initial $monitor( "time = %t", $time); // working
 
//initial #2000 $finish;                    // end simulation, quit program
 
//initial begin
//#5 for (A = 0; A < 16; A = A + 1) begin        // exhaustive test of inputs
//       for (B = 0; B < 16; B = B + 1) begin #5;  // may want to test x’s and z’s
//       end // first for
//     end // second for
//end // initial
 
 
 
endmodule
 
 