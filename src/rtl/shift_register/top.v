module top_gen #(parameter no_of_blocks = 4) (
    input [31:0] intermediate_result,
    input [7:0] quantized_result_in,
    input sel,
    input valid_intermediate_result,
    input clk,
    output valid_out_final,
    output [(no_of_blocks * 8) - 1 : 0] data_out
);
genvar i;

wire [3:0] valid_out;
assign valid_out_final = &(valid_out);

generate
    for(i = 0; i < no_of_blocks; i = i + 1) begin
        if(i == 0) begin
            top top(
                .intermediate_result(intermediate_result[7:0]),
                .quantized_result(quantized_result_in),
                .sel(sel),
                .valid(valid_intermediate_result),
                .clk(clk),
                .valid_out(valid_out[0]),
                .data_out(data_out[31:24])
            );
        end
        else begin
        top top(
            .intermediate_result(intermediate_result[(((no_of_blocks-i)*8)-1) -: 8]),
            .quantized_result(data_out[((no_of_blocks-(i-1))*8)-1 -: 8]),
            .sel(sel),
            .valid(valid_intermediate_result),
            .clk(clk),
            .valid_out(valid_out[i]),
            .data_out(data_out[(((no_of_blocks-i)*8)-1) -: 8])
        );
        end
    end
endgenerate

endmodule


module top(
    input [7:0] intermediate_result,
    input [7:0] quantized_result,
    input sel,
    input valid,
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
    .valid(valid),
    .dout(data_out),
    .valid_out(valid_out),
    .clk(clk),
    .sel(sel)
);

endmodule
