/*
    Generates sa engine N_SA times
*/
module mul_engines#(
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
    input [(N_SA * W_DATA)-1 : 0] i_weight_fifo_array_data,
    input [(COL * N_SA)-1 : 0] i_weight_fifo_array_write_en,
    input [( N_SA * W_DATA)-1 : 0] i_image_fifo_array_data,
    input [(N_SA * ROW)-1 : 0] i_image_fifo_array_wren,
    input [(COL * N_SA)-1 : 0] i_psum_ff_array_read_en,
    output [((COL * W_PSUM) * N_SA)-1 : 0] o_psum_ff_array_partial_sums,
    output [(COL * N_SA)-1 : 0] o_psum_ff_array_empty,
    output [(COL * N_SA)-1 : 0] o_psum_ff_array_dv
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
            .i_trigger_1(i_trigger_1),
            .i_weight_fifo_array_data(i_weight_fifo_array_data[(W_DATA * (N_SA - i))-1 -: W_DATA]),
            .i_weight_fifo_array_write_en(i_weight_fifo_array_write_en[(COL * (N_SA - i))-1 -: COL]),
            .i_image_fifo_array_data(i_image_fifo_array_data[(W_DATA * (N_SA - i))-1 -: W_DATA]),
            .i_image_fifo_array_wren(i_image_fifo_array_wren[(ROW * (N_SA - i))-1 -: ROW]),
            .i_psum_ff_array_read_en(i_psum_ff_array_read_en[(COL * (N_SA-i))-1 -: (COL)]),
            .o_psum_ff_array_partial_sums(o_psum_ff_array_partial_sums[((COL * W_PSUM) * (N_SA - i))-1 -: (COL * W_PSUM)]),
            .o_psum_ff_array_empty(o_psum_ff_array_empty[(COL * (N_SA - i))-1 -: COL]),
            .o_psum_ff_array_dv(o_psum_ff_array_dv[(COL * (N_SA - i))-1 -: COL])
        );
    end
endgenerate    
endmodule