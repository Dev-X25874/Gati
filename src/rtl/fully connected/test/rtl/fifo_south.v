//internal south fifo array to store output of pe grid
module fifo_south#(
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
    for(i = 0; i < COL; i = i + 1)begin : OUT_COL_FIFO
        fifo_valid #(
            .DATA_WIDTH(W_DATA),
            .ADDR_WIDTH(W_ADDR),
            .RAM_DEPTH(1 << W_ADDR)
        ) fifo_inst (
            .clk (i_clk),
            .rst (i_rst),
            .data_in (i_data[((W_DATA * (COL - i))-1) -: W_DATA]),
            .we(i_write_enable[i]),
            .re(i_read_enable[i]),
            .data_out(o_data[((W_DATA * (COL - i))-1) -: W_DATA]),
            .occupants(),
            .empty(o_fifo_empty[i]),
            .full(),
            .data_valid(o_data_valid[i])
        );
    end
endgenerate

endmodule