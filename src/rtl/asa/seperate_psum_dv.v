/*
    Each PE grid column generates 20 bits of output. 
    The partial sum consists of 19 bits, with data valid signal as its MSB.
    To ensure only correct outputs are stored in the FIFO, 
    the data valid signal is separated from the 20-bit data and transmitted as
    a write enable signal to the subsequent partial sum fifo array.
*/
module seperate_psum_dv#(
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
        assign  out_data_valid[i] = in_data[((W_PSUM + 1) * (COL-i))-1];

        assign  out_data[((W_PSUM  * (COL - i))-1) -: W_PSUM] = 
                in_data[(((W_PSUM + 1) * (COL - i))-1) -: (W_PSUM + 1)];
    end
endgenerate

endmodule