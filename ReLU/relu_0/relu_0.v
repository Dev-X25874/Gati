`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Implementation of ReLU  
// Module Name: relu_0
// Project Name: CNN Acceleration. 
// Description: The below ReLU block replaces all negative values received as inputs by zeros.


module relu_0(
  input [31:0]   i_data, // Input to the Relu from previous layer
  input          clk,
  output [31:0]  o_data //Output of the Relu  
);
    
  reg[31:0] out_reg;  //Internal reg to latch the output 
    
always @(posedge clk) begin
  if (i_data[31:30] == 1) begin
    out_reg <= 0;
  end else begin
    out_reg <= i_data;
  end
end    
    assign o_data = out_reg;
    
    
    
    
endmodule
