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
// Description: The Maxpool module compares two 1-byte input values and outputs the maximum value. It takes two input bytes, determines the larger of the two, and assigns that value to the output variable. Essentially, it performs a max-pooling operation on the input bytes, selecting the maximum value for further processing. 
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
  input datavalid, // it is a valid data acknowledgment coming from a module before
  input [7:0] dina,
  input [7:0] dinb,
  output reg [8:0] temp=0 //the greater of the two inputs gets assigned to this variable.
    );
    
  always @(posedge clk)
  begin
    if(datavalid) begin
      if(dina > dinb)begin  //compares two inputs of 1 byte each, at a time
        temp <= {datavalid,dina}; 
      end
      else 
      begin
        temp <= {datavalid,dinb};
      end
    end
    else begin
      temp <= {0, temp[7:0]};
    end
  end
endmodule
