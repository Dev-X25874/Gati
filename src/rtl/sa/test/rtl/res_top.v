module res_top #(
    parameter N_SA = (NSA_BOOTH + NSA_DSP),
    parameter W_DATA = 8,
    parameter W_ADDR = 9,
    parameter COL = 8,
    parameter ROW = 9,
    parameter W_PSUM = 19,
    parameter RAM_DEPTH = (1 << W_ADDR),
    parameter NSA_BOOTH = 4,
    parameter NSA_DSP = 4
)(
    input i_clk,
    input s_clk,
    input i_rst,
    input i_trigger_1,
    input [3:0] i_sel,
    input [(N_SA * W_DATA)-1 : 0] i_weight_ff_array_data,
    input [(N_SA * W_DATA)-1 : 0] i_image_ff_array_data,
    input [(N_SA * (W_ADDR + 1))-1 : 0] i_weight_ff_array_occ,
    input [N_SA-1 : 0] i_weight_ff_array_empty,
    input [N_SA-1 : 0] i_weight_ff_array_dv,
    input [(N_SA * ROW)-1 : 0] i_image_ff_array_wren,
    input [(N_SA * COL)-1 : 0] i_psum_array_rden,
    output [(N_SA * COL)-1 : 0] o_north_ff_rden,
    input [3:0] i_image_sel,
    input [4:0] i_psum_sel,
    output [((COL * W_PSUM) * N_SA)-1 : 0] o_psum
    // output [W_PSUM-1 : 0] psum_mux_1,
    // output [W_PSUM-1 : 0] psum_mux_2,
    // output [W_PSUM-1 : 0] psum_mux_3,
    // output [W_PSUM-1 : 0] psum_mux_4,
    // output [W_PSUM-1 : 0] psum_mux_5,
    // output [W_PSUM-1 : 0] psum_mux_6,
    // output [W_PSUM-1 : 0] psum_mux_7,
    // output [W_PSUM-1 : 0] psum_mux_8
);

wire [(N_SA * W_DATA * COL)-1 : 0] mul_engine_weight_ff_array_data;
weight_array_data_mux#(
    .COL(COL),
    .N_SA(N_SA),
    .W_DATA(8)
)north_data(
    .clk(i_clk),
    .i_sel(i_sel),
    .i_data(i_weight_ff_array_data),
    .o_data(mul_engine_weight_ff_array_data)
);

wire [(N_SA * COL)-1 : 0] mul_engine_weight_ff_array_dv;
weight_array_data_mux#(
    .COL(COL),
    .N_SA(N_SA),
    .W_DATA(1)
)north_dv(
    .clk(i_clk),
    .i_sel(i_sel),
    .i_data(i_weight_ff_array_dv),
    .o_data(mul_engine_weight_ff_array_dv)
);

wire [(N_SA * COL)-1 : 0] mul_engine_weight_ff_array_empty;
weight_array_data_mux#(
    .COL(COL),
    .N_SA(N_SA),
    .W_DATA(1)
)north_empty(
    .clk(i_clk),
    .i_sel(i_sel),
    .i_data(i_weight_ff_array_empty),
    .o_data(mul_engine_weight_ff_array_empty)
);

wire [(N_SA * COL * (W_ADDR + 1))-1 : 0] mul_engine_weight_ff_array_occ;
weight_array_data_mux#(
    .COL(COL),
    .N_SA(N_SA),
    .W_DATA(W_ADDR + 1)
)north_occupants(
    .clk(i_clk),
    .i_sel(i_sel),
    .i_data(i_weight_ff_array_occ),
    .o_data(mul_engine_weight_ff_array_occ)
);
/*
wire [(W_DATA * ROW)-1 : 0] mul_engine_image_ff_array_data;
weight_array_data_mux#(
    .COL(ROW),
    .N_SA(N_SA),
    .W_DATA(8)
)west_data(
    .clk(i_clk),
    .i_sel(i_image_sel),
    .i_data(i_image_ff_array_data),
    .o_data(mul_engine_image_ff_array_data)
);*/

