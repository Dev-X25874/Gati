/*                       adder Module 
- The output block of Gati plays a crucial role in consolidating and aggregating
data from various channels within the system.

- The adder module serves as the central processing unit within the output block,
performing the critical task of data aggregation. 

- Specifically, it adds the data received from the current adder tree of active 
channels 'data_in_adder_tree' to the accumulated output from previous channel 
adder trees 'data_in_fifo'.

- The module has been replicated N times, corresponding to the number of 
Systolic Array (SA) engines. This allows for the creation of 8 instances of the 
output block, each capable of running independently and simultaneously.

*/

module adder #( parameter DATA_WIDTH = 20,
                parameter OUT_DATA_WIDTH = 21)(
    input [DATA_WIDTH-1:0]          data_in_adder_tree,
    input [DATA_WIDTH-1:0]          data_in_fifo,
    input                           clk,
    input                           data_valid_fifo,
    input                           data_in_valid,
    output                          data_out_valid,
    output [OUT_DATA_WIDTH-1:0]     data_out_adder
);

    reg [OUT_DATA_WIDTH-1:0]        r_data_out_adder;
    reg                             r_data_out_valid;

    assign data_out_adder = r_data_out_adder;
    assign data_out_valid = r_data_out_valid;

always @(posedge clk) begin
    if (data_in_valid && data_valid_fifo) begin
        r_data_out_adder <= data_in_adder_tree + data_in_fifo;
        r_data_out_valid <= 1'b1;
    end
    else begin
        r_data_out_valid <= 1'b0;
    end
end


endmodule


module adder_gen #(
    parameter               DATA_WIDTH = 20,
    parameter               OUT_DATA_WIDTH = 21,
    parameter               N = 8
)(

    input [DATA_WIDTH*N-1:0]            gen_data_in_adder_tree,
    input [DATA_WIDTH*N-1:0]            gen_data_in_fifo,
    input                               gen_clk,
    input [N-1:0]                       gen_data_valid_fifo,
    input [N-1:0]                       gen_data_in_valid,
    output [N-1:0]                      gen_data_out_valid,
    output [OUT_DATA_WIDTH*N-1:0]       gen_data_out_adder
);


genvar i;
generate 
    for (i = 0 ; i < N ; i = i + 1) begin : ADDER_INSTANCES
        adder #(.DATA_WIDTH(DATA_WIDTH),
                .OUT_DATA_WIDTH(OUT_DATA_WIDTH)
        )
        adder_gen(
                .data_in_adder_tree(gen_data_in_adder_tree[DATA_WIDTH*i+: DATA_WIDTH]),
                .data_in_fifo(gen_data_in_fifo[DATA_WIDTH*i+: DATA_WIDTH]),
                .clk(gen_clk),
                .data_valid_fifo(gen_data_valid_fifo[i]),
                .data_in_valid(gen_data_in_valid[i]),
                .data_out_valid(gen_data_out_valid[i]),
                .data_out_adder(gen_data_out_adder[OUT_DATA_WIDTH*i+: OUT_DATA_WIDTH])
        );
end
endgenerate 
endmodule 

module fifo_gen_adder #(
    parameter DATA_WIDTH = 20,
    parameter ADDR_WIDTH = 10,
    parameter FIFO_NO = 8

)(
    input                                   gen_wr_clk,
    input                                   gen_rd_clk,
    input [FIFO_NO-1:0]                     gen_we,
    input [FIFO_NO-1:0]                     gen_re,
    input  [DATA_WIDTH*FIFO_NO-1:0]         gen_data_in,
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
                .data_in    (gen_data_in[DATA_WIDTH*i +: DATA_WIDTH]),
                .data_out   (gen_data_out[DATA_WIDTH*i +: DATA_WIDTH]),
                .full_flag  (),
                .empty_flag (gen_empty_flag[i]),
                .occupants  ()
        );
end
endgenerate 



endmodule 