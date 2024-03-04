/*
    Store weights column-wise into array of fifo, such that, 
    all the column's weights in systolic array gets loaded 
    simultaneously from this array of fifo.
*/
module fifo_north#(
    parameter COL = 64,
    parameter ROW = 9,
    parameter W_DATA = 8,
    parameter W_ADDR = 9,
    parameter RAM_DEPTH = (1 << W_ADDR)
)(
    input i_clk,
    input i_rst,
    input [W_DATA-1 : 0]i_data,
    input [COL-1:0] i_read_enable,
    input [COL-1:0] i_write_enable,
    output [(COL * W_DATA) -1 : 0] o_data,
    output [COL-1:0] o_fifo_empty,
    output [COL-1:0] o_fifo_full,
    output [COL-1:0] o_fifo_dv,
    output [(((W_ADDR + 1) * COL) -1): 0] o_occupants
);

genvar i;
generate
    for(i = 0; i < COL; i = i + 1)begin : IN_COL_FIFO
        fifo_valid#(
            .DATA_WIDTH (W_DATA),
            .ADDR_WIDTH (W_ADDR),
            .RAM_DEPTH (RAM_DEPTH) 
        ) fifo_inst(
            .clk (i_clk),
            .rst(i_rst),
            .data_in(i_data),
            .we (i_write_enable[i]),
            .re (i_read_enable[i]),
            .data_out (o_data[((W_DATA * (COL - i)) -1) -: W_DATA]),
            .occupants(o_occupants[((W_ADDR + 1) * (i + 1)) - 1 -: (W_ADDR + 1)]),
            .empty (o_fifo_empty[i]),
            .full (o_fifo_full[i]),
            .data_valid (o_fifo_dv[i])
        );
    end
endgenerate

endmodule