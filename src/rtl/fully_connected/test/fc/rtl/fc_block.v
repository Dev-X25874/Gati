module fc_block#(
    parameter N_SA = 1,
    parameter W_DATA = 8,
    parameter W_ADDR = 8,
    parameter COL = 4,
    parameter ROW = 1,
    parameter W_PSUM = 19,
    parameter RAM_DEPTH = (1<<W_ADDR),
    parameter W_ACC = 32,
    parameter W_FC_CNT = 15
)(
    input i_clk,
    input s_clk,
    input i_rst,
    input trigger1,
    input trigger2,
    input [(N_SA * W_DATA)-1 : 0] i_north_data,
    input [(COL * N_SA)-1 : 0] i_north_wren,
    input [W_DATA-1 : 0] i_west_data,
    // input [(N_SA * ROW)-1 : 0] i_west_wren,
    input i_west_dv,
    input [W_FC_CNT-1 : 0] i_image_dim,
    output [(COL * N_SA)-1 : 0] o_acc_dv,
    output [((COL * W_ACC) * N_SA)-1 : 0] o_acc_data,
    output [COL-1 : 0] o_west_ctrl_enb
);

mul_engines#(
    .N_SA(N_SA),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .COL(COL),
    .ROW(ROW),
    .W_PSUM(W_PSUM),
    .RAM_DEPTH(RAM_DEPTH)
)mul_sa_engines(
    .i_clk(i_clk),
    .s_clk(s_clk),
    .i_rst(i_rst),
    .i_trigger_1(trigger1),
    .i_trigger_2(trigger2),
    .i_north_data(i_north_data),
    .i_north_wren(i_north_wren),
    .i_west_data(i_west_data),
    .i_west_dv(i_west_dv)
    // .i_west_wren(i_west_wren),
    // .out_partial_sums(out_partial_sums)
    // .o_ps_data_valid(o_ps_data_valid)
);

wire [((COL * (W_PSUM+1)) * N_SA)-1 : 0] out_partial_sums;
// wire [(COL * N_SA)-1 : 0] o_ps_data_valid;

// acc_array#(
//     .COL(COL),
//     .W_ACC(W_ACC),
//     .W_FC_CNT(W_FC_CNT),
//     .W_PSUM(W_PSUM),
//     .N_SA(N_SA)
// ) accumulator_array(
//     .i_clk(i_clk),
//     .i_rst(i_rst),
//     .i_img_dim(i_image_dim),
//     .i_psum_data(out_partial_sums),
//     // .i_psum_dv(o_ps_data_valid),
//     .o_dv(o_acc_dv),
//     .o_data(o_acc_data),
//     .o_ctrl_enb(o_west_ctrl_enb)
// );

endmodule