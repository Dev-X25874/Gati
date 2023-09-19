`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// Design Name: Im2col
// Module Name: Valid Rows
// Project Name: CNN Acceleration
// Description: The last sub-block of the module, here-
//              The nine rows are assigned with constant values form 1 to 9 
//              -- When the patch of the image is converted into its corresponding column, it'd yield us 9 rows, hence
//                 9 rows are driven. Of these 9 rows few can be valid which is given by the valid_sq_o.
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module valid_rows(
  input             clk,
  input             rstn,
  input [8:0]       valid,
  input [7:0]       valid_row_data_i,
  output [7:0]      valid_row_data_o,
  output [8:0]      valid_sq_o,
  output [8:0]         row1,  
  output [8:0]         row2,  
  output [8:0]         row3,  
  output [8:0]         row4,  
  output [8:0]         row5,  
  output [8:0]         row6,  
  output [8:0]         row7,  
  output [8:0]         row8,  
  output [8:0]         row9  
    );
  reg [8:0]         reg_valid_rows=9'd0;
  reg [8:0]         r_row1=4'd0;
  reg [8:0]         r_row2=4'd0;
  reg [8:0]         r_row3=4'd0;
  reg [8:0]         r_row4=4'd0;
  reg [8:0]         r_row5=4'd0;
  reg [8:0]         r_row6=4'd0;
  reg [8:0]         r_row7=4'd0;
  reg [8:0]         r_row8=4'd0;
  reg [8:0]         r_row9=4'd0; 
always @(posedge clk) begin
  if(!rstn) begin
  r_row1<=4'd0;
  r_row2<=4'd0;
  r_row3<=4'd0;
  r_row4<=4'd0;
  r_row5<=4'd0;
  r_row6<=4'd0;
  r_row7<=4'd0;
  r_row8<=4'd0;
  r_row9<=4'd0;
  
  end else begin  
  r_row1<=4'd1;
  r_row2<=4'd2;
  r_row3<=4'd3;
  r_row4<=4'd4;
  r_row5<=4'd5;
  r_row6<=4'd6;
  r_row7<=4'd7;
  r_row8<=4'd8;
  r_row9<=4'd9;
  end
end

assign valid_rows = reg_valid_rows;
assign valid_row_data_o = valid_row_data_i;
assign valid_sq_o = valid;
assign row1 = r_row1;
assign row2 = r_row2;
assign row3 = r_row3;
assign row4 = r_row4;
assign row5 = r_row5;
assign row6 = r_row6;
assign row7 = r_row7;
assign row8 = r_row8;
assign row9 = r_row9;

endmodule
