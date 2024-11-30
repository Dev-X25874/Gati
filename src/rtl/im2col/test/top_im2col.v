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
//`include "valid_square.v"
//`include "total_rows.v"
//`include "index_to_coordinate.v"

module top_im2col#(parameter UPPER_BOUND = 28,
                   parameter DATA_WIDTH = 8,
                   parameter LOWER_BOUND = 1,
                   parameter MAX_VALID_SQ = 9)(
  input                             i_valid_mat_size,
 // output                            o_start_im2col,
  input                             i_start_im2col_top,
//  input [DATA_WIDTH-1:0]            i_im2col_data,
  input                             i_clk,
  input                             i_rstn,
  output [DATA_WIDTH-1:0]           o_im2col_data,
  output [MAX_VALID_SQ-1:0]         o_valid_squares,
  output [4:0]                      o_row1,
  output [4:0]                      o_row2,
  output [4:0]                      o_row3,
  output [4:0]                      o_row4,
  output [4:0]                      o_row5,
  output [4:0]                      o_row6,
  output [4:0]                      o_row7,
  output [4:0]                      o_row8,
  output [4:0]                      o_row9,
  input [$clog2(UPPER_BOUND)-1:0]   i_mat_size,
  input                             i_zero_pad,
  output                            o_valid_data,
  output                            o_valid_buff,
  input                             i_valid_data

);
  wire [$clog2(UPPER_BOUND)-1:0]      w_row;    
  wire [$clog2(UPPER_BOUND)-1:0]      w_col;
  wire [DATA_WIDTH-1:0]               w_data;
  wire [DATA_WIDTH-1:0]               w_data_total_rows;
  wire [MAX_VALID_SQ-1:0]             w_valid_squares;  
  wire [$clog2(UPPER_BOUND)-1:0]      w_mat_size;
  wire                                w_valid_data;
  wire                                w_valid_data_rows;
index_to_coordinate # (.UPPER_BOUND(UPPER_BOUND),
                       .DATA_WIDTH(DATA_WIDTH),
                       .LOWER_BOUND(LOWER_BOUND))
index_to_coordinate_module (
  .valid_mat_size(i_valid_mat_size),
//  .o_start_im2col_ctrl (o_start_im2col),
  .i_start_im2col_index (i_start_im2col_top),
  .i_valid_data (i_valid_data),
  .clk(i_clk),
  .rstn(i_rstn),
  .row(w_row),
  .col(w_col),
 // .i_data(i_im2col_data),
  .o_data(w_data),
  .mat_size(i_mat_size),
  .o_mat_size(w_mat_size),
  .zero_pad(i_zero_pad),
  .o_valid_buff(o_valid_buff),
  .o_valid_data(w_valid_data)
);

valid_square #(.DATA_WIDTH(DATA_WIDTH),
                .UPPER_BOUND(UPPER_BOUND),
                .LOWER_BOUND(LOWER_BOUND),
                .MAX_VALID_SQ(MAX_VALID_SQ))
valid_square_module(
  .i_valid (w_valid_data),
  .mat_size (w_mat_size),
  .clk(i_clk),
  .rstn(i_rstn),
  .curr_row(w_row),
  .curr_col(w_col),
  .valid_sq(w_valid_squares),
  .valid_sq_data_i(w_data),
  .valid_sq_data_o(w_data_total_rows),
  .o_valid (w_valid_data_rows)
);

total_rows 
 #(
  .DATA_WIDTH(DATA_WIDTH),
  .MAX_VALID_SQ(MAX_VALID_SQ))
total_rows_module(
  .clk(i_clk),
  .rstn(i_rstn),
  .valid_sq_i(w_valid_squares),
  .valid_row_data_i(w_data_total_rows),
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
  .row9(o_row9),
  .i_valid_data(w_valid_data_rows),
  .o_valid_data(o_valid_data) 
);
endmodule





