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


/*module counter2(
  input clk,
  input rst,
  input datavalid, //valid data acknowledgment coming from thr prior module
  input [7:0] dynamic_threshold,  
  output  sel, //toggling depends upon the size of a matrix column(earlier one matrix column was assumed to have 0-224 elements each of size 1 byte, hence toggling of selectline was done after count 224).
  output reg [13:0] count = 0
    );

  reg [13:0] counter = 0;
  reg  toggle = 0;
  reg [1:0] state = 0;
  assign sel = toggle;

  parameter IDLE = 2'b00;
  parameter S1 = 2'b01;
    
  always @ (posedge clk)begin
    if(rst == 0) begin
      counter <= 14'd0;
      toggle <= 1'b0;
    end
    else begin
    case(state)
    IDLE: begin
        counter <= 0;
        if (datavalid) begin
          state <= S1;
        end
        else begin
          //counter <= counter;
          //toggle <= toggle;
          state <= IDLE;
        end
      //end
    end
    S1: begin
      if(counter == dynamic_threshold) begin
        counter <= 0;
        //toggle <= 0;
        state <= IDLE;
      end
      else begin
        counter <= counter + 1;
        state <= S1;
      end
    end
    endcase
  toggle <= (counter < (dynamic_threshold/2))? 1'b0 : 1'b1;
    end
  end
endmodule*/


module counter2(
  input clk,
  input datavalid,
  input rst,
  input [7:0] dynamic_threshold,
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
  /*  if(datavalid)begin
      if(counter == (dynamic_threshold >> 1))begin
        toggle <= 1;
        counter <= counter + 1;
      end
      else if(counter == dynamic_threshold)begin
        counter <= 0;
        toggle <= 0;
      end
      else begin
        counter <= counter + 1;
        toggle <= toggle;
      end
    end
  end*/

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
