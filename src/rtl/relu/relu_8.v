`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Implementation of ReLU  
// Module Name: relu_8
// Project Name: CNN Acceleration. 
// Description: ReLU8: ReLU8 is a further variant that clips the output at 8 instead of 6. 
//              It operates similarly to ReLU6 but with a different clipping threshold.
// Revision1: Oct 20, 2023 - Added feature is the data_valid signal.

module relu_8(
 // input signed [31:0]   i_data, // Input to the Relu from previous layer which is a unsigned number
  input [31:0]  i_data,
  input         clk,
  output [8:0]  o_data, //Output of the Relu
  input         data_valid
);
  reg [7:0]     r_data_out = 8'd0;  //Internal reg to latch the output
  reg           r_data_valid = 0;  

  always @(posedge clk) begin
    if (data_valid) begin
      if ((i_data >= 0) && (i_data <= 8)) begin
        r_data_out <= i_data;
        r_data_valid <= data_valid;
      end else if ( i_data > 8) begin
        r_data_out <= 8'd8;
        r_data_valid <= data_valid;
      end 
    end else begin
      r_data_out <= 0;
      r_data_valid <= 0;
  end
  end 
   assign o_data = {r_data_valid,r_data_out};   
endmodule
