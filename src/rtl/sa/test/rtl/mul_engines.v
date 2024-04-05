/*
    Generates sa engine N_SA times
*/
module mul_engines#(
    parameter N_SA = (NSA_BOOTH + NSA_DSP),
    parameter W_DATA = 8,
    parameter W_ADDR = 9,
    parameter COL = 4,
    parameter ROW = 9,
    parameter W_PSUM = 19,
    parameter RAM_DEPTH = (1<<W_ADDR),
    parameter NSA_BOOTH = 0,
    parameter NSA_DSP = 1
)(
    input i_clk,
    input s_clk,
    input i_rst,
    input i_trigger_1,
    input [(N_SA * (COL * W_DATA))-1 : 0] i_weight_fifo_array_data,
    input [(N_SA * COL)-1 : 0] i_weight_fifo_array_dv,
    input [(N_SA * COL)-1 : 0] i_weight_fifo_array_empty,
    input [(N_SA * (COL * (W_ADDR + 1)))-1 : 0] i_weight_fifo_array_occupants,
    input [( N_SA * W_DATA)-1 : 0] i_image_fifo_array_data,
    input [(N_SA * ROW)-1 : 0] i_image_fifo_array_wren,
    input [(COL * N_SA)-1 : 0] i_psum_ff_array_read_en,
    output [((COL * W_PSUM) * N_SA)-1 : 0] o_psum_ff_array_partial_sums,
    output [(COL * N_SA)-1 : 0] o_psum_ff_array_empty,
    output [(COL * N_SA)-1 : 0] o_psum_ff_array_dv,
    output [(N_SA * COL)-1 : 0] o_weight_fifo_array_read_enable
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
            .i_rst(),
            .i_trigger_1(),
            .i_weight_fifo_array_data(),
            .i_weight_fifo_array_dv(),
            .i_weight_fifo_array_empty(),
            .i_weight_fifo_array_occ(),
            .i_image_fifo_array_data(),
            .i_image_fifo_array_wren(),
            .i_psum_ff_array_read_en(),
            .o_psum_ff_array_partial_sums(),
            .o_psum_ff_array_empty(),
            .o_psum_ff_array_dv(),
            .o_weight_fifo_array_rden()
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
                .i_rst(i_rst),
                .i_trigger_1(i_trigger_1),
                .i_weight_fifo_array_data(i_weight_fifo_array_data[((COL * W_DATA) * (N_SA - i))-1 -: (COL * W_DATA)]),
                .i_weight_fifo_array_dv(i_weight_fifo_array_dv[(COL * (N_SA - i))-1 -: COL]),
                .i_weight_fifo_array_empty(i_weight_fifo_array_empty[(COL * (N_SA - i))-1 -: COL]),
                .i_weight_fifo_array_occ(i_weight_fifo_array_occupants[((COL * (W_ADDR + 1)) * (N_SA - i))-1 -: (COL * (W_ADDR + 1))]),               
                .i_image_fifo_array_data(i_image_fifo_array_data[(W_DATA * (N_SA - i))-1 -: W_DATA]),
                .i_image_fifo_array_wren(i_image_fifo_array_wren[(ROW * (N_SA - i))-1 -: ROW]),
                .i_psum_ff_array_read_en(i_psum_ff_array_read_en[(COL * (N_SA-i))-1 -: (COL)]),
                .o_psum_ff_array_partial_sums(o_psum_ff_array_partial_sums[((COL * W_PSUM) * (N_SA - i))-1 -: (COL * W_PSUM)]),
                .o_psum_ff_array_empty(o_psum_ff_array_empty[(COL * (N_SA - i))-1 -: COL]),
                .o_psum_ff_array_dv(o_psum_ff_array_dv[(COL * (N_SA - i))-1 -: COL]),           
                .o_weight_fifo_array_rden(o_weight_fifo_array_read_enable[(COL * (N_SA - i))-1 -: COL])
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
                .i_rst(i_rst),
                .i_trigger_1(i_trigger_1),
                .i_weight_fifo_array_data(i_weight_fifo_array_data[((COL * W_DATA) * (N_SA - i))-1 -: (COL * W_DATA)]),
                .i_weight_fifo_array_dv(i_weight_fifo_array_dv[(COL * (N_SA - i))-1 -: COL]),
                .i_weight_fifo_array_empty(i_weight_fifo_array_empty[(COL * (N_SA - i))-1 -: COL]),
                .i_weight_fifo_array_occ(i_weight_fifo_array_occupants[((COL * (W_ADDR + 1)) * (N_SA - i))-1 -: (COL * (W_ADDR + 1))]),
                .i_image_fifo_array_data(i_image_fifo_array_data[(W_DATA * (N_SA - i))-1 -: W_DATA]),
                .i_image_fifo_array_wren(i_image_fifo_array_wren[(ROW * (N_SA - i))-1 -: ROW]),
                .i_psum_ff_array_read_en(i_psum_ff_array_read_en[(COL * (N_SA-i))-1 -: (COL)]),
                .o_psum_ff_array_partial_sums(o_psum_ff_array_partial_sums[((COL * W_PSUM) * (N_SA - i))-1 -: (COL * W_PSUM)]),
                .o_psum_ff_array_empty(o_psum_ff_array_empty[(COL * (N_SA - i))-1 -: COL]),
                .o_psum_ff_array_dv(o_psum_ff_array_dv[(COL * (N_SA - i))-1 -: COL]),
                .o_weight_fifo_array_rden(o_weight_fifo_array_read_enable[(COL * (N_SA - i))-1 -: COL])
            );
        end
    end
endgenerate

