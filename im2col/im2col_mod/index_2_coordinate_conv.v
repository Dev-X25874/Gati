`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// Design Name: Im2col
// Module Name: Index to co-ordinate conversion
// Project Name: CNN Acceleration
// Description: The first sub-block of im2col where,
//              -- The input data will be getting its respective coordinate(i.e. rows and column) 
//////////////////////////////////////////////////////////////////////////////////


module index_2_coordinate_conv # (parameter WIDTH = 224) (
  input wire         clk,
  output [8:0]       row,
  output [8:0]       col,
  input [7:0]        data_i,
  input              rstn,
  output [7:0]   data_o

);

  reg [8:0]          curr_row=8'd1;
  reg [8:0]          curr_col=8'd1;
  assign row = curr_row;
  assign col = curr_col;

  always @(posedge clk) begin
    if(!rstn) begin
      curr_col <= 8'd0;
      curr_row <= 8'd0;
    end
    else if (curr_col == WIDTH) begin 
      curr_col <= 1;                  //curr_col is assigned to 1 if the curr_col exceeds the WIDTH
      curr_row <= curr_row + 1;       // meanwhile the curr_row is incremented and goes to the next row
    end else if (0 < curr_col < WIDTH) begin
      curr_col <= curr_col + 1;       //curr_col is incremented and goes to the next col
        end     
     end    

 assign data_o = data_i;
endmodule