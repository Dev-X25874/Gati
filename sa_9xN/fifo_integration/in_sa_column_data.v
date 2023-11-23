module in_sa_column_data#(
    parameter COL = 3,
    parameter W_DATA = 8
)(  input [(COL * W_DATA) -1 : 0] i_data,
    input [COL-1:0] i_dv,
    output [(COL * 32) -1 : 0] o_data,
    output [COL-1:0] o_dv
);
assign o_dv = i_dv;
genvar i;
generate
    for(i = 0; i < COL; i = i + 1)begin : APPEND_BITS_GEN
        append_bits#(
            .W_DATA(W_DATA)
        ) col_data_32 (
            .i_data (i_data[((W_DATA * (COL - i)) -1) -: 8]),
            .o_data (o_data[((32 * (COL - i)) -1) -: 32])
        );
    end
endgenerate

endmodule

module append_bits#(
    parameter W_DATA = 8
)(
    input [W_DATA -1 : 0] i_data,
    output [31 :0] o_data
);

assign o_data = {24'd0, i_data};

endmodule