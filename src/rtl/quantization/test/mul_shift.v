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
  parameter OUT_DATA_WIDTH = 8,
  parameter SHIFT_WIDTH = 8  
)(
  input                                 clk,
  input [DATA_WIDTH-1:0]                dina,
  input [DATA_WIDTH-1:0]                dinb,
  output [OUT_DATA_WIDTH-1:0]           dout, 
  input                                 data_valid,
  output                                o_data_valid,
  input [SHIFT_WIDTH-1:0]               bit_shift
);
  wire [DATA_WIDTH*2-1:0]             w_dout;
  reg [DATA_WIDTH*2-1:0]              rdout=0;
  reg                                   r_data_valid=0;
  reg [DATA_WIDTH-1:0]                  r_dina;
/*  always @(posedge clk) begin
    r_dina <= dina;
  end */
  always @(posedge clk) begin
    if (data_valid) begin
      rdout <= dina * dinb;
      r_data_valid <= data_valid;
    end else
      r_data_valid <= 0; 
  end
  
  assign w_dout = rdout >> bit_shift;
  assign dout = w_dout[OUT_DATA_WIDTH-1:0];
  assign o_data_valid = r_data_valid;
  
endmodule


/*
module top_mul_shift#(
    parameter                        DATA_WIDTH = 18,
    parameter                        SHIFT_WIDTH = 8,
    parameter                        N = 8
)(

    input                               top_clk,
    input  [N*DATA_WIDTH-1:0]           top_dina,
    input  [N*DATA_WIDTH-1:0]           top_dinb,
    input  [N-1:0]                      top_data_valid,
    output [N*DATA_WIDTH*2-1:0]           top_dout,
    output [N-1:0]                      top_o_data_valid,
    input  [N*SHIFT_WIDTH-1:0]           top_bit_shift
    

);
generate 
    genvar i;
    for (i = 0; i < N ; i = i + 1) begin: MUL_SHIFT_INST
        mul_shift #(
        .DATA_WIDTH(DATA_WIDTH),
        .SHIFT_WIDTH      (SHIFT_WIDTH)	
)
         mul_shift (
        .clk     (top_clk),
        .dina  (top_dina[i*DATA_WIDTH+:DATA_WIDTH]),
        .dinb (top_dinb[i*DATA_WIDTH+:DATA_WIDTH]),
        .dout  (top_dout[i*DATA_WIDTH*2+:DATA_WIDTH*2]),
        .data_valid (top_data_valid[i]),
        .o_data_valid (top_o_data_valid[i]),
        .bit_shift  (top_bit_shift[i*SHIFT_WIDTH+:SHIFT_WIDTH])
);
    end
endgenerate
endmodule

*/


