`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Implementation of ReLU  
// Module Name: relu_8
// Project Name: CNN Acceleration. 
// Description: ReLU8: ReLU8 is a further variant that clips the output at 8 instead of 6. 
//              It operates similarly to ReLU6 but with a different clipping threshold.


module relu_8(
  input[31:0]   i_data, // Input to the Relu from previous layer which is a unsigned number
  input         clk,
  output[7:0]   o_data //Output of the Relu
);
  reg[7:0]      out_reg = 8'd0;  //Internal reg to latch the output
    
always @(posedge clk) begin
  if (i_data[31:30] == 1)
    out_reg <= 0;
  else if ((i_data > 0) && (i_data <= 8))
    out_reg <= i_data;
  else if ( i_data > 8)
    out_reg <= 8'h08;
end
   assign o_data = out_reg;
    
endmodule


