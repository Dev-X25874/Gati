module controller_gen #(parameter no_of_designs = 4) (
    input clk,
    input [7:0] din,
    input valid_intermediate_result,
    output [(no_of_designs * 32) - 1 : 0] intermediate_result,
    output [(no_of_designs * 8) - 1 : 0] quantized_result,
    output [(no_of_designs - 1) : 0] valid_out,
    output [(no_of_designs - 1) : 0] sel 
);

genvar i;

generate 
    for(i = 0; i < no_of_designs; i = i + 1) begin
        controller controller(
            .clk(clk),
            .din(din),
            .valid_intermediate_result(valid_intermediate_result),
            .intermediate_result(intermediate_result[(((no_of_designs-i)*32)-1) -: 32]),
            .quantized_result(quantized_result[(((no_of_designs-i)*8)-1) -: 8]),
            .valid_out(valid_out[i]),
            .sel(sel[i])
        );
    end
endgenerate

endmodule