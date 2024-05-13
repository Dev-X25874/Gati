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
  input datavalid,
  input [7:0] dynamic_threshold,
  output sel, //toggles at every posedge of the clock
  output [13:0] count
    );
    reg [13:0] counter = 14'd1;
    reg toggle = 0;    
    assign sel = toggle;

    always @ (posedge clk) begin
      if(rst) begin
        counter <= 14'd1;
        toggle <= 1'b0;
      end
      else begin
        if(counter < (dynamic_threshold)) begin
          if(datavalid) begin
            toggle <= ~toggle;
            counter <= counter + 1;
          end
          else begin
            counter <= counter;
            toggle <= toggle;
          end
        end
        else begin
          toggle <= 1'b0;
          counter <= 14'd1;
        end
      end
    end
    assign count = counter;

endmodule