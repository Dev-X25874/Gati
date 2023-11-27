//Appends data valid signal along with partial sums stores in fifo to check validity of data
module o_sa_column#(
    parameter COL = 3,
    parameter W_DATA = 8
)(
    input i_clk,
    input [(W_DATA * COL)-1:0] i_data,
    input [COL-1:0] i_data_valid,
    output [((W_DATA + 1) * COL)-1:0] o_data
);

genvar i;
generate
    for (i = 0; i < COL; i = i +1) begin : O_SA_COL
        col_dv_append#(
            .W_DATA(W_DATA)
        ) fifo_for_column (
            .i_clk(i_clk),
            .i_data (i_data[((W_DATA * (COL -i))-1) -: W_DATA]),
            .i_data_valid (i_data_valid[i]),
            .o_data (o_data[(((W_DATA + 1) * (COL-i))-1) -: (W_DATA + 1)])
        );
    end
endgenerate

endmodule
