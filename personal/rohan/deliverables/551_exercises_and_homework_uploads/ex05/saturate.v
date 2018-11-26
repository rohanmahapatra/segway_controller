module saturate(unsigned_err, unsigned_err_sat, signed_err, signed_err_sat, signed_D_diff, signed_D_diff_sat);

 
input [15:0] unsigned_err;           //            in16-bitunsignederror term to be reduced/saturated to 10-bits
output [9:0] unsigned_err_sat; //out10-bit saturated version of unsigned_err[15:0].   How wouldunsigned saturation to a 10-bit value work?
input [15:0] signed_err;                                // in16-bit signednumber to be reduced/saturated to 10-bits. 
output [9:0] signed_err_sat;       //out10-bit saturated version of signed_err[15:0]. If result is positive and greater than 0x1FF then it saturates to 0x1FF.  If result is morenegative than 0x200 then it saturates to 0x200
input [9:0] signed_D_diff;            //in10-bit signed version of a difference term used for derivative calculation
output [6:0] signed_D_diff_sat; //out7-bit signed saturated version of signed_D_diff[9:0]




assign unsigned_err_sat = (unsigned_err>10'b1111111111)? 10'b1111111111 : unsigned_err[9:0];
assign signed_err_sat = signed_err[15] ? (!(&signed_err[15:10])? 10'b1000000000 : signed_err[9:0] ) : ((|signed_err[15:10]) ? 10'b0111111111: ({1'b0, signed_err[8:0]}));
 
assign signed_D_diff_sat = signed_D_diff[9] ? (!(&signed_D_diff[9:7])? 7'b1000000 : signed_D_diff[6:0] ) : ((|signed_D_diff[9:7]) ? 7'b0111111: ({1'b0, signed_D_diff[6:0]}));

endmodule 

