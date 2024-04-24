//instantiation of multiple sa engines
module mul_engines#(
    parameter N_SA = 1,
    parameter W_DATA = 8,
    parameter W_ADDR = 8,
    parameter COL = 32,
    parameter ROW = 1,
    parameter W_PSUM = 19,
    parameter RAM_DEPTH = (1<<W_ADDR),
    parameter W_ACC = 32,
    parameter W_FC_CNT = 15
)(
    input i_clk,
    input s_clk,
    input i_rst,
    input i_trigger_1,
    input i_mux_sel_1,
    input [(N_SA * W_DATA)-1 : 0] i_north_data,
    input [(COL * N_SA)-1 : 0] i_north_wren,
    input [(N_SA * W_DATA)-1 : 0] i_west_data,
    input i_west_dv,
    // input [(N_SA * ROW)-1 : 0] i_west_empty,
    // input [(N_SA * (ROW * (W_ADDR+1)))-1 : 0] i_west_occ,
    input [W_FC_CNT-1 : 0] i_acc_image_dim,
    // output [(N_SA * ROW)-1 : 0] o_west_rden,
    output [(COL * N_SA)-1 : 0] o_acc_dv,
    output [((COL * W_ACC) * N_SA)-1 : 0] o_acc_data,
    output [COL-1 : 0] o_north_empty
);

genvar i;
generate

    for(i = 0; i < N_SA; i = i +1)begin : SA_ENGINE_GEN
    sa_engine#(
        .W_DATA(W_DATA),
        .W_ADDR(W_ADDR),
        .COL(COL),
        .ROW(ROW),
        .W_PSUM(W_PSUM),
        .RAM_DEPTH(RAM_DEPTH),
        .W_ACC(W_ACC),
        .W_FC_CNT(W_FC_CNT)
    ) engine_inst(
        .i_clk(i_clk),
        .s_clk(s_clk),
        .i_rst(i_rst),
        .i_trigger_1(i_trigger_1),
        .i_mux_sel1(i_mux_sel_1),
        .i_img_dim(i_acc_image_dim),
        .i_north_data(i_north_data[(W_DATA * (N_SA - i))-1 -: W_DATA]),
        .i_north_wren(i_north_wren[(COL * (N_SA - i))-1 -: COL]),
        .i_west_data(i_west_data[(W_DATA * (N_SA - i))-1 -: W_DATA]),
        // .i_west_empty(i_west_empty[(ROW * (N_SA - i))-1 -: ROW]),
        // .i_west_occ(i_west_occ[((ROW * (W_ADDR+1)) * (N_SA - i))-1 -: (ROW * (W_ADDR + 1))]),
        // .o_west_rden(o_west_rden[(ROW * (N_SA - i))-1 -: ROW]),
        .i_west_dv(i_west_dv),
        .o_acc_dv2(o_acc_dv[(COL * (N_SA - i))-1 -: COL]),
        .o_acc_data2(o_acc_data[((COL * W_ACC) * (N_SA - i))-1 -: (COL * W_ACC)]),
        .o_north_empty(o_north_empty[(COL * (N_SA - i))-1 -: COL])
    );
    end
endgenerate    
endmodule