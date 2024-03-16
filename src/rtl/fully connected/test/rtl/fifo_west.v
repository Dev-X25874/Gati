/*
    Store data row-wise into array of fifo, such that, 
    all the row's data in systolic array gets loaded simultaneously
    from this array of fifo.
*/
module fifo_west#(
    parameter ROW = 9,
    parameter W_DATA = 8,
    parameter W_ADDR = 8,
    parameter RAM_DEPTH = (1 << W_ADDR)
)(
    input i_clk,
    input i_rst,
    input [W_DATA-1:0] i_data,
    input [ROW-1:0] i_write_enable,
    input [ROW-1:0] i_read_enable,
    output [(ROW * W_DATA) -1 : 0] o_data,
    output [ROW-1:0] o_fifo_empty,
    output [ROW-1:0] o_fifo_full,
    output [ROW-1:0] o_fifo_data_valid,
    output [(((W_ADDR + 1) * ROW) -1): 0] o_occupants
);

genvar i;
generate
    for(i = 0; i < ROW; i = i + 1)begin : IN_ROW_FIFO
        sync_fifo fifo_inst_1(
        .full_o(o_fifo_full[i]),
        .empty_o(o_fifo_empty[i]),
        .clk_i(i_clk),
        .wr_en_i(i_write_enable[i]),
        .rd_en_i(i_read_enable[i]),
        .wdata(i_data),
        .datacount_o(o_occupants[((W_ADDR + 1) * (i + 1)) - 1 -: (W_ADDR + 1)]),
        .rst_busy(),
        .rdata(o_data[((W_DATA * (ROW - i))-1) -: W_DATA]),
        .a_rst_i(i_rst),
        .o_valid(o_fifo_data_valid[i])
        );
    end
endgenerate

endmodule