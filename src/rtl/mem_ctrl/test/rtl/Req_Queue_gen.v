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
    
       fifo_valid#(
           .DATA_WIDTH (DATA_WIDTH),
           .ADDR_WIDTH (ADDR_WIDTH), 
           .RAM_DEPTH (RAM_DEPTH)
        ) fifo_valid_inst(
            .clk (clk),
            .rst_n (rst),
            .data_in (data_in [(41* (NUM_QUEUE - i)) -1 -: 41]),
            .we (Wr_en[i]),
            .re (rd_en[i]),
            .data_out (data_out[(41 * (NUM_QUEUE - i))-1 -: 41]),
            .occupants (),
            .empty (empty_flag[i]),
            .full (),
            .data_valid (rd_out [i])
);

    end 
endgenerate

endmodule
