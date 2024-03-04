/*
    Appends data valid bit with the data before sending it 
    into rows or columns of systolic array.
*/
module append_dv#(
    parameter N_DIMENSION = 8,  //number of rows or columns
    parameter W_DATA = 8
)(  input [(W_DATA * N_DIMENSION) -1 :0] i_data,
    input [N_DIMENSION-1 : 0] i_data_valid,
    output [((W_DATA + 1) * N_DIMENSION)-1:0] o_data
);

genvar i;
generate
    for(i = 0; i < N_DIMENSION; i = i +1) begin : DV_APPEND_GEN
        data_valid_append#(
            .W_DATA(W_DATA)
        ) row_fifo (
            .i_data (i_data[((W_DATA * (N_DIMENSION -i )) -1) -: W_DATA]),
            .i_data_valid(i_data_valid[i]),
            .o_data (o_data[(((W_DATA + 1) * (N_DIMENSION - i)) -1) -: (W_DATA + 1)])
        );
    end
endgenerate

endmodule