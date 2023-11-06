`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.09.2023 16:56:40
// Design Name: maxpool 
// Module Name: maxpool
// Project Name: maxpool 
// Target Devices: 
// Tool Versions: 
// Description: this maxpool block is used for maxpooling for the first as well as the second time. 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module maxpool(
  input clk,
  input datavalid,
  input [7:0] dina,
  input [7:0] dinb,
  output reg [8:0] temp=0
    );
    
  always @(posedge clk)
  begin
    if(datavalid) begin
      if(dina>dinb)begin
        temp<= {datavalid,dina};
      end
      else 
      begin
        temp<={datavalid,dinb};
      end
    end
  end
endmodule
