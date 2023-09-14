`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Tesetbench for the ReLU8  
// Module Name: relu_8
// Project Name: CNN Acceleration. 
// Description: ReLU8: ReLU8 is a further variant that clips the output at 8 instead of 6. 
//              It operates similarly to ReLU6 but with a different clipping threshold.


module tb_relu_8();
  reg [31:0] i_data;
  reg        clk;
  wire [7:0] o_data;
  integer    i;
relu_8 dut(
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
