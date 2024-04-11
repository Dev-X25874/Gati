module Top_test_data_ctrl # (
parameter NUM_PORTS = 4 
) (
input clk,
input rst,
output  [NUM_PORTS-1:0] out_valid,
output  [(NUM_PORTS * 8)-1:0] out_test_addr,
output  [(NUM_PORTS * 4)-1:0] out_BLEN,
output  [NUM_PORTS-1:0] out_enable,
output  [NUM_PORTS-1:0] out_last 
);

wire [7:0] addr, addr_in_1, addr_in_2, addr_in_3 ;
wire [4:0] blen_in, blen_in_1, blen_in_2, blen_in_3 ;
wire valid, valid_1, valid_2, valid_3 ;
wire last, last_1, last_2, last_3 ;
wire r_w_en, r_w_en_1, r_w_en_2, r_w_en_3 ;

assign out_test_addr = {addr, addr_in_1, addr_in_2, addr_in_3};
assign out_BLEN = {blen_in, blen_in_1, blen_in_2, blen_in_3} ;
assign out_valid = {valid, valid_1, valid_2, valid_3} ;
assign out_enable = {r_w_en, r_w_en_1, r_w_en_2, r_w_en_3} ;
assign out_last = {last, last_1, last_2, last_3};

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

endmodule