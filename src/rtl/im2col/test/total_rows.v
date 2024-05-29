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


module total_rows #(parameter DATA_WIDTH = 8,
                    parameter MAX_VALID_SQ = 9)(
    input                           clk,
    input                           rstn,
    input [MAX_VALID_SQ-1:0]        valid_sq_i,
    input [DATA_WIDTH-1:0]          valid_row_data_i,
    output [DATA_WIDTH-1:0]         valid_row_data_o,
    output [MAX_VALID_SQ-1:0]       valid_sq_o,
    output [4:0]                    row1,  
    output [4:0]                    row2,  
    output [4:0]                    row3,  
    output [4:0]                    row4,  
    output [4:0]                    row5,  
    output [4:0]                    row6,  
    output [4:0]                    row7,  
    output [4:0]                    row8,  
    output [4:0]                    row9,
    input                           i_valid_data,
    output                          o_valid_data  
);

    reg [4:0]         r_row1 = 0;
    reg [4:0]         r_row2 = 0;
    reg [4:0]         r_row3 = 0;
    reg [4:0]         r_row4 = 0;
    reg [4:0]         r_row5 = 0;
    reg [4:0]         r_row6 = 0;
    reg [4:0]         r_row7 = 0;
    reg [4:0]         r_row8 = 0;
    reg [4:0]         r_row9 = 0; 

always @(posedge clk) begin
  if(!rstn) begin
    r_row1 <= 0;
    r_row2 <= 0;
    r_row3 <= 0;
    r_row4 <= 0;
    r_row5 <= 0;
    r_row6 <= 0;
    r_row7 <= 0;
    r_row8 <= 0;
    r_row9 <= 0;
  end else begin
    r_row1 <= 1;  
    r_row2 <= 2;
    r_row3 <= 3;
    r_row4 <= 4;
    r_row5 <= 5;
    r_row6 <= 6;
    r_row7 <= 7;
    r_row8 <= 8;
    r_row9 <= 9;
  end
end

assign valid_row_data_o = valid_row_data_i;
assign o_valid_data = i_valid_data;
assign valid_sq_o = valid_sq_i;
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
