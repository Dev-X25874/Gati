/*
    Generates fifo N_FIFO times.
*/
module uart_fifo_array#(
    parameter N_FIFO = 64,
    parameter W_DATA = 8,
    parameter W_ADDR = 9
)(
    input clk,
    input rst,
    input [W_DATA-1 : 0]i_data,
    input [N_FIFO-1:0] i_read_enable,
    input [N_FIFO-1:0] i_write_enable,
    output [(N_FIFO * W_DATA) -1 : 0] o_data,
    output [N_FIFO-1:0] o_empty,
    output [N_FIFO-1:0] o_valid,
    output [(((W_ADDR + 1) * N_FIFO) -1): 0] o_occupants
);

genvar i;
generate
    for(i = 0; i < N_FIFO; i = i + 1)begin
        fifo #(
            .W_DATA(W_DATA),
            .W_ADDR(W_ADDR)
        )fifo_inst(
            .prog_full_o(),
            .full_o(),
            .empty_o(o_empty[i]),
            .clk_i(clk),
            .wr_en_i(i_write_enable[i]),
            .rd_en_i(i_read_enable[i]),
            .wdata(i_data),
            .datacount_o(o_occupants[((W_ADDR + 1) * (i + 1)) - 1 -: (W_ADDR + 1)]),
            .rst_busy(),
            .rdata(o_data[((W_DATA * (N_FIFO - i)) -1) -: W_DATA]),
            .a_rst_i(rst),
            .o_valid(o_valid[i])
        );
    end
endgenerate

endmodule