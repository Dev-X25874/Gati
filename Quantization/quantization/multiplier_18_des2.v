`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Multiplier  
// Module Name: multiplier_18_des2
// Project Name: CNN Acceleration- GATI
// Description: It is a multiplier which multiplies two numbers. 
//////////////////////////////////////////////////////////////////////////////////


module multiplier_18_des2(
  input clk,
  input [17:0]  dina,
  input [17:0]  dinb,
  output [35:0] dout
);

  reg [35:0] rdout=0;

always @ (posedge clk) begin
  rdout <= dina * dinb;
end
  assign dout = rdout;
endmodule
