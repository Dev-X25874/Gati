//this is to generate fifo arrays for storing in the 32 bits in order to test the main design; it mimics for intermediate result input

module top_fifo_gen_controller #(parameter FIFO_NO = 4, 
                    parameter DATA_WIDTH = 32, 
                    parameter ADDR_WIDTH = 9)
                    (

    input clk,
    input rst_n,
    input [FIFO_NO-1:0] we,
    input [FIFO_NO-1:0] re,
    input [(DATA_WIDTH)-1:0] data_in, //
    output [((ADDR_WIDTH * FIFO_NO)-1):0] occupants,
    output [FIFO_NO-1:0] full,
    output [FIFO_NO-1:0] empty,
    output [(FIFO_NO * DATA_WIDTH)-1:0] data_out,
    output [FIFO_NO-1:0] data_valid
);

genvar i;
generate
    for (i = 0; i < FIFO_NO; i = i + 1) begin
        fifo_ip #(.DATA_WIDTH(DATA_WIDTH))
        fifo_gen(
            .clk_i(clk),
            .a_rst_i(~rst_n),
            .wr_en_i(we[i]),
            .rd_en_i(re[i]),
            .wdata(data_in),
            .datacount_o(occupants[((FIFO_NO-i)*ADDR_WIDTH)-1 -: ADDR_WIDTH]),
            .full_o(),
            .empty_o(empty[i]),
            .rdata(data_out[((FIFO_NO-i)*DATA_WIDTH)-1 -: DATA_WIDTH]),
            .o_valid(data_valid[i])
        );
    end
    endgenerate

endmodule