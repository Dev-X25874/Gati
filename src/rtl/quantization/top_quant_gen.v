// generates multiple instances of mul_shift modules that performs quantization
module top_quant_gen #(
    parameter DATA_WIDTH = 32,
    parameter SCALE_WIDTH = 16,
    parameter SHIFT_WIDTH = 8,
    parameter OUT_DATA_WIDTH = 8,
    parameter N = 8
)(
    input                                   top_i_clk,
    input [N*DATA_WIDTH-1:0]                top_i_data_quant,
    input [N*SCALE_WIDTH-1:0]               top_i_data_scale,
    input                                   enable_quant,
    output [N*DATA_WIDTH-1:0]               quantized_passthrough,
    output [(N*OUT_DATA_WIDTH)-1:0]         top_o_data, 
    input  [N-1:0]                          top_i_data_valid,
    output [N-1:0]                          top_o_data_valid,
    output [N-1:0]                          unquantized_valid,
    input [N*SHIFT_WIDTH-1:0]               top_i_bit_shift   

);



generate 
genvar i;
    for (i = 0; i < N; i = i +1) begin : QUANT_INST
    mul_shift #(.DATA_WIDTH(DATA_WIDTH),
                .OUT_DATA_WIDTH(OUT_DATA_WIDTH),
                .SCALE_WIDTH(SCALE_WIDTH),
                .SHIFT_WIDTH(SHIFT_WIDTH))
    mul_shift_inst(
    .i_clk                        (top_i_clk),
    .dina                         (top_i_data_quant[i*DATA_WIDTH +: DATA_WIDTH]),
    .dinb                         (top_i_data_scale[i*SCALE_WIDTH +: SCALE_WIDTH]),
    .enabled                      (enable_quant),
    .quantized_passthrough        (quantized_passthrough[i*DATA_WIDTH+:DATA_WIDTH]),
    .unquantized_valid            (unquantized_valid[i]),
    .dout                         (top_o_data[i*OUT_DATA_WIDTH +: OUT_DATA_WIDTH]), 
    .data_valid                   (top_i_data_valid[i]),
    .o_data_valid                 (top_o_data_valid[i]),
    .i_bit_shift                  (top_i_bit_shift[i*SHIFT_WIDTH +: SHIFT_WIDTH])
    );
end
endgenerate 
endmodule