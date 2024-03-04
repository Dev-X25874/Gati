/*
    Systolic array block along with the registers to provide delay 
    while sending data into rows of systolic array
*/
module booth_systolic_array #(
    parameter ROW = 9, 
    parameter COL = 3, 
    parameter TOTAL_BYTES = ROW * COL,
    parameter W_DATA = 8,
    parameter W_PSUM = 19
)(  input in_clk, 
    // input in_sel,   
    input [(COL * (W_DATA + 1)) - 1:0] in_north,  //8 bit weights 
    input [(ROW * (W_DATA + 1)) - 1:0] in_west,    //8 bit data 
    output [(ROW * (W_DATA + 1)) - 1:0] out_east,  //19 bit output from last row
    output [(COL * (W_PSUM + 1)) - 1:0] out_south,    //8 bit data output from the last column
    output last_row_i_data_valid    //shows the validity of input 8 bit data which is going into the last row of systolic array
);

wire [(ROW * (W_DATA + 1)) - 1 : 0] data_to_be_passed;  //9 bits data output from registers (used for providing delay) going into rows of systolic array 

assign last_row_i_data_valid = in_west[8];

booth_sa#(
    .N_COLS(COL),
    .N_ROWS(ROW),
    .W_DATA(W_DATA),
    .W_PSUM(W_PSUM)
) sa_grid (
    .i_clk(in_clk),
    // .i_sel(in_sel),
    .i_weights(in_north),
    .i_data(in_west),
    .o_partial_sums(out_south),
    .o_data(out_east)
);

endmodule
