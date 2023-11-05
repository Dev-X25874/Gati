`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.09.2023 16:57:42
// Design Name: first demux
// Module Name: demux1
// Project Name: maxpool
// Target Devices: 
// Tool Versions: 
// Description: the first demux takes the input from the relu block one by one. the first input from the relu block, after passing through the first demux, goes into a register and waits there for the second input from the relu to pass through the first demux. then they together get loaded into the next block i.e. first maxpool. 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module demux1(
  input [7:0] din,
  input sel,
  input clk,
  input datavalid,
  output [8:0] a,
  output [8:0] b,
  output reg [8:0] c=0
);
  reg [7:0] x=0;
  assign a = (sel==1'b0)? {datavalid, x} : 9'b000000000;
  assign b = (sel==1'b1)? {datavalid, x} : 9'b000000000; 

  always @(posedge clk)
  begin
  c <= a;
  x <= din;
  end

endmodule