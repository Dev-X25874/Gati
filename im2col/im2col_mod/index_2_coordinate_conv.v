`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// Design Name: Im2col
// Module Name: Index to co-ordinate conversion
// Project Name: CNN Acceleration
// Description: The first sub-block of im2col where,
//              -- The input data will be getting its respective coordinate(i.e. rows and column) 
// Revision 1 --> 12-10-2023 -- The code had few bugs like --  
//                           -- The coordinate wasn't starting from (0,0) i.e. (row,column) 
//                           -- The coordinate also wasn't ending at (224,224) i.e. (row,column)
//                           -- The bit size during initialization was made correct
//                           -- The comparison logic was fixed 
// Revision 2 --> 21-11-2023 -- Additional comments were added
//////////////////////////////////////////////////////////////////////////////////


module index_2_coordinate_conv # (parameter WIDTH = 224) (
  input wire         clk,
  output [7:0]       row,
  output [7:0]       col,
  input [7:0]        data_i,
  input              rstn,
  output [7:0]       data_o

);

  reg [7:0]          curr_row=8'd0;
  reg [7:0]          curr_col=8'd0;
  assign row = curr_row;
  assign col = curr_col;
//###########################################################################################  
/* - Start the row and column counter (row,col) with (0,0)
   - Increment the column counter by one till 224th column is reached.
   - If column counter reaches to maximum then reset the column counter and increment row counter by one
   - Repeat the above process till both row and column counters reach maximum (i.e., (row,col)=(224,224))*/
//###########################################################################################   
   always @(posedge clk) begin
     if(!rstn) begin
       curr_col <= 8'd0;
       curr_row <= 8'd0;
     end else if ( curr_row == WIDTH && curr_col == WIDTH ) begin
       curr_row <= 0;
       curr_col <= 0;
     end
     else if (curr_col == WIDTH) begin 
       curr_col <= 0;                  //curr_col is assigned to 0 if the curr_col exceeds the WIDTH
       curr_row <= curr_row + 1;       // meanwhile the curr_row is incremented and goes to the next row
     end else if (curr_col >= 0 && curr_col <= WIDTH) begin
       curr_col <= curr_col + 1;       //curr_col is incremented and goes to the next col
       curr_row <= curr_row;
     end 
     else begin
       curr_row <= 0;
       curr_col <= 0;
     end     
   end
 assign data_o = data_i;
endmodule
