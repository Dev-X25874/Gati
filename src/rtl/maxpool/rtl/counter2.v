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

module counter2 #(parameter DATA_IN = 8) (
  input clk,
  input datavalid,
  input rst,
  input [DATA_IN - 1 : 0] dynamic_threshold, //it depends on the input dimension of the image width
  output sel
);
reg [13:0] counter=14'd0;
reg toggle=0;    
assign sel = toggle;

always @ (posedge clk) begin
  if(rst == 0) begin
    counter <= 14'd0;
    toggle <= 1'b0;
  end else
  begin
  if(counter == (dynamic_threshold/2)) begin
    if(datavalid) begin
      toggle <= 1;
      counter <= counter + 1;
    end
    else begin
      counter <= counter;
      toggle <= toggle;
    end
  end
  else if(counter == (dynamic_threshold)) begin
    if (datavalid) begin
      counter <= 14'd1                          ;
      toggle <= 0;
    end
    else begin
      counter <= counter;
      toggle <= toggle;
    end
  end
  else begin
    if(datavalid) begin
      counter <= counter + 1;
      toggle <= toggle;
    end
    else begin
      counter <= counter;
      toggle <= toggle;
    end
  end
end
end
endmodule
