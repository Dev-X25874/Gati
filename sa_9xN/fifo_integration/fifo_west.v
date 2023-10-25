module fifo_west#(
    parameter ROW = 9,
    parameter W_DATA = 8,
    parameter W_ADDR = 8,
    parameter RAM_DEPTH = (1 << W_ADDR)
)(
    input i_clk,
    input [W_DATA-1:0] i_data,
    input [ROW-1:0] i_write_enable,
    input [ROW-1:0] i_read_enable,
    output [(ROW * W_DATA) -1 : 0] o_data,
    output [ROW-1:0] o_fifo_empty,
    output [ROW-1:0] o_fifo_full,
    output [ROW-1:0] o_fifo_data_valid
);

genvar i;
generate
    for(i = 0; i < ROW; i = i + 1)begin : IN_ROW_FIFO
        fifo_valid#(
            .DATA_WIDTH(W_DATA),
            .ADDR_WIDTH(W_ADDR),
            .RAM_DEPTH(RAM_DEPTH)
        )fifo_inst(
            .clk (i_clk),
            .rst_n (1'b1),
            .data_in (i_data),
            .we (i_write_enable[i]),
            .re (i_read_enable[i]),
            .data_out (o_data[((W_DATA * (ROW - i))-1) -: 8]),
            .occupants (),
            .empty (o_fifo_empty[i]),
            .full (o_fifo_full[i]),
            .data_valid (o_fifo_data_valid[i])
            );
    end
endgenerate

endmodule