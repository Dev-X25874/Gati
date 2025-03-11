module top_gen_shift_register #(parameter NUM_SHIFT = 4,
                                parameter ACC_DATA_WIDTH = 32, 
                                parameter QUANT_DATA_WIDTH = 8,
                                parameter DATA_WIDTH = 8) (
    input [QUANT_DATA_WIDTH - 1 : 0] quantized_result_in,
    input valid_quantized_result,
    input clk,
    output valid_out_final,
    output [(NUM_SHIFT * DATA_WIDTH) - 1 : 0] data_out
);
genvar i;

wire [NUM_SHIFT - 1 : 0] valid_out;
assign valid_out_final = &(valid_out);

generate
    for(i = 0; i < NUM_SHIFT; i = i + 1) begin  :NUMBER
        if(i == 0) begin
            top_shift_register #(.DATA_WIDTH(DATA_WIDTH), .NUM_SHIFT(NUM_SHIFT)) 
            top_shift_register(
                .quantized_result(quantized_result_in),
                .valid_quantized_result(valid_quantized_result),
                .clk(clk),
                .valid_out(valid_out[0]),
                .data_out(data_out[DATA_WIDTH - 1 : 0])
            );
        end
        else
    begin
        top_shift_register #(.DATA_WIDTH(DATA_WIDTH), .NUM_SHIFT(NUM_SHIFT)) 
        top_shift_register(
            .quantized_result(data_out[i*DATA_WIDTH-1 -: DATA_WIDTH]),
            .valid_quantized_result(valid_quantized_result),
            .clk(clk),
            .valid_out(valid_out[i]),
            .data_out(data_out[(1+i)*DATA_WIDTH -1 -: DATA_WIDTH])
        );
        end
    end
endgenerate

endmodule


module top_shift_register  #(parameter DATA_WIDTH = 8,
                            parameter NUM_SHIFT = 4) 
(
    input [DATA_WIDTH - 1 : 0] quantized_result,
    input valid_quantized_result,
    input clk,
    output valid_out,
    output [DATA_WIDTH - 1 : 0] data_out
);

wire [7:0] din;

register #(.DATA_WIDTH(DATA_WIDTH), 
            .NUM_SHIFT(NUM_SHIFT)) 
register(
    .din(quantized_result),
    .valid_quantized_result(valid_quantized_result),
    .dout(data_out),
    .valid_out(valid_out),
    .clk(clk)
);

endmodule
