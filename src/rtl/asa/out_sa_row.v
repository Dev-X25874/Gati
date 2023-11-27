//Appends data valid signal with data output coming from row array
module out_sa_row#(
    parameter ROW = 8,
    parameter W_DATA = 8
)(
    input [(ROW * W_DATA)-1:0] i_data,
    input [ROW-1:0] i_data_valid,
    output [((W_DATA + 1) * ROW)-1 :0] o_data
);

genvar i;
generate
    for (i = 0; i < ROW; i = i + 1)begin : ROW_DV_APPEND_GEN
        o_row_append_dv#(
            .W_DATA(W_DATA)
        ) dv_append (
        .i_data (i_data[((W_DATA * (ROW - i))-1) -: W_DATA]),
        .i_data_valid (i_data_valid[i]),
        .o_data (o_data[(((W_DATA + 1) * (ROW - i))-1) -: (W_DATA + 1)])
        );
    end
endgenerate

endmodule
