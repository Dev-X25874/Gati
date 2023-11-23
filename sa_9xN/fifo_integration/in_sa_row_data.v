module in_sa_row_data#(
    parameter ROW = 8,
    parameter W_DATA = 8
)(  input [(W_DATA * ROW) -1 :0] i_data,
    input [ROW-1 : 0] i_data_valid,
    output [(9 * ROW)-1:0] o_data
    );

genvar i;
generate
    for(i = 0; i < ROW; i = i +1) begin : DV_APPEND_GEN
        data_valid_append#(
            .W_DATA(W_DATA)
        ) row_fifo (
            .i_data (i_data[((W_DATA * (ROW -i)) -1) -: 8]),
            .i_data_valid(i_data_valid[i]),
            .o_data (o_data[((9 * (ROW - i)) -1) -: 9])
        );
    end
endgenerate

endmodule
