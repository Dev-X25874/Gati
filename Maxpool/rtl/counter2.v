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
  input datavalid,
  output [0:0] sel,
  output [7:0] count
    );
  reg [7:0] counter=0;
  reg [0:0] toggle=0;
  assign sel = toggle;    
    
  always @ (posedge clk)
  begin
    if(rst==1'b0) begin
      counter <= 8'b00000000;
      toggle <= 1'b0;
    end
    else begin
      if(datavalid)begin
        if(counter < 8'd224)begin
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
  assign count = counter;   
endmodule
