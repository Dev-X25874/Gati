/*
    Generates sa engine N_SA times
*/
module mul_engines#(
    parameter N_SA = (NSA_LUT + NSA_DSP),
    parameter W_DATA = 8,
    parameter W_ADDR = 9,
    parameter COL = 4,    //number of columns for each engine
    parameter ROW = 9,
    parameter W_PSUM = 19,
    parameter RAM_DEPTH = (1<<W_ADDR),
    parameter NSA_LUT = 0,  //number of LUT based multiplier SA engines
    parameter NSA_DSP = 4,  //number of DSP based multiplier SA engines
    parameter N_BRAM_BYTES = 32
)(
    input i_clk,
    input s_clk,
    input i_rstn,
    input i_trigger_1,
    input i_done,
    input i_layer_done,
    input [(N_SA * (COL * W_DATA))-1 : 0] i_data_weight_ff_sharing,
    input [(N_SA * COL)-1 : 0] i_dv_weight_ff_sharing,
    input [(N_SA * COL)-1 : 0] i_empty_weight_ff_sharing,
    input [(N_SA * (COL * (W_ADDR + 1)))-1 : 0] i_occupants_weight_ff_sharing,
    input [( N_SA * W_DATA)-1 : 0] i_image_ff_array_data,
    input [(N_SA * ROW)-1 : 0] i_image_fifo_array_wren,
    input [(COL * N_SA)-1 : 0] i_psum_ff_array_read_en,
    output [((COL * W_PSUM) * N_SA)-1 : 0] o_psum_ff_array_partial_sums,
    output [(COL * N_SA)-1 : 0] o_psum_ff_array_empty,
    output [(COL * N_SA)-1 : 0] o_psum_ff_array_dv,
    output [(N_SA * COL)-1 : 0] o_read_en_weight_ff_sharing,
    output o_mux_sel
);
wire [N_SA-1 : 0] mux_sel;
assign o_mux_sel = &(mux_sel);
genvar i;
generate
if(NSA_DSP == 0)begin
    for(i = 0; i < N_SA/2; i = i +1)begin : DSP_SA_ENG
        sa_engine_dsp#(
            .W_DATA(W_DATA),
            .W_ADDR(W_ADDR),
            .COL(COL),
            .ROW(ROW),
            .W_PSUM(W_PSUM),
            .RAM_DEPTH(RAM_DEPTH),
            .N_SA(N_SA/2),
            .N_BRAM_BYTES(N_BRAM_BYTES)
        ) dsp_engine_inst (
            .i_clk(),
            .s_clk(),
            .i_rstn(),
            .i_trigger_1(),
            .i_done(),
            .i_layer_done(),
            .o_mux_sel(),
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
        for(i = 0; i < N_SA; i = i +1)begin : DSP_SA_ENG
            sa_engine_dsp#(
                .W_DATA(W_DATA),
                .W_ADDR(W_ADDR),
                .COL(COL),
                .ROW(ROW),
                .W_PSUM(W_PSUM),
                .RAM_DEPTH(RAM_DEPTH),
                .N_SA(N_SA),
                .N_BRAM_BYTES(N_BRAM_BYTES)
            ) dsp_engine_inst (
                .i_clk(i_clk),
                .s_clk(s_clk),
                .i_rstn(i_rstn),
                .i_trigger_1(i_trigger_1),
                .i_done(i_done),
                .i_layer_done(i_layer_done),
                .o_mux_sel(mux_sel[i]),
                .i_weight_fifo_array_data(i_data_weight_ff_sharing[((COL * W_DATA) * (N_SA - i))-1 -: (COL * W_DATA)]),
                .i_weight_fifo_array_dv(i_dv_weight_ff_sharing[(COL * (N_SA - i))-1 -: COL]),
                .i_weight_fifo_array_empty(i_empty_weight_ff_sharing[(COL * (N_SA - i))-1 -: COL]),
                .i_weight_fifo_array_occ(i_occupants_weight_ff_sharing[((COL * (W_ADDR + 1)) * (N_SA - i))-1 -: (COL * (W_ADDR + 1))]),               
                .i_image_fifo_array_data(i_image_ff_array_data[(W_DATA * (N_SA - i))-1 -: W_DATA]),
                .i_image_fifo_array_wren(i_image_fifo_array_wren[(ROW * (N_SA - i))-1 -: ROW]),
                .i_psum_ff_array_read_en(i_psum_ff_array_read_en[(COL * (N_SA-i))-1 -: (COL)]),
                .o_psum_ff_array_partial_sums(o_psum_ff_array_partial_sums[((COL * W_PSUM) * (N_SA - i))-1 -: (COL * W_PSUM)]),
                .o_psum_ff_array_empty(o_psum_ff_array_empty[(COL * (N_SA - i))-1 -: COL]),
                .o_psum_ff_array_dv(o_psum_ff_array_dv[(COL * (N_SA - i))-1 -: COL]),           
                .o_weight_fifo_array_rden(o_read_en_weight_ff_sharing[(COL * (N_SA - i))-1 -: COL])
            );
        end
    end

     else begin
        for(i = 0; i < N_SA/2; i = i +1)begin : DSP_SA_ENG
            sa_engine_dsp#(
                .W_DATA(W_DATA),
                .W_ADDR(W_ADDR),
                .COL(COL),
                .ROW(ROW),
                .W_PSUM(W_PSUM),
                .RAM_DEPTH(RAM_DEPTH),
                .N_SA(N_SA/2),
                .N_BRAM_BYTES(N_BRAM_BYTES)
            ) dsp_engine_inst (
                .i_clk(i_clk),
                .s_clk(s_clk),
                .i_rstn(i_rstn),
                .i_trigger_1(i_trigger_1),
                .i_done(i_done),
                .i_layer_done(i_layer_done),
                .o_mux_sel(mux_sel[i]),
                .i_weight_fifo_array_data(i_data_weight_ff_sharing[((COL * W_DATA) * (N_SA - i))-1 -: (COL * W_DATA)]),
                .i_weight_fifo_array_dv(i_dv_weight_ff_sharing[(COL * (N_SA - i))-1 -: COL]),
                .i_weight_fifo_array_empty(i_empty_weight_ff_sharing[(COL * (N_SA - i))-1 -: COL]),
                .i_weight_fifo_array_occ(i_occupants_weight_ff_sharing[((COL * (W_ADDR + 1)) * (N_SA - i))-1 -: (COL * (W_ADDR + 1))]),
                .i_image_fifo_array_data(i_image_ff_array_data[(W_DATA * (N_SA - i))-1 -: W_DATA]),
                .i_image_fifo_array_wren(i_image_fifo_array_wren[(ROW * (N_SA - i))-1 -: ROW]),
                .i_psum_ff_array_read_en(i_psum_ff_array_read_en[(COL * (N_SA-i))-1 -: (COL)]),
                .o_psum_ff_array_partial_sums(o_psum_ff_array_partial_sums[((COL * W_PSUM) * (N_SA - i))-1 -: (COL * W_PSUM)]),
                .o_psum_ff_array_empty(o_psum_ff_array_empty[(COL * (N_SA - i))-1 -: COL]),
                .o_psum_ff_array_dv(o_psum_ff_array_dv[(COL * (N_SA - i))-1 -: COL]),
                .o_weight_fifo_array_rden(o_read_en_weight_ff_sharing[(COL * (N_SA - i))-1 -: COL])
            );
        end
    end
