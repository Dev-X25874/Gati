`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Multiplier  
// Module Name: multiplier_18_des2
// Project Name: CNN Acceleration- GATI
// Description: It is a multiplier which multiplies two numbers. 
// Revision 1:  Sept 29, 2023 - Added feature: The valid data input was added 
//////////////////////////////////////////////////////////////////////////////////


module mul_shift#(
  parameter DATA_WIDTH = 18,
  parameter SCALE_WIDTH = 16,
  parameter OUT_DATA_WIDTH = 8,
  parameter SHIFT_WIDTH = 8  
)(
  input                                 clk,
  input signed [DATA_WIDTH-1:0]         dina, //input data from bias block
  input signed [SCALE_WIDTH-1:0]        dinb, //scale value from inst.
  input                                 enabled,
  input                                 fp_cast, //if enabled, it will cast the floating point value
  input [SHIFT_WIDTH-1:0]               fp_cast_shift, //shift value for floating point casting
  output reg [DATA_WIDTH-1:0]           quantized_passthrough,
  output reg                            unquantized_valid,
  output signed [OUT_DATA_WIDTH-1:0]    dout, 
  input                                 data_valid,
  output reg                            o_data_valid,
  input [SHIFT_WIDTH-1:0]               bit_shift
);
  reg  signed [DATA_WIDTH*2-1:0]        w_dout;
  reg  signed [DATA_WIDTH*2-1:0]        w_dout1;
  reg  signed [DATA_WIDTH*2-1:0]        w_dout2;
  reg  signed [DATA_WIDTH*2-1:0]        rdout=0;
  reg                                   r_data_valid=0;
  reg                                   r_data_valid1=0;
  reg                                   r_data_valid2=0;
  reg [DATA_WIDTH-1:0]                  r_dina;

  /* quantization is performed in two steps: 
    1: multpily the i/p data by the scale value that comes from the instruction
    2: shift the multiplier output by another scale value which is also present as a part of inst.
      If qunatizer is not enabled in a partcular iteration, it passes the input data 
      to the output without any processing.
  */ 
  always @(posedge clk) begin
    if (data_valid & enabled) begin //if quantizer enabled, quantize the i/p else pass to o/p
      rdout <= dina * dinb;
      r_data_valid <= data_valid;
      unquantized_valid <= 0;
    end 
    else if (data_valid & ~enabled) begin
      quantized_passthrough <= dina;
      unquantized_valid     <= data_valid;
      r_data_valid          <= 0;      
    end

    else begin
      r_data_valid <= 0; 
      unquantized_valid <= 0;
    end
  end
  
  // assign w_dout = (enabled==1)? ((rdout+(1<<(bit_shift-1))) >>> bit_shift) : 0;
  
  always @(posedge clk) begin
    w_dout <= (enabled==1)? ((rdout+(1<<(bit_shift-1))) >>> bit_shift) : 0;
    r_data_valid1 <= r_data_valid;
  end

  // TODO : mention the reason for FP Casting here.
  // Additional logic for floating point casting
  always @(posedge clk) begin
    r_data_valid2 <= r_data_valid1;
    w_dout1 <= fp_cast? (w_dout + (1<<(fp_cast_shift-1))) >>> fp_cast_shift : w_dout;
  end

  always @(posedge clk) begin    
    w_dout2 <= (w_dout1 < -128) ? -128 : ((w_dout1 > 127) ? 127 : w_dout1);
    o_data_valid <= r_data_valid2;  
  end
  assign dout = w_dout2[OUT_DATA_WIDTH-1:0];
  // assign w_dout = (enabled==1)? ((rdout+((1<<bit_shift)>>(1))) >> bit_shift) : 0;
  // assign w_dout2 = (w_dout < -128) ? -128 : ((w_dout > 127) ? 127 : w_dout);  
endmodule


