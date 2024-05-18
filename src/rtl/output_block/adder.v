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

module adder_v #( parameter DATA_WIDTH = 20,
                parameter OUT_DATA_WIDTH = 21)(
    input [DATA_WIDTH-1:0]          data_in_adder_tree,
    input [DATA_WIDTH-1:0]          data_in_fifo,
    input                           clk,
   input enable,
    input                           data_valid_fifo,
    input                           data_in_valid,
    output                          data_out_valid,
    output [OUT_DATA_WIDTH-1:0]     data_out_adder
);

    reg [OUT_DATA_WIDTH-1:0]        r_data_out_adder;
    reg                             r_data_out_valid;
    reg r_dtr_valid,t_dtr_valid,i_dtr_valid;
    reg [DATA_WIDTH-1:0] r_dtr_data,t_dtr_data,i_dtr_data;
    assign data_out_adder = r_data_out_adder;
    assign data_out_valid = r_data_out_valid;
   

always @(posedge clk) begin
	t_dtr_valid<=data_in_valid;
	t_dtr_data<=data_in_adder_tree;
    
      	i_dtr_valid<=t_dtr_valid;	
      i_dtr_data<=t_dtr_data; 

	r_dtr_data<=i_dtr_data;
	r_dtr_valid<=i_dtr_valid;


    if (r_dtr_valid  && enable) begin
        r_data_out_adder <=r_dtr_data + data_in_fifo;
        r_data_out_valid <= 1'b1;
    end
    else if (r_dtr_valid && ~enable) begin
        r_data_out_adder <= r_dtr_data;
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
    input vector_add_enable,
    input [N-1:0]                       gen_data_valid_fifo,
    input [N-1:0]                       gen_data_in_valid,
    output [N-1:0]                      gen_data_out_valid,
    output [OUT_DATA_WIDTH*N-1:0]       gen_data_out_adder
);


genvar i;
generate 
    for (i = 0 ; i < N ; i = i + 1) begin : ADDER_INSTANCES
        adder_v #(.DATA_WIDTH(DATA_WIDTH),
                .OUT_DATA_WIDTH(OUT_DATA_WIDTH)
        )
        adder_gen(
                .data_in_adder_tree(gen_data_in_adder_tree[DATA_WIDTH*i+: DATA_WIDTH]),
                .data_in_fifo(gen_data_in_fifo[DATA_WIDTH*i+: DATA_WIDTH]),
                .clk(gen_clk),
		.enable(vector_add_enable),
                .data_valid_fifo(gen_data_valid_fifo[i]),
                .data_in_valid(gen_data_in_valid[i]),
                .data_out_valid(gen_data_out_valid[i]),
                .data_out_adder(gen_data_out_adder[OUT_DATA_WIDTH*i+: OUT_DATA_WIDTH])
        );
end
endgenerate 
endmodule 



