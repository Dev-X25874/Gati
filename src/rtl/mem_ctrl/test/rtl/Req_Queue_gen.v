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
            .rst (rst),
            .data_in (data_in [(41* (NUM_QUEUE - i)) -1 -: 41]),
            .we (Wr_en[i]),
            .re (rd_en[i]),
            .data_out (data_out[(41 * (NUM_QUEUE - i))-1 -: 41]),
            .occupants (),
            .empty (empty_flag[i]),
            .full (),
            .data_valid (rd_out [i])
);
        /*req_que_mod
        req_que_mod_inst(
            .prog_full_o (),
            .full_o(),
            .empty_o (empty_flag [i]),
            .clk_i (clk),
            .wr_en_i (Wr_en [NUM_QUEUE-1:0]),
            .rd_en_i (rd_en [NUM_QUEUE-1:0]),
            .wdata(data_in [(41 * (NUM_QUEUE - i))-1 -: 41] ),
            .datacount_o (),
            .rst_busy(),
            .rdata (data_out [(41 * (NUM_QUEUE - i))-1 -: 10] ),
            .a_rst_i (rst)
           // .rd_out (rd_out [i])
        );*/
     end 
endgenerate

endmodule


////////////////////////////////////////////////////////////////////////////////////////////////////

/*
genvar i ;
generate
    for (i = 0; i < NUM_QUEUE; i = i + 1) begin
        req_que_mod
        req_que_mod_inst(
            .prog_full_o (),
            .full_o(),
            .empty_o (empty_flag [i]),
            .clk_i (clk),
            .wr_en_i (Wr_en [NUM_QUEUE-1:0]),
            .rd_en_i (rd_en [NUM_QUEUE-1:0]),
            .wdata(data_in [(41 * (NUM_QUEUE - i))-1 -: 41] ),
            .datacount_o (),
            .rst_busy(),
            .rdata (data_out [(41 * (NUM_QUEUE - i))-1 -: 10] ),
            .a_rst_i (rst)
           // .rd_out (rd_out [i])
        );
     end 
endgenerate
*/
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*module Req_Queue_gen #(
    parameter NUM_QUEUE = 4 
) (
        input    clk,      
        input    rst,      
        input [(NUM_QUEUE * 32)-1:0]  in_address, 
        input [(NUM_QUEUE * 4)-1:0]   in_port_id,  
        input [(NUM_QUEUE * 4)-1:0]   in_burst_len,
        input [NUM_QUEUE - 1 :0]      in_enable_rw
          
        output [(NUM_QUEUE * 32)-1:0] out_addr,  
        output [(NUM_QUEUE * 4)-1:0]  out_port_id,  
        output [(NUM_QUEUE * 4)-1:0]  BLEN,
        output [NUM_QUEUE-1:0]        enable_rw,
        output reg [NUM_QUEUE-1:0]    empty_flag 
);

//Generate block to instatiate multiple Req_Queue block 
genvar i ;
generate
    for (i = 0; i < NUM_QUEUE; i = i + 1) begin
        Req_Queue (
          .clk (clk),      
          .rst (rst),      
          .in_address (in_address [(32 * (NUM_QUEUE - i))-1 -: 32] ), 
          .in_port_id (in_port_id [(4 * (NUM_QUEUE - i))-1 -: 4]),  
          .in_burst_len (in_burst_len [(4 * (NUM_QUEUE - i))-1 -: 4]),
          .in_enable_rw (in_enable_rw [i] ),

          .out_addr (out_addr[(32 * (NUM_QUEUE - i))-1 -: 32]),  
          .out_port_id (out_port_id [(4 * (NUM_QUEUE - i))-1 -: 4]),  
          .BLEN (BLEN[(4 * (NUM_QUEUE - i))-1 -: 4]),
          .enable_rw (enable_rw [i]),
          .empty_flag (empty_flag [i])  
        );
     end 
endgenerate 

endmodule */