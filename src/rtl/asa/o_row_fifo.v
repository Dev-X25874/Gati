//Array of fifo to store output of all the rows of systolic array
module o_row_fifo#(
    parameter ROW = 8,
    parameter W_DATA = 8,
    parameter W_ADDR = 8,
    parameter RAM_DEPTH = (1 << W_ADDR)
)(
    input i_clk,
    input [((W_DATA + 1) * ROW)-1:0] i_data,
    input [ROW-1:0] i_read_enable,
    output [ROW-1:0] o_fifo_empty,
    output [ROW-1:0] o_fifo_full,
    output [(ROW * W_DATA)-1:0] o_data,
    output [ROW-1:0] o_data_valid 
);

genvar i;
generate
    for(i = 0; i < ROW; i = i +1) begin : OUT_ROW_FIFO
        fifo_valid#(
            .DATA_WIDTH(W_DATA),
            .ADDR_WIDTH(W_ADDR),
            .RAM_DEPTH(RAM_DEPTH)
        ) fifo_inst_row (
            .clk (i_clk),
            .rst_n (1'b1),
            .data_in (i_data[(((W_DATA + 1) * (ROW - i))-2) -: W_DATA]),
            .we(i_data[(((W_DATA + 1) * (ROW - i))-1)]),
            .re(i_read_enable[i]),
            .data_out(o_data[((W_DATA * (ROW - i))-1) -: W_DATA]),
            .occupants(),
            .empty(o_fifo_empty[i]),
            .full(),
            .data_valid(o_data_valid[i])
        );
    end
endgenerate

endmodule