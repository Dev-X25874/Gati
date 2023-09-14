`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Tesetbench for the ReLU6  
// Module Name: relu_6
// Project Name: CNN Acceleration. 
// Description: ReLU6: ReLU6 is a variant of the ReLU activation function that clips the output at 6. 
//                     In other words, if the output is greater than 6, it is set to 6. 
//                     This can help constraint the output range and prevent large activations that might cause numerical
//                     instability.



module tb_relu_6();
  reg [31:0] i_data;
  reg        clk;
  wire [7:0] o_data;
  integer    i;
relu_6 dut(
  .clk      (clk),
  .i_data   (i_data),
  .o_data   (o_data)
);
  initial begin
    clk    = 0;
    i_data = 32'd0;
  end
  
    always #5 clk = ~clk;
  
      initial begin
        for(i=0; i<65535; i=i+1)
          #10 i_data = i * 1;
      end
endmodule











