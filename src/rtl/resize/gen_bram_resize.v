
module gen_bram_resize #(
    parameter W_DATA = 8,
    parameter W_ADDR = 6
)(
    input  clk,
    input  wr_en,
    input  [W_ADDR-1:0]  wr_addr,   // column index
    input  [W_DATA-1:0]  wr_data,
    input  rd_en,
    input  [W_ADDR-1:0]  rd_addr,   // column index
    output [W_DATA-1:0]  rd_data
);

    simple_dpram #(
        .W_DATA (W_DATA),
        .W_ADDR (W_ADDR)
    ) row_buffer_bram (
        .clk      (clk),
        .we       (wr_en),
        .re       (rd_en),
        .waddr    (wr_addr),
        .raddr    (rd_addr),
        .wdata_a  (wr_data),
        .rdata_b  (rd_data)
    );

endmodule