genvar j;
generate
    if(NSA_BOOTH == 0)begin
        for(j = 0; j < N_SA/2; j = j + 1)begin : BOOTH_SA
            sa_engine_booth#(
                .W_DATA(W_DATA),
                .W_ADDR(W_ADDR),
                .COL(COL),
                .ROW(ROW),
                .W_PSUM(W_PSUM),
                .RAM_DEPTH(RAM_DEPTH),
                .N_SA(N_SA/2)
            ) booth_engine_inst (
                .i_clk(),
                .s_clk(),
                .i_rst(),
                .i_trigger_1(),
                .i_weight_fifo_array_data(),
                .i_weight_fifo_array_dv(),
                .i_weight_fifo_array_empty(),
                .i_weight_fifo_array_occ(),
                .i_image_fifo_array_data(),
                .i_image_fifo_array_wren(),
                .i_psum_ff_array_read_en(),
                .o_psum_ff_array_partial_sums(),
                .o_psum_ff_array_empty(),
                .o_psum_ff_array_dv(),
                .o_weight_fifo_array_rden()
            );
        
        end 
    end else if(NSA_BOOTH == N_SA)begin
            for(j = 0; j < N_SA; j = j + 1)begin : BOOTH_SA
                sa_engine_booth#(
                    .W_DATA(W_DATA),
                    .W_ADDR(W_ADDR),
                    .COL(COL),
                    .ROW(ROW),
                    .W_PSUM(W_PSUM),
                    .RAM_DEPTH(RAM_DEPTH),
                    .N_SA(N_SA)
                ) booth_engine_inst (
                    .i_clk(i_clk),
                    .s_clk(s_clk),
                    .i_rst(i_rst),
                    .i_trigger_1(i_trigger_1),
                    .i_weight_fifo_array_data(i_weight_fifo_array_data[((COL * W_DATA) * (N_SA - j))-1 -: (COL * W_DATA)]),
                    .i_weight_fifo_array_dv(i_weight_fifo_array_dv[(COL * (N_SA - j))-1 -: COL]),
                    .i_weight_fifo_array_empty(i_weight_fifo_array_empty[(COL * (N_SA - j))-1 -: COL]),
                    .i_weight_fifo_array_occ(i_weight_fifo_array_occupants[((COL * (W_ADDR + 1)) * (N_SA - j))-1 -: (COL * (W_ADDR + 1))]),
                    .i_image_fifo_array_data(i_image_fifo_array_data[(W_DATA * (N_SA - j))-1 -: W_DATA]),
                    .i_image_fifo_array_wren(i_image_fifo_array_wren[(ROW * (N_SA - j))-1 -: ROW]),
                    .i_psum_ff_array_read_en(i_psum_ff_array_read_en[(COL * (N_SA - j))-1 -: (COL)]),
                    .o_psum_ff_array_partial_sums(o_psum_ff_array_partial_sums[((COL * W_PSUM) * (N_SA - j))-1 -: (COL * W_PSUM)]),
                    .o_psum_ff_array_empty(o_psum_ff_array_empty[(COL * (N_SA - j))-1 -: COL]),
                    .o_psum_ff_array_dv(o_psum_ff_array_dv[(COL * (N_SA - j))-1 -: COL]),
                    .o_weight_fifo_array_rden(o_weight_fifo_array_read_enable[(COL * (N_SA - j))-1 -: COL])
                );
            end
        end

    else begin
        for(j = 0; j < N_SA/2; j = j + 1)begin : BOOTH_SA
            sa_engine_booth#(
                .W_DATA(W_DATA),
                .W_ADDR(W_ADDR),
                .COL(COL),
                .ROW(ROW),
                .W_PSUM(W_PSUM),
                .RAM_DEPTH(RAM_DEPTH),
                .N_SA(N_SA/2)
            ) booth_engine_inst (
                .i_clk(i_clk),
                .s_clk(s_clk),
                .i_rst(i_rst),
                .i_trigger_1(i_trigger_1),
                .i_weight_fifo_array_data(i_weight_fifo_array_data[((COL * W_DATA) * (N_SA/2 - j))-1 -: (COL * W_DATA)]),
                .i_weight_fifo_array_dv(i_weight_fifo_array_dv[(COL * (N_SA/2 - j))-1 -: COL]),
                .i_weight_fifo_array_empty(i_weight_fifo_array_empty[(COL * (N_SA/2 - j))-1 -: COL]),
                .i_weight_fifo_array_occ(i_weight_fifo_array_occupants[((COL * (W_ADDR + 1)) * (N_SA/2 - j))-1 -: (COL * (W_ADDR + 1))]),
                .i_image_fifo_array_data(i_image_fifo_array_data[(W_DATA * (N_SA/2 - j))-1 -: W_DATA]),
                .i_image_fifo_array_wren(i_image_fifo_array_wren[(ROW * (N_SA/2 - j))-1 -: ROW]),
                .i_psum_ff_array_read_en(i_psum_ff_array_read_en[(COL * (N_SA/2 - j))-1 -: (COL)]),
                .o_psum_ff_array_partial_sums(o_psum_ff_array_partial_sums[((COL * W_PSUM) * (N_SA/2 - j))-1 -: (COL * W_PSUM)]),
                .o_psum_ff_array_empty(o_psum_ff_array_empty[(COL * (N_SA/2 - j))-1 -: COL]),
                .o_psum_ff_array_dv(o_psum_ff_array_dv[(COL * (N_SA/2 - j))-1 -: COL]),
                .o_weight_fifo_array_rden(o_weight_fifo_array_read_enable[(COL * (N_SA/2 - j))-1 -: COL])
            );
        end
    end
endgenerate

endmodule