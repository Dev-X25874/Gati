`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Multiplier and shifter for quantization 
// Module Name: top_mul_shift_des2
// Project Name: CNN Acceleration
// Description: Integer quantization in deep neural networks is a process of reducing model 
//              memory and computation requirements by converting floating-point weights and 
//              activations to integer values. This minimizes storage and accelerates 
//              computations on hardware with limited precision, maintaining network 
//              performance with quantized values for faster inference.
//////////////////////////////////////////////////////////////////////////////////


module top_mul_shift_des2(
  input        i_clk,
  input[17:0]  i_dina,
  input[17:0]  i_dinb,
  output[27:0] o_dout
      );
  wire [35:0] w_dout;
multiplier_18_des2 mul_mod(
  .clk (i_clk),
  .dina(i_dina),
  .dinb(i_dinb),
  .dout(w_dout)
);
    
right_shifter_des2 shifter_mod(
  .clk         (i_clk),
  .din_mul     (w_dout),
  .dout_shifted(o_dout)
);
endmodule
