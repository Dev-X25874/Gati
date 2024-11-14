/*
    Array of fifo used inside the SA engine for storing
    and loading weights and image into PE grid.
*/
module dram_fifo#(
    parameter DIMENSION = 64,
    parameter W_DATA = 8,
    parameter W_ADDR = 9,
    parameter OUTPUT_REG = 1,
    parameter RAM_DEPTH = (1 << W_ADDR)
)(
    input i_clk,
    input i_rst,
    input [(DIMENSION*W_DATA)-1 : 0]i_data,
    input [DIMENSION-1:0] i_read_enable,
    input [DIMENSION-1:0] i_write_enable,
    output [(DIMENSION * W_DATA) -1 : 0] o_data,
    output [DIMENSION-1:0] o_fifo_empty,
    output [DIMENSION-1:0] o_fifo_full,
    output [DIMENSION-1:0] o_fifo_dv,
    output [(((W_ADDR + 1) * DIMENSION) -1): 0] o_occupants
);

wire nw_rst;
assign nw_rst=~i_rst;
genvar i;
generate
    for(i = 0; i < DIMENSION; i = i + 1)begin
        sync_fifo #(
            .W_DATA(W_DATA),
            .OUTPUT_REG(OUTPUT_REG),
            .W_ADDR(W_ADDR)
        ) fifo_inst (
            .full_o(o_fifo_full[i]),
            .empty_o(o_fifo_empty[i]),
            .clk_i(i_clk),
            .wr_en_i(i_write_enable[i]),
            .rd_en_i(i_read_enable[i]),
            .wdata(i_data[(W_DATA*(DIMENSION-i)-1) -:W_DATA]),
            .datacount_o(o_occupants[((W_ADDR + 1) * (DIMENSION -i )) - 1 -: (W_ADDR + 1)]),
            .rst_busy(),
            .rdata(o_data[((W_DATA * (DIMENSION - i)) -1) -: W_DATA]),
            .a_rst_i(nw_rst),
            .o_valid(o_fifo_dv[i])
        );
    end
endgenerate

endmodule
