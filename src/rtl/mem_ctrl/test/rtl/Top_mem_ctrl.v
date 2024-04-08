module Top_test #(
parameter NUM_PORTS = 4,
parameter NUM_QUEUE = 4,
parameter DATA_WIDTH = 41

) (
input clk,
input rst,
output [(NUM_PORTS*32)-1 : 0] o_addr,
output [(NUM_PORTS*4)-1:0] o_BLEN ,
output [(NUM_PORTS*4)-1:0] i_port_id,
output [NUM_PORTS-1:0] enable_in,
output [(NUM_PORTS * 41)-1:0] combined_out,
output [(NUM_PORTS*41)-1 : 0]  div_out_data,
output [NUM_PORTS-1:0] rd_out_en 
);

wire [7:0] addr, addr_in_1, addr_in_2, addr_in_3 ;
wire [3:0] blen_in, blen_in_1, blen_in_2, blen_in_3 ;
wire valid, valid_1, valid_2, valid_3 ;
wire r_w_en, r_w_en_1, r_w_en_2, r_w_en_3 ;
wire last , last_1, last_2, last_3 ;

wire [NUM_PORTS-1:0] i_valid ;
wire [(NUM_PORTS * 8)-1:0] in_address;
wire [(NUM_PORTS * 4)-1:0] in_BLEN;
wire [NUM_PORTS-1:0] i_enable ;
wire [NUM_PORTS-1:0] i_last ;

assign in_address = {addr, addr_in_1, addr_in_2, addr_in_3};
assign in_BLEN = {blen_in, blen_in_1, blen_in_2, blen_in_3} ;
assign i_valid = {valid, valid_1, valid_2, valid_3} ;
assign i_enable = {r_w_en, r_w_en_1, r_w_en_2, r_w_en_3} ;
assign i_last = {last, last_1, last_2, last_3};



Test_data_ctrl
Test1_inst(
    .clk (clk),
    .rst (rst),
    .addr (addr),
    .last (last),
    .blen_in (blen_in) ,
    .valid (valid),
    .r_w_en (r_w_en) 
);

Test_data_ctrl_1
Test2_inst(
    .clk (clk),
    .rst (rst),
    .addr_in_1 (addr_in_1),
    .last_1 (last_1),
    .blen_in_1 (blen_in_1) ,
    .valid_1 (valid_1),
    .r_w_en_1 (r_w_en_1) 
);

Test_data_ctrl_2
Test3_inst(
    .clk (clk),
    .rst (rst),
    .last_2 (last_2),
    .addr_in_2 (addr_in_2),
    .blen_in_2 (blen_in_2),
    .valid_2 (valid_2),
    .r_w_en_2 (r_w_en_2) 
);

Test_data_ctrl_3 
Test4_inst(
    .clk (clk),
    .rst(rst),
    .last_3 (last_3),
    .addr_in_3 (addr_in_3),
    .blen_in_3 (blen_in_3) ,
    .valid_3 (valid_3),
    .r_w_en_3 (r_w_en_3) 
);

Port_ctrl_gen #(
    .NUM_PORTS(NUM_PORTS)
) 
port_ctrl_gen_inst(
    .clk (clk),
    .rst(rst), 
    .valid(i_valid),        
    .last (i_last),       
    .o_valid (o_valid),  
    .in_address (in_address),   
    .in_burst_len (in_BLEN), 
    .in_enable_rw(i_enable),   
    .out_address (o_addr),  
    .out_burst_len (o_BLEN),
    .out_enable_rw (enable_in),
    .port_id (i_port_id),
    .combined_out (combined_out)

);
wire [(NUM_PORTS * 41)-1:0] combined_out ;


Req_Queue_gen #(
    .NUM_QUEUE(NUM_PORTS),
    .DATA_WIDTH (DATA_WIDTH)
   // .ADDR_WIDTH (POINTER_COUNT), 
    //.RAM_DEPTH (RAM_DEPTH)
) 
Req_Queue_gen_inst(
    .clk (clk),
    .rst (rst), 
    .empty_flag (e_flag),
 //   .rd_en (r_en),
    .rd_en (1'b1),
    .Wr_en (o_valid),
    .data_in (combined_out),
    .data_out (div_out_data),
    .rd_out (rd_out_en)
    
);
endmodule 