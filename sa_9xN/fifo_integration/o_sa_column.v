module o_sa_column#(
    parameter COL = 3,
    parameter W_DATA = 8
)(
    input i_clk,
    input [(W_DATA * COL)-1:0] i_data,
    input [COL-1:0] i_data_valid,
    output [(9 * COL)-1:0] o_data
);

genvar i;
generate
    for (i = 0; i < COL; i = i +1) begin : O_SA_COL
        col_dv_append#(
            .W_DATA(W_DATA)
        ) fifo_for_column (
            .i_clk(i_clk),
            .i_data (i_data[((W_DATA * (COL -i))-1) -: 8]),
            .i_data_valid (i_data_valid[i]),
            .o_data (o_data[((9 * (COL-i))-1) -: 9])
        );
    end
endgenerate

endmodule
