/*
    Array of fifo used inside the SA engine for storing
    and loading weights and image into PE grid.
*/
module image_fifo_array#(
    parameter DIMENSION = 64,
    parameter W_DATA = 8,
    parameter W_ADDR = 9,
    parameter RAM_DEPTH = (1 << W_ADDR)
)(
    input i_clk,
    input i_rstn,
    input [(DIMENSION * W_DATA) -1 : 0]i_data,
    input [DIMENSION-1:0] i_read_enable,
    input [DIMENSION-1:0] i_write_enable,
    output [(DIMENSION * W_DATA) -1 : 0] o_data,
    output [DIMENSION-1:0] o_fifo_empty,
    output [DIMENSION-1:0] o_fifo_almost_empty,
    output [DIMENSION-1:0] o_fifo_almost_full,
    output [DIMENSION-1:0] o_fifo_full,
    output [DIMENSION-1:0] o_fifo_prog_full,
    output [DIMENSION-1:0] o_fifo_prog_empty,
    output [DIMENSION-1:0] o_fifo_dv,
    output [(((W_ADDR + 1) * DIMENSION) -1): 0] o_occupants
);

genvar i;
generate
    for(i = 0; i < DIMENSION; i = i + 1)begin
        sync_fifo #(
            .W_DATA(W_DATA),
            .W_ADDR(W_ADDR),
            .OUTPUT_REG(0)
        ) fifo_inst (
            .full_o(o_fifo_full[i]),
            .almost_full_o(o_fifo_almost_full[i]),
            .almost_empty_o(o_fifo_almost_empty[i]),
            .prog_full_o(o_fifo_prog_full[i]),
            .prog_empty_o(o_fifo_prog_empty[i]),
            .empty_o(o_fifo_empty[i]),
            .clk_i(i_clk),
            .wr_en_i(i_write_enable[i]),
            .rd_en_i(i_read_enable[i]),
            .wdata(i_data[((W_DATA * (DIMENSION - i)) -1) -: W_DATA]),
            .datacount_o(o_occupants[((W_ADDR + 1) * (i + 1)) - 1 -: (W_ADDR + 1)]),
            .rst_busy(),
            .rdata(o_data[((W_DATA * (DIMENSION - i)) -1) -: W_DATA]),
            .a_rst_i(~i_rstn),
            .o_valid(o_fifo_dv[i])
        );
    end
endgenerate

endmodule