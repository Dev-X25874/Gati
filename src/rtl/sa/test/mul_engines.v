/*
    Generates sa engine N_SA times
*/
module mul_engines#(
    parameter N_SA = (NSA_LUT + NSA_DSP),
    parameter W_DATA = 8,
    parameter W_ADDR = 8,
    parameter COL = 4,
    parameter ROW = 9,
    parameter W_PSUM = 19,
    parameter RAM_DEPTH = (1<<W_ADDR),
    parameter NSA_LUT = 4,
    parameter NSA_DSP = 4
)(
    input i_clk,
    input s_clk,
    input i_rstn,
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
if(NSA_DSP == 0)begin
    for(i = 0; i < N_SA/2; i = i +1)begin : DSP_SA
        sa_engine_dsp#(
            .W_DATA(W_DATA),
            .W_ADDR(W_ADDR),
            .COL(COL),
            .ROW(ROW),
            .W_PSUM(W_PSUM),
            .RAM_DEPTH(RAM_DEPTH),
            .N_SA(N_SA/2)
        ) dsp_engine_inst (
            .i_clk(),
            .s_clk(),
            .i_rstn(),
            .i_trigger_1(),
            .i_weight_fifo_array_data(),
            .i_weight_fifo_array_write_en(),
            .i_image_fifo_array_data(),
            .i_image_fifo_array_wren(),
            .i_psum_ff_array_read_en(),
            .o_psum_ff_array_partial_sums(),
            .o_psum_ff_array_empty(),
            .o_psum_ff_array_dv()
        );
    end
end
    else if(NSA_DSP == N_SA)begin
        for(i = 0; i < N_SA; i = i +1)begin : DSP_SA
            sa_engine_dsp#(
                .W_DATA(W_DATA),
                .W_ADDR(W_ADDR),
                .COL(COL),
                .ROW(ROW),
                .W_PSUM(W_PSUM),
                .RAM_DEPTH(RAM_DEPTH),
                .N_SA(N_SA)
            ) dsp_engine_inst (
                .i_clk(i_clk),
                .s_clk(s_clk),
                .i_rstn(i_rstn),
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
    end
     else begin
        for(i = 0; i < N_SA/2; i = i +1)begin : DSP_SA
            sa_engine_dsp#(
                .W_DATA(W_DATA),
                .W_ADDR(W_ADDR),
                .COL(COL),
                .ROW(ROW),
                .W_PSUM(W_PSUM),
                .RAM_DEPTH(RAM_DEPTH),
                .N_SA(N_SA/2)
            ) dsp_engine_inst (
                .i_clk(i_clk),
                .s_clk(s_clk),
                .i_rstn(i_rstn),
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
    end
endgenerate
genvar j;
generate
    if(NSA_LUT == 0)begin
        for(j = 0; j < N_SA/2; j = j + 1)begin : LUT_SA
            sa_engine_lut#(
                .W_DATA(W_DATA),
                .W_ADDR(W_ADDR),
                .COL(COL),
                .ROW(ROW),
                .W_PSUM(W_PSUM),
                .RAM_DEPTH(RAM_DEPTH),
                .N_SA(N_SA/2)
            ) lut_engine_inst (
                .i_clk(),
                .s_clk(),
                .i_rstn(),
                .i_trigger_1(),
                .i_weight_fifo_array_data(),
                .i_weight_fifo_array_write_en(),
                .i_image_fifo_array_data(),
                .i_image_fifo_array_wren(),
                .i_psum_ff_array_read_en(),
                .o_psum_ff_array_partial_sums(),
                .o_psum_ff_array_empty(),
                .o_psum_ff_array_dv()
            );

        end 
    end else if(NSA_LUT == N_SA)begin
            for(j = 0; j < N_SA; j = j + 1)begin : LUT_SA
                sa_engine_lut#(
                    .W_DATA(W_DATA),
                    .W_ADDR(W_ADDR),
                    .COL(COL),
                    .ROW(ROW),
                    .W_PSUM(W_PSUM),
                    .RAM_DEPTH(RAM_DEPTH),
                    .N_SA(N_SA)
                ) lut_engine_inst (
                    .i_clk(i_clk),
                    .s_clk(s_clk),
                    .i_rstn(i_rstn),
                    .i_trigger_1(i_trigger_1),
                    .i_weight_fifo_array_data(i_weight_fifo_array_data[(W_DATA * (N_SA - j))-1 -: W_DATA]),
                    .i_weight_fifo_array_write_en(i_weight_fifo_array_write_en[(COL * (N_SA - j))-1 -: COL]),
                    .i_image_fifo_array_data(i_image_fifo_array_data[(W_DATA * (N_SA - j))-1 -: W_DATA]),
                    .i_image_fifo_array_wren(i_image_fifo_array_wren[(ROW * (N_SA - j))-1 -: ROW]),
                    .i_psum_ff_array_read_en(i_psum_ff_array_read_en[(COL * (N_SA - j))-1 -: (COL)]),
                    .o_psum_ff_array_partial_sums(o_psum_ff_array_partial_sums[((COL * W_PSUM) * (N_SA - j))-1 -: (COL * W_PSUM)]),
                    .o_psum_ff_array_empty(o_psum_ff_array_empty[(COL * (N_SA - j))-1 -: COL]),
                    .o_psum_ff_array_dv(o_psum_ff_array_dv[(COL * (N_SA - j))-1 -: COL])
                );
            end
        end
    else begin
        for(j = 0; j < N_SA/2; j = j + 1)begin : LUT_SA
            sa_engine_lut#(
                .W_DATA(W_DATA),
                .W_ADDR(W_ADDR),
                .COL(COL),
                .ROW(ROW),
                .W_PSUM(W_PSUM),
                .RAM_DEPTH(RAM_DEPTH),
                .N_SA(N_SA/2)
            ) lut_engine_inst (
                .i_clk(i_clk),
                .s_clk(s_clk),
                .i_rstn(i_rstn),
                .i_trigger_1(i_trigger_1),
                .i_weight_fifo_array_data(i_weight_fifo_array_data[(W_DATA * (N_SA/2 - j))-1 -: W_DATA]),
                .i_weight_fifo_array_write_en(i_weight_fifo_array_write_en[(COL * (N_SA/2 - j))-1 -: COL]),
                .i_image_fifo_array_data(i_image_fifo_array_data[(W_DATA * (N_SA/2 - j))-1 -: W_DATA]),
                .i_image_fifo_array_wren(i_image_fifo_array_wren[(ROW * (N_SA/2 - j))-1 -: ROW]),
                .i_psum_ff_array_read_en(i_psum_ff_array_read_en[(COL * (N_SA/2 - j))-1 -: (COL)]),
                .o_psum_ff_array_partial_sums(o_psum_ff_array_partial_sums[((COL * W_PSUM) * (N_SA/2 - j))-1 -: (COL * W_PSUM)]),
                .o_psum_ff_array_empty(o_psum_ff_array_empty[(COL * (N_SA/2 - j))-1 -: COL]),
                .o_psum_ff_array_dv(o_psum_ff_array_dv[(COL * (N_SA/2 - j))-1 -: COL])
            );
        end
    end
endgenerate
endmodule