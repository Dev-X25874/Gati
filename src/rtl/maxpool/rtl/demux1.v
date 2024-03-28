
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
  input sel,   //counter1 toggles the select line 
  input clk,
  input rx_valid,
  input datavalid, //this 'datavalid' is a valid data acknowledgement from the block prior to the maxpool block
  output reg [8:0] a = 0 ,
  output reg [8:0] b = 0 ,
  output reg [8:0] c = 0
);
  reg dv = 0;
  reg [8:0] temp = 0;
  reg [8:0] delay = 0;
  reg [7:0] x = 0;
 /* assign a = (sel==1'b1)? {datavalid, x} : 9'd0;  
  assign b = (sel==1'b0)? {datavalid, x} : 9'd0; */

  always @ (posedge clk) begin
    if(sel) begin
      a <= {datavalid, din};
      b <= {0, b[7:0]};
    end
    else begin
      a <= {0, a[7:0]};
      b <= {datavalid, din};
    end
  end 

 // always @(posedge rx_valid)
  always @(posedge datavalid)
  begin
  // temp <= a;  //the first input from the previous block gets assigned to a reg, hence waiting for the second input because the next module is maxpool. Maxpooling requires two input at the same time.
  // c <= temp;
  // x <= din;
  //dv <= datavalid;
    c <= a;
  end

endmodule