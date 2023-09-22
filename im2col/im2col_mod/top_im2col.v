`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// Design Name: Im2col
// Module Name: Top Im2col
// Project Name: CNN Acceleration
// Description: The im2col operation is a transformation applied to image data in deep learning. 
//              It reshapes image patches into columns, simplifying convolutions and enabling matrix operations. 
//              This enhances efficiency in neural networks by utilizing optimized matrix multiplication for convolutional
//              layers.
//              For the ease of implementation im2col is divided into 3 sub-modules- 
//              1. Index to Co-ordinate conversion
//              2. Calculation of the number of valid squares
//              3. Assigning a constant value for rows 
//////////////////////////////////////////////////////////////////////////////////


module top_im2col#(parameter WIDTH=8,
                   parameter VALID=9)(
  input [WIDTH-1:0]   i_im2col_data,
  input               i_clk,
  input               i_rstn,
  output [WIDTH-1:0]  o_im2col_data,
  output [VALID-1:0]  o_valid_squares,
  output [8:0]        o_row1,
  output [8:0]        o_row2,
  output [8:0]        o_row3,
  output [8:0]        o_row4,
  output [8:0]        o_row5,
  output [8:0]        o_row6,
  output [8:0]        o_row7,
  output [8:0]        o_row8,
  output [8:0]        o_row9                
    );
  wire [8:0]  w_row;    
  wire [8:0]  w_col;
  wire [7:0]  w_data;
  wire [7:0]  w_data_squares2rows;
  wire [8:0]  w_valid_squares;    
index_2_coordinate_conv # (.WIDTH(224))
index_2_coordinate_module (
  .clk(i_clk),
  .rstn(i_rstn),
  .row(w_row),
  .col(w_col),
  .data_i(i_im2col_data),
  .data_o(w_data)
);

valid_squares_param #(
  .WIDTH(9),
  .UPPER_BOUND(224),
  .LOWER_BOUND(1))
valid_squares_module(
  .clk(i_clk),
  .rstn(i_rstn),
  .curr_row(w_row),
  .curr_col(w_col),
  .valid(w_valid_squares),
  .valid_sq_data_i(w_data),
  .valid_sq_data_o(w_data_squares2rows)
);
valid_rows 
valid_rows_module(
  .clk(i_clk),
  .rstn(i_rstn),
  .valid(w_valid_squares),
  .valid_row_data_i(w_data_squares2rows),
  .valid_row_data_o(o_im2col_data),
  .valid_sq_o(o_valid_squares),
  .row1(o_row1),
  .row2(o_row2),
  .row3(o_row3),
  .row4(o_row4),
  .row5(o_row5),
  .row6(o_row6),
  .row7(o_row7),
  .row8(o_row8),
  .row9(o_row9) 
    );
endmodule





