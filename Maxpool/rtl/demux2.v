`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.09.2023 17:22:45
// Design Name: second demux 
// Module Name: demux2
// Project Name: maxpool
// Target Devices: 
// Tool Versions: 
// Description: the second demux as per the select line, which toggles at count of 224, saves the result from the first maxpool into FIFO1 and FIFO2, respectively. 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module demux2(
  input [7:0] data_in,
  input sel, //gets toggled by counter2 module
  input clk,
  input rst,
  input datavalid, //valid data acknowledgment sent by the previous module
  output [8:0] fifo1,
  output [8:0] fifo2
    );
  reg [7:0] x=0;
  assign fifo1 = (sel==1'b0)? {datavalid,x} : 9'b0_0000_0000; //total elements of the first matrix column, each of 1 byte, gets stored in fifo1
  assign fifo2 = (sel==1'b1)? {datavalid,x} : 9'b0_0000_0000; //the next batch of elements of next matrix column, each of 1 byte, gets stored in fifo2

  always @(posedge clk)begin
  x<=data_in;
  end
endmodule
