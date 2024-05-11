//top module for single sa engine
module sa_engine#(
    parameter W_DATA = 8,
    parameter W_ADDR = 8,
    parameter COL = 4,
    parameter ROW = 1,
    parameter W_PSUM = 19,
    parameter N_SA = 1,
    parameter RAM_DEPTH = (1 << W_ADDR),
    parameter W_ACC = 32,
    parameter W_FC_CNT = 15
)(
    input i_clk,
    input s_clk,
    input i_rst,
    input i_weight_rden_trigger,
    input [W_FC_CNT-1 : 0] i_img_dim,
    input [(COL * W_DATA)-1 : 0] i_weight_ff_array_data,
    input [COL-1 : 0] i_weight_ff_array_dv,
    input [COL-1 : 0] i_weight_ff_array_empty,
    input [(COL * (W_ADDR + 1))-1 : 0] i_weight_ff_array_occ,

    input [W_DATA-1 : 0] i_image_data,
    input [ROW-1 : 0] i_west_empty,
    input [(ROW * (W_ADDR + 1))-1 : 0] i_west_occ,
    output [ROW-1 : 0] o_west_rden,
    input i_image_data_valid,
    output [(COL * N_SA)-1 : 0] accumulator_dv,
    output [((COL * W_ACC) * N_SA)-1 : 0] accumulator_data
);

wire [COL-1 : 0] north_rden;
wire [(COL * W_DATA)-1 : 0] north_data;
wire [(COL * (W_DATA + 1))-1 : 0] pe_weights;

append_dv#(
    .N_DIMENSION(COL), 
    .W_DATA(W_DATA)
)north_array_dv(
    .i_data(i_weight_ff_array_data),
    .i_data_valid(i_weight_ff_array_dv),
    .o_data(pe_weights)
);

rden_controller#(
    .COL(COL),
    .ROW(ROW),
    .W_FC_CNT(W_FC_CNT),
    .W_ADDR(W_ADDR)
) fifo_read_enable(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_trigger(i_weight_rden_trigger),
    .i_north_empty(i_weight_ff_array_empty),
    .i_west_empty(i_west_empty),
    .i_north_occ(i_weight_ff_array_occ),
    .i_west_occ(i_west_occ),
    .i_img_dim(i_img_dim),
    .o_north_rden(north_rden),
    .o_west_rden(o_west_rden)
);


append_dv#(
    .N_DIMENSION(ROW), 
    .W_DATA(W_DATA)
)west_array_dv(
    .i_data(i_image_data),
    .i_data_valid(i_image_data_valid),
    .o_data(pe_image)
);

wire [((W_DATA + 1) * ROW)-1 : 0] pe_image;

//synchronizers for CDC
(* async_reg = "true" *) reg [(COL * (W_DATA + 1))-1 : 0] x1=0,x2=0;
(* async_reg = "true" *) reg [(ROW * (W_DATA + 1))-1 : 0] y1=0,y2=0;
always @(posedge s_clk)
begin 
    x1<=pe_weights;
    x2<=x1;
    
    y1<=pe_image;
    y2<=y1;
end

wire [(ROW * (W_DATA + 1))-1 : 0] temp;
wire sa_last_row_dv;
wire  [((W_PSUM + 1) * COL)-1 : 0] out_south_data;

dsp_pe_grid#(
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
    .o_data(temp) 
);

wire [(COL * N_SA)-1 : 0] o_acc_dv;
wire [((COL * W_ACC) * N_SA)-1 : 0] o_acc_data;

accumulator#(
    .COL(COL),
    .W_ACC(W_ACC),
    .W_FC_CNT(W_FC_CNT),
    .W_PSUM(W_PSUM),
    .N_SA(N_SA)
) accumulator_array(
    .i_clk(s_clk),
    .i_rst(i_rst),
    .i_img_dim(i_img_dim),
    .i_psum_data(out_south_data),
    .o_dv(o_acc_dv),
    .o_data(o_acc_data)
);

//synchronizers for CDC
(*async_reg = "true" *) reg [(COL * N_SA)-1 : 0] r_acc_dv, accumulator_dv = 0;
(*async_reg = "true" *) reg [((COL * W_ACC) * N_SA)-1 : 0] r_acc_data, accumulator_data = 0;

always @(posedge i_clk)begin
    r_acc_dv       <=    o_acc_dv;
    accumulator_dv <=    r_acc_dv;
    r_acc_data <=  o_acc_data;
    accumulator_data <=  r_acc_data;
end

endmodule