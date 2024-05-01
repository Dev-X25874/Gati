module top_gen_shift_register #(parameter no_of_blocks = 4) (
    input [31:0] intermediate_result,
    input [7:0] quantized_result_in,
    input sel,
    input valid_intermediate_result,
    input valid_quantized_result,
    input clk,
    output valid_out_final,
    output [(no_of_blocks * 8) - 1 : 0] data_out
);
genvar i;

wire [3:0] valid_out;
assign valid_out_final = &(valid_out);

generate
    for(i = 0; i < no_of_blocks; i = i + 1) begin  :NUMBER
        if(i == 0) begin
            top_shift_register top_shift_register(
                .intermediate_result(intermediate_result[7:0]),
                .quantized_result(quantized_result_in),
                .sel(sel),
                .valid_intermediate_result(valid_intermediate_result),
                .valid_quantized_result(valid_quantized_result),
                .clk(clk),
                .valid_out(valid_out[0]),
                .data_out(data_out[7:0])
            );
        end
        else
    begin
        top_shift_register top_shift_register(
            .intermediate_result(intermediate_result[(i+1)*8 -1-:8]),
            .quantized_result(data_out[i*8-1 -: 8]),
            .sel(sel),
            .valid_intermediate_result(valid_intermediate_result),
            .valid_quantized_result(valid_quantized_result),
            .clk(clk),
            .valid_out(valid_out[i]),
            .data_out(data_out[(1+i)*8 -1 -: 8])
        );
        end
    end
endgenerate

endmodule


module top_shift_register(
    input [7:0] intermediate_result,
    input [7:0] quantized_result,
    input sel,
    input valid_intermediate_result,
    input valid_quantized_result,
    input clk,
    output valid_out,
    output [7:0] data_out
);

wire [7:0] din;

mux mux(
    .intermediate_result(intermediate_result),
    .quantized_result(quantized_result),
    .sel(sel),
    .dout(din)
);

register register(
    .din(din),
    .valid_intermediate_result(valid_intermediate_result),
    .valid_quantized_result(valid_quantized_result),
    .dout(data_out),
    .valid_out(valid_out),
    .clk(clk),
    .sel(sel)
);

endmodule
