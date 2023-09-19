`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Implementation of ReLU  
// Module Name: relu_6
// Project Name: CNN Acceleration. 
// Description: ReLU6: ReLU6 is a variant of the ReLU activation function that clips the output at 6. 
//                     In other words, if the output is greater than 6, it is set to 6. 
//                     This can help constraint the output range and prevent large activations that might cause numerical
//                     instability. 


module relu_6(
  input[31:0]   i_data, // Input to the Relu from previous layer which is a unsigned number
  input         clk,
  output[7:0]   o_data //Output of the Relu
);
  reg[7:0]      out_reg = 8'd0;  //Internal reg to latch the output
    
always @(posedge clk) begin
  if (i_data[31] == 1)
    out_reg <= 0;
  else if ((i_data > 0) && (i_data <= 6))
    out_reg <= i_data;
  else if ( i_data > 6)
    out_reg <= 8'h06;
end
   assign o_data = out_reg;
    
endmodule



