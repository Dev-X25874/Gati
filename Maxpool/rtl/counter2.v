`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.09.2023 17:58:50
// Design Name: second counter
// Module Name: counter2
// Project Name: maxpool
// Target Devices: 
// Tool Versions: 
// Description: the second counter controls the select line of the second demux by toggling it when the count reaches 224(224 elements in each row after the first maxpool).
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module counter2(
  input clk,
  input rst,
  input datavalid, //valid data acknowledgment coming from thr prior module
  input [7:0] dynamic_threshold,  
  output [0:0] sel, //toggling depends upon the size of a matrix column(earlier one matrix column was assumed to have 0-224 elements each of size 1 byte, hence toggling of selectline was done after count 224).
  output [7:0] count
    );
  reg [7:0] counter=0;
  reg [0:0] toggle=0;
  reg [7:0] threshold = 8'd0;
  assign sel = toggle;    
    
  always @ (posedge clk)
  begin
    if(rst==1'b0) begin
      counter <= 8'd0;
      toggle <= 1'b0;
    end
    else begin
      if(datavalid)begin
        if(counter < threshold)begin
          toggle <= toggle;
          counter <= counter + 1;
         end
         else begin
           counter <= 0;
           toggle <= ~toggle; 
          end
       end           
    end
  end
  always @ (posedge clk) begin
    if(rst == 1'b0) begin
      threshold <= 8'b0;
    end
    else begin
      threshold <= dynamic_threshold;
    end
  end  
  assign count = counter;   
endmodule
