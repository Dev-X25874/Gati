/*
    Appends data valid bit alonmg with the data before sending it 
    into rows of systolic array.
*/
module in_sa_row_data#(
    parameter ROW = 8,
    parameter W_DATA = 8
)(  input [(W_DATA * ROW) -1 :0] i_data,
    input [ROW-1 : 0] i_data_valid,
    output [((W_DATA + 1) * ROW)-1:0] o_data
    );

genvar i;
generate
    for(i = 0; i < ROW; i = i +1) begin : DV_APPEND_GEN
        data_valid_append#(
            .W_DATA(W_DATA)
        ) row_fifo (
            .i_data (i_data[((W_DATA * (ROW -i )) -1) -: W_DATA]),
            .i_data_valid(i_data_valid[i]),
            .o_data (o_data[(((W_DATA + 1) * (ROW - i)) -1) -: (W_DATA + 1)])
        );
    end
endgenerate

endmodule
