module Req_Queue_gen #(
    parameter NUM_QUEUE = 4,
    parameter DATA_WIDTH = 41,
    parameter ADDR_WIDTH = 10, 
    parameter RAM_DEPTH = (1 << ADDR_WIDTH)
    
) (
    input clk,
    input rst, 
    output [NUM_QUEUE-1:0] empty_flag,
    input [NUM_QUEUE-1:0 ] rd_en,
    input [NUM_QUEUE-1:0] Wr_en,
    input [(NUM_QUEUE * 41)-1:0 ] data_in ,
    output [(NUM_QUEUE * 41)-1:0] data_out,
    output [NUM_QUEUE-1:0] rd_out 
    
);
genvar i ;
generate
    for (i = 0; i < NUM_QUEUE; i = i + 1) begin
        data_fifo#(
            .DATA_WIDTH(DATA_WIDTH),
            .FF_DEPTH(RAM_DEPTH)
        ) fifo_inst (
            .prog_full_o(),
            .full_o(),
            .empty_o(empty_flag[i]),
            .clk_i(clk),
            .wr_en_i(Wr_en[i]),
            .rd_en_i(rd_en[i]),
            .wdata(data_in [(41* (NUM_QUEUE - i)) -1 -: 41]),
            .datacount_o(),
            .rst_busy(),
            .rdata(data_out[(41 * (NUM_QUEUE - i))-1 -: 41]),
            .a_rst_i(~rst),
            .o_valid(rd_out[i])
        );
    end 
endgenerate

endmodule
 