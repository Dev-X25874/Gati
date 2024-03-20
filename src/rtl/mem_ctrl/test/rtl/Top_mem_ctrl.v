module Top_mem_ctrl #(
    parameter NUM_PORTS = 4,
    parameter NUM_QUEUE = 4,
    parameter ADDR_WIDTH = 32,
    parameter BURST_LENGTH_WIDTH = 4,
    parameter PORT_ID_WIDTH = 4,
    parameter POINTER_COUNT = 10,
    parameter RAM_DEPTH = (1 << POINTER_COUNT),
    parameter DATA_WIDTH = 41
) (
input clk,
input rst,
input [NUM_PORTS-1:0] i_valid, 
input [NUM_PORTS-1:0] i_last,
input [(NUM_PORTS * 8)-1:0] in_address,
input [(NUM_PORTS * 4)-1:0] in_BLEN,
input [NUM_PORTS-1:0] i_enable,
output [(NUM_PORTS*32)-1 : 0] o_addr,
output [(NUM_PORTS*4)-1:0] o_BLEN ,
output [(NUM_PORTS*4)-1:0] i_port_id,
output [NUM_PORTS-1:0] enable_in,
//output [(NUM_PORTS*41)-1 : 0]  div_out_data,
output [NUM_PORTS-1:0]  o_grant,
output [ADDR_WIDTH-1:0]  o_addr_div,
output [BURST_LENGTH_WIDTH-1:0] o_burst_div,
output [PORT_ID_WIDTH-1:0] o_port_div,
output o_rw_div ,
input en_pin
);

//wire [(NUM_PORTS * 32)-1:0 ] o_addr;     //d_addr;
//wire [(NUM_PORTS * 4)-1:0] o_BLEN, i_port_id;    //d_BLEN, d_port_id;
//wire [NUM_PORTS-1:0] enable_in;   // d_rw;
wire [NUM_PORTS-1:0]  e_flag , rd_out_en, o_valid , r_en;
wire [(NUM_PORTS * 41)-1:0] div_out_data ; 

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
	.grant (o_grant),
    .en_pin (en_pin),
    .req_out (r_en),
    .in_data_div (div_out_data),
    .o_addr_div (o_addr_div),
    .o_burst_div (o_burst_div), 
    .o_port_div (o_port_div),
    .o_rw_div (o_rw_div),
    .r_valid (rd_out_en)
);



endmodule 


///////////////////////////////////////////////////////////////////////////////////

/*//output [(NUM_QUEUE * 41)-1:0] div_out_data,
//output [(NUM_PORTS * 32)-1:0] out_addr,
output [(NUM_PORTS * 32)-1:0] d_addr,
//output [(NUM_PORTS * 4)-1:0] out_port_id,
output [(NUM_PORTS * 4)-1:0] d_port_id,
output [(NUM_PORTS * 4)-1:0] d_BLEN,
//output [(NUM_PORTS * 4)-1:0] out_BLEN,
//output [NUM_PORTS-1:0] enable_rw,
output [NUM_PORTS-1:0] d_rw,
input [NUM_QUEUE-1:0] en_pin*/

///////////////////////////////////////////////////////////////////////////////////////////////////
/*Req_Queue_gen #(
    .NUM_QUEUE(NUM_PORTS)
) (
        .clk (clk),      
        .rst (rst),      
        .in_address (o_addr), 
        .in_port_id (i_port_id),  
        .in_burst_len (o_BLEN),
        .in_enable_rw (enable_in),
        .out_addr (out_add),  
        .out_port_id (out_port_id),  
        .BLEN (BLEN),
        .enable_rw (enable_rw),
        .empty_flag (e_flag) 
);
*/
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////input converter //////////////////////////////////////////////////////////////////////////
/*genvar i ;
generate 
    for (i= 0; i<NUM_PORTS; i = i+1) begin 
.o_addr_div ()
        inputconvert #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH),
        .PORT_ID_WIDTH(PORT_ID_WIDTH)
      ) 
      o2i_inst (
        .clk (clk),
        .rst (rst) ,
        .address(o_addr[(32 * (NUM_PORTS - i))-1 -: 32]),
        .burst_length(o_BLEN[(4 * (NUM_PORTS - i))- 1 -: 4]),
        .i_port(i_port_id[(4 * (NUM_PORTS - i))- 1 -: 4]),
        .rw_in(enable_in[i]),
        .combined_input(div_data[(41 * (NUM_PORTS - i))-1 -: 41])
      );
    end
 endgenerate*/
////////////////////////////////////////////////////////////////////////////////////////////////
/*
Req_Queue_gen #(
    .NUM_QUEUE(NUM_PORTS)
) 
Req_Queue_gen_inst(
    .clk (clk),
    .rst (rst), 
    .empty_flag (e_flag),
    .rd_en (r_en),
    .Wr_en (w_en),
    .data_in (div_data),
    .data_out (div_out_data)
    //.rd_out (rd_out_en)
    
);*/
//////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////output divider///////////////////////////////////////
/*genvar j ;
generate 
    for (j=0; j<NUM_PORTS; j = j+1) begin 
        output_divider #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH),
        .PORT_ID_WIDTH(PORT_ID_WIDTH)
        ) 
        
         output_divider_inst (
        .clk (clk),
        .rst (rst),
        .divide_out(div_out_data[(41 * (NUM_PORTS - j))-1 -: 41]),
        .div_addr(d_addr[(32 * (NUM_PORTS - j))-1 -: 32]),
        .div_BLEN(d_BLEN[(4 * (NUM_PORTS - j))- 1 -: 4]),
        .div_port_id(d_port_id[(4 * (NUM_PORTS - j))- 1 -: 4]),
        .div_rw(d_rw[j])
      );
   end 
endgenerate*/
//////////////////////////////////////////////////////////////////////////////
/*
RR_ARB 
RR_ARB_inst(
	.rst_an (rst),
	.clk (clk),
	.req(e_flag),
	.grant (r_en),
    .en_pin (en_pin),
    .in_address (d_addr),
    .in_rw_enable (d_rw),
    .in_burst_length (d_BLEN),
    .grant_port_id (d_port_id),
    .rd_en (r_en),
    .stored_address (out_addr),
    .stored_port_id (out_port_id),
    .stored_rw_enable (enable_rw),
    .stored_burst_length (out_BLEN)
);
*/