endgenerate

genvar j;
generate
    if(NSA_LUT == 0)begin
        for(j = 0; j < N_SA/2; j = j + 1)begin : LUT_SA_ENG
            sa_engine_lut#(
                .W_DATA(W_DATA),
                .W_ADDR(W_ADDR),
                .COL(COL),
                .ROW(ROW),
                .W_PSUM(W_PSUM),
                .RAM_DEPTH(RAM_DEPTH),
                .N_SA(N_SA/2),
                .N_BRAM_BYTES(N_BRAM_BYTES)
            ) lut_engine_inst (
                .i_clk(),
                .s_clk(),
                .i_rstn(),
                .i_trigger_1(),
                .i_done(),
                .i_layer_done(),
                .o_mux_sel(),
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
    end else if(NSA_LUT == N_SA)begin
            for(j = 0; j < N_SA; j = j + 1)begin : LUT_SA_ENG
                sa_engine_lut#(
                    .W_DATA(W_DATA),
                    .W_ADDR(W_ADDR),
                    .COL(COL),
                    .ROW(ROW),
                    .W_PSUM(W_PSUM),
                    .RAM_DEPTH(RAM_DEPTH),
                    .N_SA(N_SA),
                    .N_BRAM_BYTES(N_BRAM_BYTES)
                ) lut_engine_inst (
                    .i_clk(i_clk),
                    .s_clk(s_clk),
                    .i_rstn(i_rstn),
                    .i_trigger_1(i_trigger_1),
                    .i_done(i_done),
                    .i_layer_done(i_layer_done),
                    .o_mux_sel(mux_sel[j]),
                    .i_weight_fifo_array_data(i_data_weight_ff_sharing[((COL * W_DATA) * (N_SA - j))-1 -: (COL * W_DATA)]),
                    .i_weight_fifo_array_dv(i_dv_weight_ff_sharing[(COL * (N_SA - j))-1 -: COL]),
                    .i_weight_fifo_array_empty(i_empty_weight_ff_sharing[(COL * (N_SA - j))-1 -: COL]),
                    .i_weight_fifo_array_occ(i_occupants_weight_ff_sharing[((COL * (W_ADDR + 1)) * (N_SA - j))-1 -: (COL * (W_ADDR + 1))]),
                    .i_image_fifo_array_data(i_image_ff_array_data[(W_DATA * (N_SA - j))-1 -: W_DATA]),
                    .i_image_fifo_array_wren(i_image_fifo_array_wren[(ROW * (N_SA - j))-1 -: ROW]),
                    .i_psum_ff_array_read_en(i_psum_ff_array_read_en[(COL * (N_SA - j))-1 -: (COL)]),
                    .o_psum_ff_array_partial_sums(o_psum_ff_array_partial_sums[((COL * W_PSUM) * (N_SA - j))-1 -: (COL * W_PSUM)]),
                    .o_psum_ff_array_empty(o_psum_ff_array_empty[(COL * (N_SA - j))-1 -: COL]),
                    .o_psum_ff_array_dv(o_psum_ff_array_dv[(COL * (N_SA - j))-1 -: COL]),
                    .o_weight_fifo_array_rden(o_read_en_weight_ff_sharing[(COL * (N_SA - j))-1 -: COL])
                );
            end
        end

    else begin
        for(j = 0; j < N_SA/2; j = j + 1)begin : LUT_SA_ENG
            sa_engine_lut#(
                .W_DATA(W_DATA),
                .W_ADDR(W_ADDR),
                .COL(COL),
                .ROW(ROW),
                .W_PSUM(W_PSUM),
                .RAM_DEPTH(RAM_DEPTH),
                .N_SA(N_SA/2),
                .N_BRAM_BYTES(N_BRAM_BYTES)
            ) lut_engine_inst (
                .i_clk(i_clk),
                .s_clk(s_clk),
                .i_rstn(i_rstn),
                .i_trigger_1(i_trigger_1),
                .i_done(i_done),
                .i_layer_done(i_layer_done),
                .o_mux_sel(mux_sel[j]),
                .i_weight_fifo_array_data(i_data_weight_ff_sharing[((COL * W_DATA) * (N_SA/2 - j))-1 -: (COL * W_DATA)]),
                .i_weight_fifo_array_dv(i_dv_weight_ff_sharing[(COL * (N_SA/2 - j))-1 -: COL]),
                .i_weight_fifo_array_empty(i_empty_weight_ff_sharing[(COL * (N_SA/2 - j))-1 -: COL]),
                .i_weight_fifo_array_occ(i_occupants_weight_ff_sharing[((COL * (W_ADDR + 1)) * (N_SA/2 - j))-1 -: (COL * (W_ADDR + 1))]),
                .i_image_fifo_array_data(i_image_ff_array_data[(W_DATA * (N_SA/2 - j))-1 -: W_DATA]),
                .i_image_fifo_array_wren(i_image_fifo_array_wren[(ROW * (N_SA/2 - j))-1 -: ROW]),
                .i_psum_ff_array_read_en(i_psum_ff_array_read_en[(COL * (N_SA/2 - j))-1 -: (COL)]),
                .o_psum_ff_array_partial_sums(o_psum_ff_array_partial_sums[((COL * W_PSUM) * (N_SA/2 - j))-1 -: (COL * W_PSUM)]),
                .o_psum_ff_array_empty(o_psum_ff_array_empty[(COL * (N_SA/2 - j))-1 -: COL]),
                .o_psum_ff_array_dv(o_psum_ff_array_dv[(COL * (N_SA/2 - j))-1 -: COL]),
                .o_weight_fifo_array_rden(o_read_en_weight_ff_sharing[(COL * (N_SA/2 - j))-1 -: COL])
            );
        end
    end
endgenerate

endmodule
