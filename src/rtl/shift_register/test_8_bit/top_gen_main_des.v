module top_gen_main_des #(parameter no_of_designs = 4, parameter no_of_blocks = 4) (
    input [(no_of_designs * 32)-1 : 0] intermediate_result,
    input [(no_of_designs * 8)-1 : 0] quantized_result_in,
    input sel,
    input [(no_of_designs)-1 : 0] valid_intermediate_result,
    input [(no_of_designs)-1 : 0] valid_quantized_result,
    input clk,
    output [(no_of_designs)-1 : 0] valid_out_final,
    output [(no_of_designs * (no_of_blocks * 8)) - 1 : 0] data_out
);

genvar i;

generate 
    for(i = 0; i < no_of_designs; i = i + 1) begin
        top_gen top_gen(
            .intermediate_result(intermediate_result[(((no_of_designs-i)*32)-1) -: 32]),
            .quantized_result_in(quantized_result_in[(((no_of_designs-i)*8)-1) -: 8]),
            .sel(sel),
            .valid_intermediate_result(valid_intermediate_result[i]),
            .valid_quantized_result(valid_quantized_result[i]),
            .clk(clk),
            .valid_out_final(valid_out_final[i]),
            .data_out(data_out[(((no_of_designs-i)*32)-1) -: 32])
        );
    end
endgenerate

endmodule