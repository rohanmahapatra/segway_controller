module tb_inertial_integrator();

logic clk, rst_n;
logic vld;
logic [15:0]ptch_rt;
logic [15:0]AZ;
logic [15:0]ptch;

/////////////////////////////////////////////////// DUT ////////////////////////////////////////////////////////////// 

inertial_integrator iDUT(.clk(clk), .rst_n(rst_n), .vld(vld), .ptch_rt(ptch_rt), .AZ(AZ), .ptch(ptch));

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

localparam PTCH_RT_OFFSET = 16'h03C2; 			// offset in ptch_rt


initial begin

rst_n = 0;
clk = 0;

repeat (2) @ (negedge clk);

rst_n = 1;
ptch_rt = 16'h1000 + PTCH_RT_OFFSET;			
AZ = 16'h0000;
vld = 1;

repeat (500) @ (negedge clk);
ptch_rt = PTCH_RT_OFFSET;
repeat (1000) @ (negedge clk);
ptch_rt = PTCH_RT_OFFSET - 16'h1000;
repeat (500) @ (negedge clk);
ptch_rt = PTCH_RT_OFFSET;
repeat (1000) @ (negedge clk);
AZ = 16'h0800;
repeat (1000) @ (negedge clk);
$stop();

end

always #5 clk = ~clk;


endmodule

