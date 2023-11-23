`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// Design Name: Im2col
// Module Name: valid_sqaures_param
// Project Name: CNN Acceleration
// Description: Index to coordinate conversion block is followed by valid squares block, here-
//              -- If the below nine conditions are satisfied valid bits will go high and that gives the number of 
//                 squares in which an element would be part of.  
//              -- To optimize the code we are first performing the addition and subtraction operation followed by comparison operation
//              -- The size of the kernel is 3*3 so we can expect each patch of the image to have 9 blocks/
//                 coordinates enclosed within it and so the 9 various conditions. 
//              -- The square is considered to be a valid one if the filter that is covering that patch of the image
//                 is within the image boundary i.e. 224*224-matrix size.
//////////////////////////////////////////////////////////////////////////////////







module valid_squares_param #(
  parameter WIDTH = 9,
  parameter UPPER_BOUND = 224, 
  parameter LOWER_BOUND = 1)(
  input                      clk,
  input                      rstn,
  input signed [WIDTH-1:0]   curr_row,
  input signed [WIDTH-1:0]   curr_col,
  output [8:0]               valid,           
  input [7:0]                valid_sq_data_i,   //Input data from the previous block 
  output [7:0]               valid_sq_data_o    //Output data
);
  reg signed [WIDTH-1:0]     row = 9'd0;
  reg signed [WIDTH-1:0]     col = 9'd0;
  reg [8:0]      valid_reg = 9'd0;
  reg signed [8:0]     row1 = 9'd0;
  reg signed [8:0]     row2 = 9'd0;
  reg signed [8:0]     row3 = 9'd0;
  reg signed [8:0]     row4 = 9'd0;
  reg signed [8:0]     col1 = 9'd0;
  reg signed [8:0]     col2 = 9'd0;
  reg signed [8:0]     col3 = 9'd0;
  reg signed [8:0]     col4 = 9'd0;
 // reg [7:0]            reg_im2col_data = 8'd0; 
always @(posedge clk) begin
  if(!rstn) begin
    row <= 9'd0;
    col <= 9'd0;
  end else begin
  row1 <= curr_row + 1;  //
  row2 <= curr_row + 2;
  row3 <= curr_row - 1;
  row4 <= curr_row - 2;
  col1 <= curr_col + 1;
  col2 <= curr_col + 2;
  col3 <= curr_col - 1;
  col4 <= curr_col - 2; 
  row <= curr_row;
  col <= curr_col;
  end
 end  
 
always @(posedge clk) begin
  if(!rstn) begin
    valid_reg[0] <= 0;
    valid_reg[1] <= 0;
    valid_reg[2] <= 0;
    valid_reg[3] <= 0;
    valid_reg[4] <= 0;
    valid_reg[5] <= 0;
    valid_reg[6] <= 0;
    valid_reg[7] <= 0;
    valid_reg[8] <= 0;
  end else if(((row >= LOWER_BOUND) && (col >= LOWER_BOUND)) && (((row2) <= UPPER_BOUND) && ((col2) <= UPPER_BOUND))) begin
    valid_reg[0] <= 1;  // 0th bit is assigned 1 if the above condition is satisfied. 
  end else begin 
    valid_reg[0] <= 0;
  end
  
  if((((row3) >= LOWER_BOUND) && (col >= LOWER_BOUND)) && (((row1) <= UPPER_BOUND) && ((col2) <= UPPER_BOUND))) begin
    valid_reg[1] <= 1;  // 1st bit is assigned 1 if the above condition is satisfied. 
  end else begin 
    valid_reg[1] <= 0;
  end
  
  if((((row4) >= LOWER_BOUND) && (col >= LOWER_BOUND)) && ((row <= UPPER_BOUND) && ((col2) <= UPPER_BOUND))) begin
    valid_reg[2] <= 1;  // 2nd bit is assigned 1 if the above condition is satisfied. 
  end else begin 
    valid_reg[2] <= 0;
  end
  
  if(((row >= LOWER_BOUND) && ((col3) >= LOWER_BOUND)) && (((row2) <= UPPER_BOUND) && ((col1) <= UPPER_BOUND))) begin
    valid_reg[3] <= 1;  // 3rd bit is assigned 1 if the above condition is satisfied. 
  end else begin 
    valid_reg[3] <= 0;
  end
  
  if((((row3) >= LOWER_BOUND) && ((col3) >= LOWER_BOUND)) && (((row1) <= UPPER_BOUND) && ((col1) <= UPPER_BOUND))) begin
    valid_reg[4] <= 1;  // 4th bit is assigned 1 if the above condition is satisfied. 
  end else begin 
    valid_reg[4] <= 0;
  end
  
  if((((row4) >= LOWER_BOUND) && ((col3) >= LOWER_BOUND)) && (((row) <= UPPER_BOUND) && ((col1) <= UPPER_BOUND))) begin
    valid_reg[5] <= 1;  // 5th bit is assigned 1 if the above condition is satisfied. 
  end else begin 
    valid_reg[5] <= 0;
  end  
  
  if(((row >= LOWER_BOUND) && ((col4) >= LOWER_BOUND)) && (((row2) <= UPPER_BOUND) && (col <= UPPER_BOUND))) begin
    valid_reg[6] <= 1;  // 6th bit is assigned 1 if the above condition is satisfied. 
  end else begin 
    valid_reg[6] <= 0;
  end   
  
  if((((row3) >= LOWER_BOUND) && ((col4) >= LOWER_BOUND)) && (((row1) <= UPPER_BOUND) && (col <= UPPER_BOUND))) begin
    valid_reg[7] <= 1;  // 7th bit is assigned 1 if the above condition is satisfied. 
  end else begin 
    valid_reg[7] <= 0;
  end  
  
  if((((row4) >= LOWER_BOUND) && ((col4) >= LOWER_BOUND)) && ((row  <= UPPER_BOUND) && (col <= UPPER_BOUND))) begin
    valid_reg[8] <= 1;  // 8th bit is assigned 1 if the above condition is satisfied. 
  end else begin 
    valid_reg[8] <= 0;
  end 
 end

   assign valid = valid_reg; 
   assign valid_sq_data_o = valid_sq_data_i;
endmodule


