module Segway_tb_h();
//// Interconnects to DUT/support defined as type wire /////
wire SS_n,SCLK,MOSI,MISO,INT; // to inertial sensor
wire A2D_SS_n,A2D_SCLK,A2D_MOSI,A2D_MISO; // to A2D converter
wire RX_TX;
wire PWM_rev_rght, PWM_frwrd_rght, PWM_rev_lft, PWM_frwrd_lft;
wire piezo,piezo_n;

////// Stimulus is declared as type reg ///////
reg clk, RST_n;
reg [7:0] cmd; // command host is sending to DUT
reg send_cmd; // asserted to initiate sending of command
reg signed [15:0] rider_lean;
reg [11:0] ld_cell_lft, ld_cell_rght,batt; // A2D values

///// Internal event counters /////////
reg clr_peak_mins_n;
reg [15:0] A2D_SPI_events;
reg signed [15:0] omega_peak,omega_min;
reg signed [15:0] theta_peak,theta_min;


wire [7:0] LED;
wire cmd_sent;
wire rst_n; // synchronized global reset


////////////////////////////////////////////////////////////////
// Instantiate Physical Model of Segway with Inertial sensor //
////////////////////////////////////////////////////////////// 
SegwayModel iPHYS(.clk(clk),.RST_n(RST_n),.SS_n(SS_n),.SCLK(SCLK),
                  .MISO(MISO),.MOSI(MOSI),.INT(INT),.PWM_rev_rght(PWM_rev_rght),
  .PWM_frwrd_rght(PWM_frwrd_rght),.PWM_rev_lft(PWM_rev_lft),
  .PWM_frwrd_lft(PWM_frwrd_lft),.rider_lean(rider_lean));   

/////////////////////////////////////////////////////////
// Instantiate Model of A2D for load cell and battery //
///////////////////////////////////////////////////////
ADC128S iA2D(.clk(clk),.rst_n(RST_n),.SS_n(A2D_SS_n),.SCLK(A2D_SCLK),
             .MISO(A2D_MISO),.MOSI(A2D_MOSI),.batt_set(batt_set), .lft_cell_set(ld_cell_lft), .rght_cell_set(ld_cell_rght));

 
////// Instantiate DUT ////////
Segway iDUT(.clk(clk),.RST_n(RST_n),.LED(),.INERT_SS_n(SS_n),.INERT_MOSI(MOSI),
            .INERT_SCLK(SCLK),.INERT_MISO(MISO),.A2D_SS_n(A2D_SS_n),
.A2D_MOSI(A2D_MOSI),.A2D_SCLK(A2D_SCLK),.A2D_MISO(A2D_MISO),
.INT(INT),.PWM_rev_rght(PWM_rev_rght),.PWM_frwrd_rght(PWM_frwrd_rght),
.PWM_rev_lft(PWM_rev_lft),.PWM_frwrd_lft(PWM_frwrd_lft),
.piezo_n(piezo_n),.piezo(piezo),.RX(RX_TX));

/////// Count A2D_SPI_events //////
always @(negedge A2D_SS_n, negedge RST_n)
  if (!RST_n)
    A2D_SPI_events <= 16'h0000;
  else
    A2D_SPI_events <= A2D_SPI_events + 1;
/////// Keep track of physical peak/mins //////
assign rst_peak_mins_n = RST_n & clr_peak_mins_n;
always @(negedge SS_n, negedge rst_peak_mins_n)
  if (!rst_peak_mins_n) begin
    omega_min <= 16'h0000;
    omega_peak <= 16'h0000;
    theta_min <= 16'h0000;
    theta_peak <= 16'h0000;
  end else begin
    omega_min <= (iPHYS.omega_platform<omega_min) ? iPHYS.omega_platform : omega_min;
omega_peak <= (iPHYS.omega_platform>omega_peak) ? iPHYS.omega_platform : omega_peak;
    theta_min <= (iPHYS.theta_platform<theta_min) ? iPHYS.theta_platform : theta_min;
