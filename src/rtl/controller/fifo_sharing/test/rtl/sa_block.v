//instantiation of multiple sa engines
module sa_block#(
    parameter N_SA = 4,
    parameter W_DATA = 8,
    parameter W_ADDR = 8,
    parameter COL = 8,
    parameter ROW = 9,
    parameter W_PSUM = 19,
    parameter RAM_DEPTH = (1<<W_ADDR)
)(
    input i_clk,
    input s_clk,
    input i_rst,
    input i_trigger_1,
    input i_trigger_2,
    
    input i_sel_1,
    input i_sel_2,
    input [(N_SA * COL)-1 : 0] i_north_empty,
    input [(N_SA * (COL * (W_ADDR + 1)))-1 : 0] i_north_occ,
    output [(N_SA * COL)-1 : 0] o_north_rden,

    // input [(N_SA * W_DATA)-1 : 0] i_north_data,
    input [(N_SA * (COL * (W_DATA + 1)))-1 : 0] i_north_data,
    // input [(COL * N_SA)-1 : 0] i_north_wren,
    // input [(N_SA * W_DATA)-1 : 0] i_west_data,
    input [(N_SA * (ROW * (W_DATA + 1)))-1 : 0] i_west_data,
    input [(N_SA * ROW)-1 : 0] i_west_wren,
    input [(COL * N_SA)-1 : 0] i_south_array_rden,
    output [((COL * W_PSUM) * N_SA)-1 : 0] out_partial_sums,
    output [(COL * N_SA)-1 : 0] out_south_empty,
    output [(COL * N_SA)-1 : 0] out_south_dv
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
            .N_SA(N_SA)
        ) engine_inst (
            .i_clk(i_clk),
            .s_clk(s_clk),
            .i_rst(i_rst),
            
            .i_sel_1(i_sel_1),
            .i_sel_2(i_sel_2),
            .i_north_empty(i_north_empty[(N_SA * ((COL) * (N_SA - i))) -: COL]),
            .i_north_occ(i_north_occ[(N_SA * ((COL * (W_ADDR + 1)) * (N_SA - i))) -: (COL * (W_ADDR + 1))]),
            .o_north_rden(o_north_rden[(N_SA * ((COL) * (N_SA - i))) -: COL]),


            .i_trigger_1(i_trigger_1),
            .i_trigger_2(i_trigger_2),
            .i_north_data(i_north_data[(N_SA * (W_DATA * (N_SA - i)))-1 -: W_DATA]),
            // .i_north_wren(i_north_wren[(COL * (N_SA - i))-1 -: COL]),
            .i_west_data(i_west_data[(N_SA * (W_DATA * (N_SA - i)))-1 -: W_DATA]),
            .i_west_wren(i_west_wren[(N_SA * (ROW * (N_SA - i)))-1 -: ROW]),
            .i_south_array_rden(i_south_array_rden[( N_SA * (COL * (N_SA-i)))-1 -: (COL)]),
            .out_partial_sums(out_partial_sums[(N_SA * ((COL * W_PSUM) * (N_SA - i)))-1 -: (COL * W_PSUM)]),
            .south_empty(out_south_empty[(N_SA * (COL * (N_SA - i)))-1 -: COL]),
            .south_data_valid(out_south_dv[(N_SA * (COL * (N_SA - i)))-1 -: COL])
        );
    end
endgenerate    
endmodule
