`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 29.09.2023 09:52:50
// Design Name: 
// Module Name: tb_right_shifter_parameter
// Project Name: CNN acceleration - GATI 
// Description: This is the tb for the sub-module right_shifter_des2 in quantization
//
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_right_shifter_des2();
reg clk = 0;
reg[35:0] din_mul = 1024;
wire[35:0] dout_shifted;
integer i;

top_right_shifter
dut(
.clk(clk),
.din_mul_top(din_mul),
.dout_shifted_top(dout_shifted));

always #5 clk <= ~clk;

initial begin
#5 
    for(i=0;i<262143;i=i+1) begin
    #10 din_mul= i*10;
    end   
   end   
endmodule


