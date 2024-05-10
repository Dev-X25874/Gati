/*
    Array of fifo to store output of PE grid.
    Each fifo in this array store its corrosponding column's
    19 bits of output data coming from PE grid.
*/
module fifo_array#(
    parameter DIMENSION = 3,
    parameter W_DATA = 20,
    parameter W_ADDR = 8,
    parameter RAM_DEPTH = (1 << W_ADDR)
)(
    input i_clk,
    input i_rstn,
    input [(W_DATA * DIMENSION)-1:0] i_data,
    input [DIMENSION-1:0] i_write_enable,
    input [DIMENSION-1:0] i_read_enable,
    output [(W_DATA * DIMENSION)-1:0] o_data,
    output [DIMENSION-1:0] o_fifo_empty,
    output [DIMENSION-1:0] o_data_valid,
    output [DIMENSION-1 : 0] o_fifo_full,
    output [((DIMENSION * (W_ADDR + 1)))-1 : 0] o_occupants
);

genvar i;
generate
    for(i = 0; i < DIMENSION; i = i + 1)begin
        sync_fifo #(
            .W_DATA(W_DATA),
            .W_ADDR(W_ADDR)
        ) psum_fifo (
            .full_o(o_fifo_full[i]),
            .empty_o(o_fifo_empty[i]),
            .clk_i(i_clk),
            .wr_en_i(i_write_enable[i]),
            .rd_en_i(i_read_enable[i]),
            .wdata(i_data[((W_DATA * (DIMENSION - i))-1) -: W_DATA]),
            .datacount_o(o_occupants[((W_ADDR + 1) * (i + 1)) - 1 -: (W_ADDR + 1)]),
            .rst_busy(),
            .rdata(o_data[((W_DATA * (DIMENSION - i))-1) -: W_DATA]),
            .a_rst_i(~i_rstn),
            .o_valid(o_data_valid[i])
        );
    end
endgenerate

endmodule