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


module demux2 #(parameter DATA_IN = 8) (
  input [DATA_IN - 1 : 0] data_in,
  input sel, //gets toggled by counter2 module
  input clk,
  input rst,
  input datavalid, //valid data acknowledgment sent by the previous module
  output reg [DATA_IN  : 0] fifo1 = 0,
  output reg [DATA_IN  : 0] fifo2 = 0
    );
    reg dv = 0;
    reg [7:0] x=0;
  
  always @(posedge clk) begin
    if (sel) begin
      fifo2 <= {dv, x};
      fifo1 <= 9'd0;
    end
    else begin
      fifo1 <= {dv, x};
      fifo2 <= 9'd0;
    end
  end
  always @(posedge clk)begin
    x <= data_in;
    dv <= datavalid;
  end
endmodule
