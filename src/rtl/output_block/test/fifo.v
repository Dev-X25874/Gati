/*                             FIFO Module 
- The module has been replicated 32 times, corresponding to the number of 
bytes DRAM can give at a time. This allows for the creation of 32 instances of the 
fifo, each capable of running independently and simultaneously.
*/

module fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 8,
    parameter RAM_DEPTH = 1 << ADDR_WIDTH)(
                   
    input                           wr_clk,
    input                           rd_clk,
    input                           we,
    input                           re,
    input [DATA_WIDTH-1:0]          data_in,
    output [DATA_WIDTH-1:0]         data_out,
    output                          full_flag,
    output                          empty_flag,
    output [ADDR_WIDTH-1:0]         occupants

  
);
    reg [DATA_WIDTH-1:0]  mem [RAM_DEPTH-1:0];
    reg [ADDR_WIDTH-1:0]        rptr = 0;  //[$clog2(DEPTH)-1:0] 
    reg [ADDR_WIDTH-1:0]        wptr = 0;
    reg [DATA_WIDTH-1:0]        r_data_out = 0; 


    
    always @(posedge wr_clk) begin
        if (we & !full_flag) begin
            mem[wptr] <= data_in;
            wptr <= wptr + 1;
        end  
    end 
    always @(posedge rd_clk) begin
        if (re & !empty_flag) begin
            r_data_out <= mem[rptr];
            rptr <= rptr + 1;
        end  
    end

    assign full_flag = (rptr-1 == wptr);
    assign empty_flag = (wptr == rptr);
    assign occupants = wptr - rptr;
    assign data_out = r_data_out;   
endmodule


module fifo_gen #(
    parameter DATA_WIDTH = 20,
    parameter ADDR_WIDTH = 10,
    parameter FIFO_NO =32

)(
    input                                   gen_wr_clk,
    input                                   gen_rd_clk,
    input [FIFO_NO-1:0]                     gen_we,
    input [FIFO_NO-1:0]                     gen_re,
    input  [DATA_WIDTH-1:0]                 gen_data_in,
    output [DATA_WIDTH*FIFO_NO-1:0]         gen_data_out,
    output [FIFO_NO-1:0]                    gen_full_flag,
    output [FIFO_NO-1:0]                    gen_empty_flag,
    output [ADDR_WIDTH*FIFO_NO-1:0]         gen_occupants
);


genvar i;
generate 
    
    for (i = 0 ; i < FIFO_NO ; i = i + 1) begin : FIFO_INSTANCES
        fifo #(.DATA_WIDTH(DATA_WIDTH),
               .ADDR_WIDTH(ADDR_WIDTH)
        )
        fifo_gen(
                .wr_clk     (gen_wr_clk),
                .rd_clk     (gen_rd_clk),
                .we         (gen_we[i]),
                .re         (gen_re[i]),
                .data_in    (gen_data_in[DATA_WIDTH-1 : 0]),
                .data_out   (gen_data_out[DATA_WIDTH*i +: DATA_WIDTH]),
                .full_flag  (),
                .empty_flag (gen_empty_flag[i]),
                .occupants  ()
        );
end
endgenerate 



endmodule 
