`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Implementation of ReLU  
// Module Name: relu_0
// Project Name: CNN Acceleration. 
// Description: The below ReLU block replaces all negative values received as inputs by zeros.
// Revision1: Sept 29, 2023 - Added feature is the data_valid signal.


module relu_0(
  //input signed [31:0]   i_data, // Input to the Relu from previous layer
  input [31:0]   i_data,
  input                 clk,
  input                 data_valid,
  output [32:0]         o_data //Output of the Relu  
);
  reg       r_data_valid;
  reg[31:0] out_reg;  //Internal reg to latch the output   
always @(posedge clk) begin
  if (data_valid == 1) begin
    if (i_data[31] == 1) begin
      out_reg <= 0;
      r_data_valid <= data_valid;
    end else begin
      out_reg <= i_data;
      r_data_valid <= data_valid; 
    end 
    end else begin
    out_reg <= 0;
    r_data_valid <= 0;
  end
end 
    assign o_data = {r_data_valid,out_reg};  
endmodule