theta_peak <= (iPHYS.theta_platform>theta_peak) ? iPHYS.theta_platform : theta_peak; 
  end 
//// Instantiate UART_tx (mimics command from BLE module) //////
UART_tx iTX(.clk(clk),.rst_n(rst_n),.TX(RX_TX),.trmt(send_cmd),.tx_data(cmd),.tx_done(cmd_sent));

/////////////////////////////////////
// Instantiate reset synchronizer //
///////////////////////////////////
rst_synch iRST(.clk(clk),.RST_n(RST_n),.rst_n(rst_n));

initial begin
  Initialize;
  ////// Start issuing commands to DUT //////
 
  repeat(50000) @(posedge clk);
  
  SendCmd(8'h67); // send 'g' to enable segway

  repeat(50000) @(posedge clk);
  
  ld_cell_lft = 12'h180;
  ld_cell_rght = 12'h180;
  rider_lean = 16'h1FFF;
  
  repeat (300000) @(posedge clk);
  
  if (out_of_range(omega_min,$signed(-16'd15568),16'd4000)) begin
    $display("ERR: omega_min not in expected range, was %d, expect -15726",omega_min);
$finish();
  end
 
  if (out_of_range(omega_peak,$signed(16'd8140),16'd2100)) begin
    $display("ERR: omega_peak not in expected range, was %d, expect 8647",omega_peak);
 //   $finish();
$stop();
  end 
  
  if (out_of_range(theta_min,$signed(16'd0),16'd200)) begin
    $display("ERR: theta_min not in expected range, was %d, expect 0",theta_min);
$finish();
  end
 
  if (out_of_range(theta_peak,$signed(16'd9839),16'd1200)) begin
    $display("ERR: theta_peak not in expected range, was %d, expect 10175",theta_peak);
$finish();
  end
  
  repeat (750000) @(posedge clk);
  
  if (out_of_range(iPHYS.theta_platform,$signed(16'd935),16'd350)) begin
    $display("ERR: theta_platform not in expected range, was %d, expect 910 ish",iPHYS.theta_platform);
$finish();
  end  

  $display("omega_min = %d, omega_peak = %d",omega_min,omega_peak);
  $display("theta_min = %d, theta_peak = %d",theta_min,theta_peak);
  $display("theta_platform = %d",iPHYS.theta_platform);
  
  clr_peak_mins_n = 0;
  @(posedge clk);
  clr_peak_mins_n = 1;
  
  rider_lean = 16'h0000;
  
  repeat (750000) @(posedge clk);
  
  if (out_of_range(omega_min,$signed(-16'd6702),16'd2000)) begin
    $display("ERR: omega_min not in expected range, was %d, expect -6929",omega_min);
//$finish();
  end
 
  if (out_of_range(omega_peak,$signed(16'd15618),16'd4000)) begin
    $display("ERR: omega_peak not in expected range, was %d, expect 15645",omega_peak);
$finish();
  end 
  
  if (out_of_range(theta_min,$signed(-16'd7981),16'd1100)) begin
    $display("ERR: theta_min not in expected range, was %d, expect -7817",theta_min);
$finish();
  end
 
  if (out_of_range(theta_peak,$signed(16'd907),16'd270)) begin
    $display("ERR: theta_peak not in expected range, was %d, expect 898",theta_peak);
$finish();
  end
  
  if (out_of_range(iPHYS.theta_platform,$signed(-16'd1077),16'd1000)) begin
    $display("ERR: theta_platform not in expected range, was %d, expect -1130 ish",iPHYS.theta_platform);
$finish();
  end 
  
  $display("omega_min = %d, omega_peak = %d",omega_min,omega_peak);
  $display("theta_min = %d, theta_peak = %d",theta_min,theta_peak);
  $display("theta_platform = %d",iPHYS.theta_platform);
  $display("YAHOO! test2 passed!");
  
  $finish();
end

always
  #10 clk = ~clk;

`include "tb_tasks.v"

endmodule 