mul_engines#(
    .N_SA(N_SA),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .COL(COL),
    .ROW(ROW),
    .W_PSUM(W_PSUM),
    .RAM_DEPTH(RAM_DEPTH),
    .NSA_BOOTH(NSA_BOOTH),
    .NSA_DSP(NSA_DSP)
)(
    .i_clk(i_clk),
    .s_clk(s_clk),
    .i_rst(i_rst),
    .i_trigger_1(i_trigger_1),
    .i_weight_fifo_array_data(mul_engine_weight_ff_array_data),
    .i_weight_fifo_array_dv(mul_engine_weight_ff_array_dv),
    .i_weight_fifo_array_empty(mul_engine_weight_ff_array_empty),
    .i_weight_fifo_array_occupants(mul_engine_weight_ff_array_occ),
    .i_image_fifo_array_data(i_image_ff_array_data),
    .i_image_fifo_array_wren(i_image_ff_array_wren),
    .i_psum_ff_array_read_en(i_psum_array_rden),
    .o_psum_ff_array_partial_sums(o_psum),
    .o_psum_ff_array_empty(),
    .o_psum_ff_array_dv(),
    .o_weight_fifo_array_read_enable(o_north_ff_rden)
);
/*
wire [((COL * W_PSUM) * N_SA)-1 : 0] o_psum;

output_mux#(
    .W_DATA(W_PSUM * N_SA), 
    .W_PSUM(W_PSUM), 
    .N(N_SA)
)psum_mux_1_inst(
    .clk(i_clk),
    .i_sel(i_psum_sel),
    .i_data(o_psum[1215:1064]),
    .o_data(psum_mux_1)
);

output_mux#(
    .W_DATA(W_PSUM * N_SA), 
    .W_PSUM(W_PSUM), 
    .N(N_SA)
)psum_mux_2_inst(
    .clk(i_clk),
    .i_sel(i_psum_sel),
    .i_data(o_psum[1063:912]),
    .o_data(psum_mux_2)
);

output_mux#(
    .W_DATA(W_PSUM * N_SA), 
    .W_PSUM(W_PSUM), 
    .N(N_SA)
)psum_mux_3_inst(
    .clk(i_clk),
    .i_sel(i_psum_sel),
    .i_data(o_psum[911:760]),
    .o_data(psum_mux_3)
);

output_mux#(
    .W_DATA(W_PSUM * N_SA), 
    .W_PSUM(W_PSUM), 
    .N(N_SA)
)psum_mux_4_inst(
    .clk(i_clk),
    .i_sel(i_psum_sel),
    .i_data(o_psum[759:608]),
    .o_data(psum_mux_4)
);

output_mux#(
    .W_DATA(W_PSUM * N_SA), 
    .W_PSUM(W_PSUM), 
    .N(N_SA)
)psum_mux_5_inst(
    .clk(i_clk),
    .i_sel(i_psum_sel),
    .i_data(o_psum[607:456]),
    .o_data(psum_mux_5)
);

output_mux#(
    .W_DATA(W_PSUM * N_SA), 
    .W_PSUM(W_PSUM), 
    .N(N_SA)
)psum_mux_6_inst(
    .clk(i_clk),
    .i_sel(i_psum_sel),
    .i_data(o_psum[455:304]),
    .o_data(psum_mux_6)
);

output_mux#(
    .W_DATA(W_PSUM * N_SA), 
    .W_PSUM(W_PSUM), 
    .N(N_SA)
)psum_mux_7_inst(
    .clk(i_clk),
    .i_sel(i_psum_sel),
    .i_data(o_psum[303:152]),
    .o_data(psum_mux_7)
);

output_mux#(
    .W_DATA(W_PSUM * N_SA), 
    .W_PSUM(W_PSUM), 
    .N(N_SA)
)psum_mux_8_inst(
    .clk(i_clk),
    .i_sel(i_psum_sel),
    .i_data(o_psum[151:0]),
    .o_data(psum_mux_8)
);
*/
endmodule

module output_mux#(parameter W_PSUM = 19, parameter N = 4)(
    input clk,
    input [4:0] i_sel,
    input [(W_PSUM * N)-1 : 0] i_data,
    output reg [W_PSUM-1:0] o_data = 0
);

always @(posedge clk)begin
    if(i_sel == 4'd1)
        o_data = i_data[151:133];
    else if(i_sel == 4'd2)
        o_data <= i_data[132:114];
    else if(i_sel == 4'd3)
        o_data <= i_data[113:95];
    else if(i_sel == 4'd4)
        o_data <= i_data[94:76];
    else if(i_sel == 4'd5)
        o_data <= i_data[75:57];
    else if(i_sel == 4'd6)
        o_data <= i_data[56:38];
    else if(i_sel == 4'd7)
        o_data <= i_data[37:19];
    else if(i_sel == 4'd8)
        o_data <= i_data[18:0];
    else begin
        o_data = 0;
    end
end

endmodule