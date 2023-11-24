`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Implementation of ReLU  
// Module Name: relu
// Project Name: CNN Acceleration. 
// Description: This is a generic relu module incorporating the functionality
//              of all relu variants.
//             - If the clipping constant is 8, it clips the output at 8.
//             - If the clipping constant is 6, it clips the output at 6.
//             - If the clipping constant is 0 or any other number, it sends the 
//               incoming input as an output.
/////////////////////////////////////////////////////////////////////////////////
`define CHECK_FREQ 1

module relu 
#(
  parameter           WIDTH = 32,
  parameter           CLIPPING_CONSTANT = 16, // can be 6/8/0 based on the req
//  parameter           OPWIDTH = (CLIPPING_CONSTANT == 0) ? WIDTH-1: (CLIPPING_CONSTANT == 1) ? 0 : $clog2(CLIPPING_CONSTANT+1)-1
)
(
  input [WIDTH-1:0]                i_data_w,
  input                            clk,
//  output [$clog2(CLIPPING_CONSTANT):0]         o_data,
  output [WIDTH-1:0]               o_data,
//  output [ (CLIPPING_CONSTANT == 0) ? [31:0] : (CLIPPING_CONSTANT == 1) ? [0:0] : [$clog2(CLIPPING_CONSTANT+1)-1:0]]  o_data;
  input                            data_valid_w 
);


 
  
  reg [WIDTH-1:0]                       r_data_out = 0;  
  reg                                   r_data_valid = 0;
  
  reg [WIDTH-1:0]                       i_data = 0;
  reg                                   data_valid = 0;
 
`undef CHECK_FREQ 
 `ifdef CHECK_FREQ
  always @(posedge clk) begin
    i_data <= i_data_w;
    data_valid <= data_valid_w;    
  end
  `endif

  always @(posedge clk) begin
    if (CLIPPING_CONSTANT != 0) begin
      if (data_valid) begin
        if ((i_data >= 0) && (i_data <= CLIPPING_CONSTANT)) begin
          r_data_out <= i_data;
          r_data_valid <= data_valid;
        end else if ( i_data > CLIPPING_CONSTANT) begin
          r_data_out <= CLIPPING_CONSTANT;
          r_data_valid <= data_valid;
        end 
      end else begin
        r_data_out <= 0;
        r_data_valid <= 0;
      end 
    end else begin
      if (data_valid) begin
        r_data_out <= i_data;
        r_data_valid <= data_valid;
      end else begin
        r_data_out <= 0;
        r_data_valid <= 0;
      end
    end
  end
   
  assign o_data = {r_data_valid,r_data_out}; 
  
endmodule
