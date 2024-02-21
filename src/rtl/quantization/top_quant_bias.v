module top_quant_bias #(parameter DATA_WIDTH = 18,
                        parameter OUT_DATA_WIDTH = 8,
                        parameter SHIFT_WIDTH = 8)(
    input                                 i_clk,
    input [DATA_WIDTH-1:0]                i_data,
    input [DATA_WIDTH-1:0]                i_data_scale,
    output [OUT_DATA_WIDTH-1:0]           o_data, 
    input                                 i_data_valid,
    output                                o_data_valid,
    input [SHIFT_WIDTH-1:0]               i_bit_shift,
    input[DATA_WIDTH-1:0]                 i_data_bias
);
    wire [DATA_WIDTH-1:0]                 w_data_bias_quant;
    wire                                  w_valid_bias_quant;

    
    
    bias #(.DATA_WIDTH(DATA_WIDTH))
    bias_mod(
    .i_data        (i_data),
    .i_data_bias   (i_data_bias),
    .i_valid       (i_data_valid),
    .clk           (i_clk),
    .o_data        (w_data_bias_quant),
    .o_valid       (w_valid_bias_quant)
    );
    
    
    mul_shift #(.DATA_WIDTH(DATA_WIDTH),
                .OUT_DATA_WIDTH(OUT_DATA_WIDTH),
                .SHIFT_WIDTH(SHIFT_WIDTH))
    mul_shift_mod(
    .clk          (i_clk),
    .dina         (w_data_bias_quant),
    .dinb         (i_data_scale),
    .dout         (o_data), 
    .data_valid   (w_valid_bias_quant),
    .o_data_valid (o_data_valid),
    .bit_shift    (i_bit_shift)
    
    );
    

endmodule 




module top_quant_bias_gen #(parameter DATA_WIDTH = 32,
                            parameter SHIFT_WIDTH = 8,
                            parameter OUT_DATA_WIDTH = 8,
                            parameter N = 8
)(
    input                                   top_i_clk,
    input [N*DATA_WIDTH-1:0]                top_i_data_quant,
    input [N*DATA_WIDTH-1:0]                top_i_data_scale,
    output [(N*OUT_DATA_WIDTH)-1:0]         top_o_data, 
    input [N-1:0]                           top_i_data_valid,
    output [N-1:0]                          top_o_data_valid,
    input [N*SHIFT_WIDTH-1:0]               top_i_bit_shift,
    input[(N*DATA_WIDTH)-1:0]               top_i_data_bias
    

);



generate 
genvar i;
    for (i = 0; i < N; i = i +1) begin : QUANT_BIAS_INST
    top_quant_bias #(.DATA_WIDTH(DATA_WIDTH),
                     .OUT_DATA_WIDTH(OUT_DATA_WIDTH),
                     .SHIFT_WIDTH(SHIFT_WIDTH))
    top_quant_bias_mod(
    .i_clk                        (top_i_clk),
    .i_data                       (top_i_data_quant[i*DATA_WIDTH +: DATA_WIDTH]),
    .i_data_scale                 (top_i_data_scale[i*DATA_WIDTH +: DATA_WIDTH]),
    .o_data                       (top_o_data[i*OUT_DATA_WIDTH +: OUT_DATA_WIDTH]), 
    .i_data_valid                 (top_i_data_valid[i]),
    .o_data_valid                 (top_o_data_valid[i]),
    .i_bit_shift                  (top_i_bit_shift[i*SHIFT_WIDTH +: SHIFT_WIDTH]),
    .i_data_bias                  (top_i_data_bias[i*DATA_WIDTH +: DATA_WIDTH])
    );
end
endgenerate 
endmodule