//Array of relu blocks used to clip 32 bits of partial sums into 8 bits
module col_relu_array#(
    parameter COL = 3,
    parameter W_DATA = 8,
    parameter PS_WIDTH = 32
)(
    input i_clk,
    input [COL-1:0] i_data_valid,
    input [(COL * PS_WIDTH)-1:0] i_data,
    output [(W_DATA * COL)-1:0] o_data,
    output [COL-1:0] o_data_valid
);

genvar i;
generate
    for (i = 0; i < COL; i = i + 1)begin : RELU_GEN
        relu 
        relu_inst1(
            .i_data(i_data[((PS_WIDTH * (COL-i)) -1 ) -: PS_WIDTH]),
            .clk (i_clk),
            .i_valid(i_data_valid[i]),
            .o_data(o_data[((W_DATA * (COL - i)) -1) -: W_DATA]), //Output of the Relu
            .o_valid(o_data_valid[i])
        );
    end
endgenerate

endmodule
