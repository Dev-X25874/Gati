/*
    Store weights column-wise into array of fifo, such that, 
    weights from each fifo gets loaded into each column of
    SA or FC block.
*/
module test_weight_ff_array#(
    parameter COL = 32,
    parameter W_DATA = 8,
    parameter WEIGHT_FF_DEPTH = 512
)(
    input i_clk,
    input i_rstn,
    input [(COL * W_DATA)-1 : 0]i_data,
    input [COL-1:0] i_read_enable,      
    input [COL-1:0] i_write_enable,
    output [(COL * W_DATA) -1 : 0] o_data,
    output [COL-1:0] o_fifo_empty,
    output [COL-1:0] o_fifo_full,
    output [COL-1:0] o_fifo_dv,
    output [(((WEIGHT_FF_ADDR + 1) * COL) -1): 0] o_occupants
);

localparam WEIGHT_FF_ADDR = $clog2(WEIGHT_FF_DEPTH);

genvar i;
generate
    for(i = 0; i < COL; i = i + 1)begin : IN_COL_FIFO
        sync_fifo #(
            .W_DATA(W_DATA),
            .W_ADDR(WEIGHT_FF_ADDR)
        ) fifo_array (
            .full_o(o_fifo_full[i]),
            .empty_o(o_fifo_empty[i]),
            .clk_i(i_clk),
            .wr_en_i(i_write_enable[i]),
            .rd_en_i(i_read_enable[i]),
            .wdata(i_data),
            .datacount_o(o_occupants[((WEIGHT_FF_ADDR + 1) * (i + 1)) - 1 -: (WEIGHT_FF_ADDR + 1)]),
            .rst_busy(),
            .rdata(o_data[((W_DATA * (COL - i)) -1) -: W_DATA]),
            .a_rst_i(~i_rstn),
            .o_valid(o_fifo_dv[i])
        );

    end
endgenerate

endmodule
