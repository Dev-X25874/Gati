module Top_mem_ctrl #(
parameter NUM_PORTS = 4,
parameter NUM_QUEUE = 4,
parameter DATA_WIDTH = 41,
parameter ADDR_WIDTH = 32,
parameter BURST_LENGTH_WIDTH = 4,
parameter ADDRESS_WIDTH = 32,
parameter BURST_WIDTH = 4,
parameter POINTER_COUNT = 10,
parameter RAM_DEPTH = (1 << POINTER_COUNT),
parameter BIN_WIDTH = $clog2(NUM_PORTS-1),
parameter PORT_ID_WIDTH = 4
) (
input clk,
input rst,
output [(NUM_PORTS*32)-1 : 0] o_addr,
output [(NUM_PORTS*4)-1:0] o_BLEN ,
output [(NUM_PORTS*4)-1:0] i_port_id,
output [NUM_PORTS-1:0] enable_in,
//output [(NUM_PORTS * 41)-1:0] combined_out,
//output [(NUM_PORTS*41)-1 : 0]  div_out_data,
//output [NUM_PORTS-1:0] rd_out_en ,
//output [NUM_PORTS-1 :0 ] e_flag
output o_valid_req,
output [NUM_PORTS-1:0]  o_grant,
output [ADDR_WIDTH-1:0]  o_addr_div,
output [BURST_LENGTH_WIDTH-1:0] o_burst_div,
output [PORT_ID_WIDTH-1:0] o_port_div,
output o_rw_div 
 
);


wire [NUM_PORTS-1:0] i_valid ;
wire [(NUM_PORTS * 8)-1:0] in_address;
wire [(NUM_PORTS * 4)-1:0] in_BLEN;
wire [NUM_PORTS-1:0] i_enable ;
wire [NUM_PORTS-1:0] i_last ;
wire [(NUM_PORTS * DATA_WIDTH)-1:0] combined_out ;
wire [NUM_PORTS-1:0] e_flag;
wire [NUM_PORTS-1:0] o_valid, r_en ;
wire [(NUM_PORTS*DATA_WIDTH)-1 : 0]  div_out_data ;
wire [NUM_PORTS-1:0] rd_out_en ;


Top_test_data_ctrl # (
    .NUM_PORTS (NUM_PORTS) 
) 
Test_data_inst (  
    .clk (clk),
    .rst (rst),
    .out_valid (i_valid),
    .out_test_addr (in_address),
    .out_BLEN (in_BLEN),
    .out_enable (i_enable),
    .out_last (i_last) 
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

Req_Queue_gen #(
    .NUM_QUEUE(NUM_QUEUE),
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (POINTER_COUNT), 
    .RAM_DEPTH (RAM_DEPTH)
) 
Req_Queue_gen_inst(
    .clk (clk),
    .rst (rst), 
    .empty_flag (e_flag),
    .rd_en (r_en),
    .Wr_en (o_valid),
    .data_in (combined_out),
    .data_out (div_out_data),
    .rd_out (rd_out_en)
    
);

RR_ARB  #(
    .N (NUM_PORTS),
    .NUM_PORTS (NUM_PORTS),
    .PORT_ID_WIDTH (PORT_ID_WIDTH) ,
    .ADDRESS_WIDTH (ADDR_WIDTH),
    .BURST_LENGTH_WIDTH (BURST_LENGTH_WIDTH) ,
    .DATA_WIDTH (DATA_WIDTH)
)
RR_ARB_inst(
	.rst_an (rst),
	.clk (clk),
	.req (~e_flag),
	.grant_out (o_grant),
    .en_pin (1'b1),
    .req_out (r_en),
    .in_data_div (div_out_data),
    .o_addr_div (o_addr_div),
    .o_burst_div (o_burst_div), 
    .o_port_div (o_port_div),
    .o_rw_div (o_rw_div),
    .r_valid (rd_out_en),
    .valid_req (o_valid_req)
);



endmodule 