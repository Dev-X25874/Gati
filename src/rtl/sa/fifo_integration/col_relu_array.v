module col_relu_array#(
    parameter COL = 3,
    parameter W_DATA = 8
)(
    input i_clk,
    input [COL-1:0] i_data_valid,
    input [(COL * 32)-1:0] i_data,
    output [(W_DATA * COL)-1:0] o_data,
    output [COL-1:0] o_data_valid
);

genvar i;
generate
    for (i = 0; i < COL; i = i + 1)begin : RELU_GEN
        relu_8 
        relu_inst1(
            .i_data(i_data[((32 * (COL-i)) -1 ) -: 32]),
            .clk (i_clk),
            .i_data_valid(i_data_valid[i]),
            .o_data (o_data[((W_DATA * (COL - i)) -1) -: 8]), //Output of the Relu
            .o_data_valid(o_data_valid[i])
        );
    end
endgenerate

endmodule