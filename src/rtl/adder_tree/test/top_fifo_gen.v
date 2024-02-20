module top_fifo_gen #(parameter FIFO_NO = 8, 
                    parameter DATA_WIDTH = 8, 
                    parameter ADDR_WIDTH = 8)
                    (

    input clk,
    input rst_n,
    input [FIFO_NO-1:0] we,
    input [FIFO_NO-1:0] re,
    input [DATA_WIDTH-1:0] data_in,
    output reg [((ADDR_WIDTH+1)*FIFO_NO)-1:0] occupants = 0,
    output [FIFO_NO-1:0] full,
    output [FIFO_NO-1:0] empty,
    output [(FIFO_NO * DATA_WIDTH)-1:0] data_out,
    output [FIFO_NO-1:0] datavalid
);

genvar i;
generate
    for (i = 0; i < FIFO_NO; i = i + 1) begin
        fifo_valid #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH))
        fifo_gen(
            .clk(clk),
            .rst_n(rst_n),
            .we(we[i]),
            .re(re[i]),
            .data_in(data_in),
            .occupants(occupants[i]),
            .full(),
            .empty(empty[i]),
            .data_out(DATA_OUT[((FIFO_NO-i)*DATA_WIDTH)-1 -: DATA_WIDTH]),
            .datavalid(datavalid[i])
        );
    end
    endgenerate

endmodule