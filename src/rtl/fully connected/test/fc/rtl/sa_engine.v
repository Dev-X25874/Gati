//top module for single sa engine
module sa_engine#(
    parameter W_DATA = 8,
    parameter W_ADDR = 8,
    parameter COL = 4,
    parameter ROW = 1,
    parameter W_PSUM = 19,
    parameter RAM_DEPTH = (1 << W_ADDR),
    parameter W_ACC = 32,
    parameter W_FC_CNT = 15
)(
    input i_clk,
    input s_clk,
    input i_rst,
    input i_trigger_1,
    input [W_FC_CNT-1 : 0] i_img_dim,
    input [W_DATA-1 : 0] i_north_data,
    input [COL-1 : 0] i_north_wren,
    input [W_DATA-1 : 0] i_west_data,
    input [ROW-1 : 0] i_west_empty,
    input [(ROW * (W_ADDR + 1))-1 : 0] i_west_occ,
    output [ROW-1 : 0] o_west_rden,
    input i_west_dv,
    output [COL-1 : 0] o_acc_dv2,
    output [(COL * W_ACC)-1 : 0] o_acc_data2
);

wire [COL-1 : 0] north_rden;
wire [COL-1 : 0] north_dv;
wire [COL-1 : 0] north_empty;
wire [(COL * W_DATA)-1 : 0] north_data;
wire [((W_ADDR + 1) * COL)-1 : 0] north_occupants;

fifo_north#(
    .COL(COL),
    .ROW(ROW),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(RAM_DEPTH)
) north_fifo_array (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(i_north_data),
    .i_read_enable(north_rden),
    .i_write_enable(i_north_wren),
    .o_data(north_data),
    .o_fifo_empty(north_empty),
    .o_fifo_full(),
    .o_fifo_dv(north_dv),
    .o_occupants(north_occupants)
);

wire [(COL * (W_DATA + 1))-1 : 0] o_north_data;

append_dv#(
    .N_DIMENSION(COL), 
    .W_DATA(W_DATA)
)north_array_dv(
    .i_data(north_data),
    .i_data_valid(north_dv),
    .o_data(o_north_data)
);

rden_controller#(
    .COL(COL),
    .ROW(ROW),
    .W_FC_CNT(W_FC_CNT),
    .W_ADDR(W_ADDR)
) fifo_read_enable(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_trigger(i_trigger_1),
    .i_north_empty(north_empty),
    .i_west_empty(i_west_empty),
    .i_north_occ(north_occupants),
    .i_west_occ(i_west_occ),
    .i_img_dim(i_img_dim),
    .o_north_rden(north_rden),
    .o_west_rden(o_west_rden)
);


append_dv#(
    .N_DIMENSION(ROW), 
    .W_DATA(W_DATA)
)west_array_dv(
    .i_data(i_west_data),
    .i_data_valid(i_west_dv),
    .o_data(o_west_data)
);

wire [((W_DATA + 1) * ROW)-1 : 0] o_west_data;

//synchronizers for CDC
(* async_reg = "true" *) reg [(COL * (W_DATA + 1))-1 : 0] x1=0,x2=0;
(* async_reg = "true" *) reg [(ROW * (W_DATA + 1))-1 : 0] y1=0,y2=0;
always @(posedge s_clk)
begin 
    x1<=o_north_data;
    x2<=x1;
    
    y1<=o_west_data;
    y2<=y1;
end

wire  [((W_PSUM + 1) * COL)-1 : 0] out_south_data;

pe_grid#(
    .COL(COL),
    .ROW(ROW),
    .W_DATA(W_DATA),
    .W_PSUM(W_PSUM)
)sa_block(
    .i_clk(s_clk),
    .i_rst(i_rst),
    .i_weight(x2),
    .in_data(y2),
    .o_partial_sum(out_south_data),
    .o_data() 
);

wire [COL-1 : 0] o_acc_dv;
wire [(COL * W_ACC)-1 : 0] o_acc_data;

accumulator#(
    .COL(COL),
    .W_ACC(W_ACC),
    .W_FC_CNT(W_FC_CNT),
    .W_PSUM(W_PSUM)
) accumulator_array(
    .i_clk(s_clk),
    .i_rst(i_rst),
    .i_img_dim(i_img_dim),
    .i_psum_data(out_south_data),
    .o_dv(o_acc_dv),
    .o_data(o_acc_data)
);

//synchronizers for CDC
(*async_reg = "true" *) reg [COL-1 : 0] o_acc_dv1, o_acc_dv2 = 0;
(*async_reg = "true" *) reg [(COL * W_ACC)-1 : 0] o_acc_data1, o_acc_data2 = 0;

always @(posedge i_clk)begin
    o_acc_dv1 <=    o_acc_dv;
    o_acc_dv2 <=    o_acc_dv1;
    o_acc_data1 <=  o_acc_data;
    o_acc_data2 <=  o_acc_data1;
end

endmodule