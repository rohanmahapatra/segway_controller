module UpDownCounter(clk,en,rst_n,dwn,cnt);

input clk,en,rst_n,dwn;
output reg [3:0]cnt;


always @(posedge clk) begin
	if(!rst_n) begin
            cnt<=0;
	// question says that only after up count, it starts down count, so should we initialize cnt to 44 when dwn is high during rst_n.
         end
        else if (en) begin
        if(dwn==0)
            cnt<=cnt+1;
        else
            cnt<=cnt-1;
        end
   end
  

endmodule




