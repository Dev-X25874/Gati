module top_fifo_gen #(parameter FIFO_NO = 4, 
                    parameter DATA_WIDTH = 32, 
                    parameter ADDR_WIDTH = 9)
                    (

    input clk,
    input rst_n,
    input [FIFO_NO-1:0] we,
    input [FIFO_NO-1:0] re,
    input [(DATA_WIDTH * FIFO_NO)-1:0] data_in,
    output [((ADDR_WIDTH * FIFO_NO)-1):0] occupants,
    output [FIFO_NO-1:0] full,
    output [FIFO_NO-1:0] empty,
    output [(FIFO_NO * DATA_WIDTH)-1:0] data_out,
    output [FIFO_NO-1:0] data_valid
);

genvar i;
generate
    for (i = 0; i < FIFO_NO; i = i + 1) begin
        fifo_valid #(.DATA_WIDTH(DATA_WIDTH))
        fifo_gen(
            .clk(clk),
            .rst_n(rst_n),
            .we(we[i]),
            .re(re[i]),
            .data_in(data_in),
            .occupants(occupants[(i*ADDR_WIDTH) +: ADDR_WIDTH]),
            .full(),
            .empty(empty[i]),
            .data_out(data_out[(i*DATA_WIDTH) +: DATA_WIDTH]),
            .data_valid(data_valid[i])
        );
    end
    endgenerate

endmodule