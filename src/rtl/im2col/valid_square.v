`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Im2col
// Module Name: valid_sqaures_param
// Project Name: CNN Acceleration
// Description: Index to coordinate conversion block is followed by valid squares block, here-
//              -- If the below nine conditions are satisfied valid bits will go high and that gives the number of 
//                 squares in which an element would be part of.  
//              -- To optimize the code we are first performing the addition and subtraction operation followed by 
//                 comparison operation.
//              -- The size of the kernel is 3*3 so we can expect each patch of the image to have 9 blocks/
//                 coordinates enclosed within it and so the 9 various conditions. 
//              -- The square is considered to be a valid one if the filter that is covering that patch of the image
//                 is within the image boundary i.e. 224*224-matrix size.
// Revision 2 --> 21-11-2023 -- Additional comments were added
// Revision 3 --> 21-12-2023 -- The order in which valid squares were checked were changed. 
//////////////////////////////////////////////////////////////////////////////////


module valid_square #(
  parameter DATA_WIDTH = 8,
  parameter UPPER_BOUND = 226, 
  parameter LOWER_BOUND = 1,
  parameter MAX_VALID_SQ = 9)(
  input 						     	stall_on,
  input                               i_valid,
  input [$clog2(UPPER_BOUND)-1:0]     mat_size,     
  input                               clk,
  input                               rstn,
  input  [$clog2(UPPER_BOUND)-1:0]    curr_row,
  input  [$clog2(UPPER_BOUND)-1:0]    curr_col,
  output [MAX_VALID_SQ-1:0]           valid_sq,           
  input [DATA_WIDTH-1:0]              valid_sq_data_i,   //Input data from the previous block 
  output [DATA_WIDTH-1:0]             valid_sq_data_o,    //Output data
  output                              o_valid
);

  reg [MAX_VALID_SQ-1:0]            valid_sq_reg = 0;
  reg [DATA_WIDTH-1:0]              r_data_i = 0;
  reg [DATA_WIDTH-1:0]              r2_data_i = 0;


  wire [$clog2(UPPER_BOUND)-1:0]              row ;
  wire [$clog2(UPPER_BOUND)-1:0]              col ;
  wire signed [$clog2(UPPER_BOUND):0]     row1 ;
  wire signed [$clog2(UPPER_BOUND):0]     row2 ;
  wire signed [$clog2(UPPER_BOUND):0]     row3 ;
  wire signed [$clog2(UPPER_BOUND):0]     row4 ;
  wire signed [$clog2(UPPER_BOUND):0]     col1 ;
  wire signed [$clog2(UPPER_BOUND):0]     col2 ;
  wire signed [$clog2(UPPER_BOUND):0]     col3 ;
  wire signed [$clog2(UPPER_BOUND):0]     col4 ;
 
  assign row1 = curr_row + 1;  
  assign row2 = curr_row + 2;
  assign row3 = curr_row - 1;
  assign row4 = curr_row - 2;
  assign col1 = curr_col + 1;
  assign col2 = curr_col + 2;
  assign col3 = curr_col - 1;
  assign col4 = curr_col - 2; 
  assign row = curr_row;
  assign col = curr_col; 



//######################################################################################### 
/* -- The square is considered to be a valid one if the filter that is covering that patch of the image
      is within the image boundary i.e. 224*224-matrix size.
   -- Check If (x,y)/(row,column) is greater than 1 and if the input co-ordinate is bounded between (x,y) and (x+2,y+2).
      If so valid[0] goes high.
   -- Now from (x,y), go one column behind i.e. (x,y-1) and check if input co-ordinate is bounded between 
      (x,y-1) and (x+2,y+1). if so valid[1] goes high.
   -- Now from (x,y) we go two columns behind i.e. (x,y-2) and check if input co-ordinate is bounded between
      (x,y-2) and (x+2,y). if so valid[2] goes high.
   -- Then from (x,y) we go one row above i.e. (x-1,y) and check if input co-ordinate is bounded between
      (x-1,y) and (x+1,y+2). if so valid[3] goes high.
   -- Then from (x-1,y) we go one column behind i.e. (x-1,y-1) and check if input co-ordinate is bounded between
      (x-1,y-1) and (x+1,y+1). if so valid[4] goes high.  
   -- Then from (x-1,y) we go two columns behind i.e. (x-1,y-2) and check if input co-ordinate is bounded between
      (x-1,y-2) and (x+1,y). if so valid[5] goes high. 
   -- Now from (x,y) we go two rows above i.e. (x-2,y) and check if input co-ordinate is bounded between
      (x-2,y) and (x,y+2). if so valid[6] goes high.  
   -- Then from (x-2,y) we go one column behind i.e. (x-2,y-1) and check if input co-ordinate is bounded between
      (x-2,y-1) and (x,y+1). if so valid[7] goes high. 
   -- Then from (x-2,y) we go two columns behind i.e. (x-2,y-2) and check if input co-ordinate is bounded between
      (x-2,y-2) and (x,y). if so valid[8] goes high. 
*/
//##########################################################################################
always @(posedge clk) begin
  if(!rstn) begin
    valid_sq_reg[0] <= 0;
    valid_sq_reg[1] <= 0;
    valid_sq_reg[2] <= 0;
    valid_sq_reg[3] <= 0;
    valid_sq_reg[4] <= 0;
    valid_sq_reg[5] <= 0;
    valid_sq_reg[6] <= 0;
    valid_sq_reg[7] <= 0;
    valid_sq_reg[8] <= 0;
    r_data_i <= 0;
  end else if (rstn && (~stall_on)) begin
    if (((row >= LOWER_BOUND) && (col >= LOWER_BOUND)) && (((row2) <= mat_size) && ((col2) <= mat_size))) begin
      valid_sq_reg[0] <= 1;  // 0th bit is assigned 1 if the above condition is satisfied. 
    end else begin 
      valid_sq_reg[0] <= 0;
    end
  
    if(((row >= LOWER_BOUND) && ((col3) >= LOWER_BOUND)) && (((row2) <= mat_size) && ((col1) <= mat_size))) begin
      valid_sq_reg[1] <= 1;  // 1st bit is assigned 1 if the above condition is satisfied. 
    end else begin 
      valid_sq_reg[1] <= 0;
    end  

    if(((row >= LOWER_BOUND) && ((col4) >= LOWER_BOUND)) && (((row2) <= mat_size) && (col <= mat_size))) begin
      valid_sq_reg[2] <= 1;  // 2nd bit is assigned 1 if the above condition is satisfied. 
    end else begin 
      valid_sq_reg[2] <= 0;
    end 

    if((((row3) >= LOWER_BOUND) && (col >= LOWER_BOUND)) && (((row1) <= mat_size) && ((col2) <= mat_size))) begin
      valid_sq_reg[3] <= 1;  // 3rd bit is assigned 1 if the above condition is satisfied. 
    end else begin 
      valid_sq_reg[3] <= 0;
    end

    if((((row3) >= LOWER_BOUND) && ((col3) >= LOWER_BOUND)) && (((row1) <= mat_size) && ((col1) <= mat_size))) begin
      valid_sq_reg[4] <= 1;  // 4th bit is assigned 1 if the above condition is satisfied. 
    end else begin 
      valid_sq_reg[4] <= 0;
    end

    if((((row3) >= LOWER_BOUND) && ((col4) >= LOWER_BOUND)) && (((row1) <= mat_size) && (col <= mat_size))) begin
      valid_sq_reg[5] <= 1;  // 5th bit is assigned 1 if the above condition is satisfied. 
    end else begin 
      valid_sq_reg[5] <= 0;
    end 

    if((((row4) >= LOWER_BOUND) && (col >= LOWER_BOUND)) && ((row <= mat_size) && ((col2) <= mat_size))) begin
      valid_sq_reg[6] <= 1;  // 6th bit is assigned 1 if the above condition is satisfied. 
    end else begin 
      valid_sq_reg[6] <= 0;
    end

    if((((row4) >= LOWER_BOUND) && ((col3) >= LOWER_BOUND)) && (((row) <= mat_size) && ((col1) <= mat_size))) begin
      valid_sq_reg[7] <= 1;  // 7th bit is assigned 1 if the above condition is satisfied. 
    end else begin 
      valid_sq_reg[7] <= 0;
    end   

    if((((row4) >= LOWER_BOUND) && ((col4) >= LOWER_BOUND)) && ((row  <= mat_size) && (col <= mat_size))) begin
      valid_sq_reg[8] <= 1;  // 8th bit is assigned 1 if the above condition is satisfied. 
    end else begin 
      valid_sq_reg[8] <= 0;
    end 
    r_data_i <= valid_sq_data_i;
  //  r2_data_i <= r_data_i;
    end
	else begin 
		valid_sq_reg<=0;
	end
 end
    assign o_valid = i_valid;
    assign valid_sq = valid_sq_reg; 
    assign valid_sq_data_o = r_data_i;
endmodule



