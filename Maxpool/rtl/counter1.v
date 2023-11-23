`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.09.2023 17:36:22
// Design Name: first counter
// Module Name: counter1
// Project Name: maxpool
// Target Devices: 
// Tool Versions: 
// Description: the first counter is to toggle the delect line of the first demux 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module counter1(
  input clk,
  input rst,
  output [0:0] sel, //toggles at every posedge of the clock
  output [0:0] count
    );
  reg [0:0] counter=0;
  reg [0:0] toggle=0;    
  assign sel = toggle;
    
  always @ (posedge clk)
  begin
    if(rst==1'b0) begin
      counter <= 1'b0; 
      toggle <= 1'b0;
    end
    else begin
      toggle <= ~toggle;
      counter <= counter + 1;
    end
  end
  assign count = counter;   
endmodule
