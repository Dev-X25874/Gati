/*
    Array of fifo to store output of PE grid.
    Each fifo in this array store its corrosponding column's
    19 bits of output data coming from PE grid.
*/
module psum_fifo_array#(
    parameter COL = 3,
    parameter W_DATA = 20,
    parameter W_ADDR = 8,
    parameter RAM_DEPTH = (1 << W_ADDR)
)(
    input i_clk,
    input i_rst,
    input [(W_DATA * COL)-1:0] i_data,
    input [COL-1:0] i_write_enable,
    input [COL-1:0] i_read_enable,
    output [(W_DATA * COL)-1:0] o_data,
    output [COL-1:0] o_fifo_empty,
    output [COL-1:0] o_data_valid
);

genvar i;
generate
    for(i = 0; i < COL; i = i + 1)begin
        sync_fifo #(
            .W_DATA(W_DATA)
        ) psum_fifo (
            .full_o(),
            .empty_o(o_fifo_empty[i]),
            .clk_i(i_clk),
            .wr_en_i(i_write_enable[i]),
            .rd_en_i(i_read_enable[i]),
            .wdata(i_data[((W_DATA * (COL - i))-1) -: W_DATA]),
            .datacount_o(),
            .rst_busy(),
            .rdata(o_data[((W_DATA * (COL - i))-1) -: W_DATA]),
            .a_rst_i(i_rst),
            .o_valid(o_data_valid[i])
        );
    end
endgenerate

endmodule