module rem_dv_array#(
    parameter COL = 4,
    parameter W_PSUM = 19
)(
    input [(COL * (W_PSUM + 1))-1 : 0] in_data,
    output [(COL * W_PSUM)-1 : 0] out_data,
    output [COL-1 : 0] out_data_valid
);

genvar i;
generate
    for(i=0; i<COL; i = i +1)begin : W_PSUM_DV
        wire w_dv;
        assign out_data_valid[i] = in_data[((W_PSUM + 1) * (COL-i))-1];
        rem_psum_dv#(
            .W_PSUM(W_PSUM)
        ) inst1 (
            .i_data(in_data[(((W_PSUM + 1) * (COL - i))-1) -: (W_PSUM + 1)]),
            .o_data(out_data[((W_PSUM  * (COL - i))-1) -: W_PSUM])
        );
    end
endgenerate

endmodule

//separates partial sum from its data valid
module rem_psum_dv#(
    parameter W_PSUM = 19
)(
    input [W_PSUM : 0]i_data,
    output [W_PSUM-1 : 0] o_data
);
   
assign o_data = i_data[W_PSUM-1 : 0];
    
endmodule