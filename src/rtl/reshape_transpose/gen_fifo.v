module gen_fifo #(
    parameter W_ADDR = 9,
    parameter W_DATA = 8,
    parameter N_FIFO = 32)
    (
        input  clk,
        input  rst,
        input  [N_FIFO-1:0] wen,
        input  [N_FIFO-1:0] ren,
        input  [(N_FIFO*W_DATA)-1:0] wdata,
        output [(N_FIFO*W_ADDR)-1:0] datacount,
        output [N_FIFO-1:0] valid_o,
        output [N_FIFO-1:0] empty_o,
        output [(N_FIFO*W_DATA)-1:0] rdata
    );

    genvar i;

    generate
        for(i=0; i<N_FIFO; i=i+1) begin
            sync_fifo #(.W_ADDR(W_ADDR), .W_DATA(W_DATA)) dut(
                .clk_i(clk),
                .a_rst_i(rst),
                .wr_en_i(wen[N_FIFO-1-i]),
                .rd_en_i(ren[N_FIFO-1-i]),
                .wdata(wdata[((N_FIFO-i)*W_DATA) - 1 -:W_DATA]),
                .rdata(rdata[(W_DATA*(N_FIFO-i)) - 1 -:W_DATA]),
                .datacount_o(datacount[(W_ADDR*(N_FIFO-i)) - 1 -:W_ADDR]),
                .full_o(),
                .empty_o(empty_o[N_FIFO-1-i]),
                .o_valid(valid_o[N_FIFO-1-i])
            );
        end
    endgenerate

endmodule