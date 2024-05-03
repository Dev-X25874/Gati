module res_cnt_top#(
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
    input [3:0] weight_ff_data_sel,
    input [3:0] weight_ff_emp_sel,
    input [3:0] weight_ff_dv_sel,
    input [3:0] weight_ff_occ_sel,
    input [3:0] i_image_sel,
    input [4:0] i_psum_sel,
    input [W_DATA-1 : 0] i_image,
    input [(ROW * N_SA)-1 : 0] i_image_fifo_array_wren,
    input [(N_SA * W_DATA)-1 : 0] i_weight_fifo_array_data,
    input [N_SA-1 : 0] i_weight_fifo_array_emp,
    input [N_SA-1 : 0] i_weight_fifo_array_dv,
    input [(N_SA * (W_ADDR + 1))-1 : 0] i_weight_fifo_array_occ,
    input [(COL * N_SA)-1 : 0] i_psum_fifo_array_rden,
    output [W_PSUM-1 : 0] psum_mux_1,
    output [W_PSUM-1 : 0] psum_mux_2,
    output [W_PSUM-1 : 0] psum_mux_3,
    output [W_PSUM-1 : 0] psum_mux_4,
    output [W_PSUM-1 : 0] psum_mux_5,
    output [W_PSUM-1 : 0] psum_mux_6,
    output [W_PSUM-1 : 0] psum_mux_7,
    output [W_PSUM-1 : 0] psum_mux_8,

    // input [(N_SA * COL)-1 : 0] i_weight_fifo_array_dv,
    // input [(N_SA * COL)-1 : 0] i_weight_fifo_array_empty,
    // input [(N_SA * (COL * (W_ADDR + 1)))-1 : 0] i_weight_fifo_array_occupants,
    // input [( N_SA * W_DATA)-1 : 0] i_image_fifo_array_data,
    // input [(N_SA * ROW)-1 : 0] i_image_fifo_array_wren,
    // input [(COL * N_SA)-1 : 0] i_psum_ff_array_read_en,
    // output [((COL * W_PSUM) * N_SA)-1 : 0] o_psum_ff_array_partial_sums,
    output [(COL * N_SA)-1 : 0] o_psum_ff_array_empty,
    output [(COL * N_SA)-1 : 0] o_psum_ff_array_dv,
    output [(N_SA * COL)-1 : 0] o_weight_fifo_array_read_enable
);

////////////////////////////////////Weight fifo array data////////////////////////////////////
wire [(N_SA * (COL * W_DATA))-1 : 0] engine_weight_fifo_array_data;
assign engine_weight_fifo_array_data = {weight_ff_data_1, weight_ff_data_2, weight_ff_data_3, weight_ff_data_4, weight_ff_data_5, weight_ff_data_6, weight_ff_data_7, weight_ff_data_8};
wire [(COL * W_DATA)-1 : 0] weight_ff_data_1;
input_demux#(
    .W_DATA(W_DATA),
    .COL(COL)
)north_data_1(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_data[7:0]),
    .i_sel(weight_ff_data_sel),
    .o_data(weight_ff_data_1)
);

wire [(COL * W_DATA)-1 : 0] weight_ff_data_2;
input_demux#(
    .W_DATA(W_DATA),
    .COL(COL)
)north_data_2(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_data[15:8]),
    .i_sel(weight_ff_data_sel),
    .o_data(weight_ff_data_2)
);

wire [(COL * W_DATA)-1 : 0] weight_ff_data_3;
input_demux#(
    .W_DATA(W_DATA),
    .COL(COL)
)north_data_3(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_data[23:16]),
    .i_sel(weight_ff_data_sel),
    .o_data(weight_ff_data_3)
);

wire [(COL * W_DATA)-1 : 0] weight_ff_data_4;
input_demux#(
    .W_DATA(W_DATA),
    .COL(COL)
)north_data_4(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_data[31:24]),
    .i_sel(weight_ff_data_sel),
    .o_data(weight_ff_data_4)
);

wire [(COL * W_DATA)-1 : 0] weight_ff_data_5;
input_demux#(
    .W_DATA(W_DATA),
    .COL(COL)
)north_data_5(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_data[39:32]),
    .i_sel(weight_ff_data_sel),
    .o_data(weight_ff_data_5)
);

wire [(COL * W_DATA)-1 : 0] weight_ff_data_6;
input_demux#(
    .W_DATA(W_DATA),
    .COL(COL)
)north_data_6(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_data[47:40]),
    .i_sel(weight_ff_data_sel),
    .o_data(weight_ff_data_6)
);

wire [(COL * W_DATA)-1 : 0] weight_ff_data_7;
input_demux#(
    .W_DATA(W_DATA),
    .COL(COL)
)north_data_7(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_data[55:48]),
    .i_sel(weight_ff_data_sel),
    .o_data(weight_ff_data_7)
);

wire [(COL * W_DATA)-1 : 0] weight_ff_data_8;
input_demux#(
    .W_DATA(W_DATA),
    .COL(COL)
)north_data_8(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_data[63:55]),
    .i_sel(weight_ff_data_sel),
    .o_data(weight_ff_data_8)
);

////////////////////////////////////Weight fifo array data valid///////////////////////////////////
wire [(N_SA * COL)-1 : 0] engine_weight_fifo_array_dv;
assign engine_weight_fifo_array_dv = {weight_ff_dv_1, weight_ff_dv_2, weight_ff_dv_3, weight_ff_dv_4, weight_ff_dv_5, weight_ff_dv_6, weight_ff_dv_7, weight_ff_dv_8};
wire [COL-1 : 0] weight_ff_dv_1;
input_demux#(
    .W_DATA(1),
    .COL(COL)
)north_dv_1(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_dv[0]),
    .i_sel(weight_ff_dv_sel),
    .o_data(weight_ff_dv_1)
);

wire [COL-1 : 0] weight_ff_dv_2;
input_demux#(
    .W_DATA(1),
    .COL(COL)
)north_dv_2(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_dv[1]),
    .i_sel(weight_ff_dv_sel),
    .o_data(weight_ff_dv_2)
);

wire [COL-1 : 0] weight_ff_dv_3;
input_demux#(
    .W_DATA(1),
    .COL(COL)
)north_dv_3(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_dv[2]),
    .i_sel(weight_ff_dv_sel),
    .o_data(weight_ff_dv_3)
);

wire [COL-1 : 0] weight_ff_dv_4;
input_demux#(
    .W_DATA(1),
    .COL(COL)
)north_dv_4(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_dv[3]),
    .i_sel(weight_ff_dv_sel),
    .o_data(weight_ff_dv_4)
);

wire [COL-1 : 0] weight_ff_dv_5;
input_demux#(
    .W_DATA(1),
    .COL(COL)
)north_dv_5(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_dv[4]),
    .i_sel(weight_ff_dv_sel),
    .o_data(weight_ff_dv_5)
);

wire [COL-1 : 0] weight_ff_dv_6;
input_demux#(
    .W_DATA(1),
    .COL(COL)
)north_dv_6(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_dv[5]),
    .i_sel(weight_ff_dv_sel),
    .o_data(weight_ff_dv_6)
);

wire [COL-1 : 0] weight_ff_dv_7;
input_demux#(
    .W_DATA(1),
    .COL(COL)
)north_dv_7(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_dv[6]),
    .i_sel(weight_ff_dv_sel),
    .o_data(weight_ff_dv_7)
);

wire [COL-1 : 0] weight_ff_dv_8;
input_demux#(
    .W_DATA(1),
    .COL(COL)
)north_dv_8(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_dv[7]),
    .i_sel(weight_ff_dv_sel),
    .o_data(weight_ff_dv_8)
);

////////////////////////////////////Weight fifo array empty///////////////////////////////////
wire [(N_SA * COL)-1 : 0] engine_weight_fifo_array_empty;
assign engine_weight_fifo_array_empty = {weight_ff_emp_1, weight_ff_emp_2, weight_ff_emp_3, weight_ff_emp_4, weight_ff_emp_5, weight_ff_emp_6, weight_ff_emp_7, weight_ff_emp_8};
wire [COL-1 : 0] weight_ff_emp_1;
input_demux#(
    .W_DATA(1),
    .COL(COL)
)north_emp_1(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_emp[0]),
    .i_sel(weight_ff_emp_sel),
    .o_data(weight_ff_emp_1)
);

wire [COL-1 : 0] weight_ff_emp_2;
input_demux#(
    .W_DATA(1),
    .COL(COL)
)north_emp_2(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_emp[1]),
    .i_sel(weight_ff_emp_sel),
    .o_data(weight_ff_emp_2)
);

wire [COL-1 : 0] weight_ff_emp_3;
input_demux#(
    .W_DATA(1),
    .COL(COL)
)north_emp_3(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_emp[2]),
    .i_sel(weight_ff_emp_sel),
    .o_data(weight_ff_emp_3)
);

wire [COL-1 : 0] weight_ff_emp_4;
input_demux#(
    .W_DATA(1),
    .COL(COL)
)north_emp_4(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_emp[3]),
    .i_sel(weight_ff_emp_sel),
    .o_data(weight_ff_emp_4)
);

wire [COL-1 : 0] weight_ff_emp_5;
input_demux#(
    .W_DATA(1),
    .COL(COL)
)north_emp_5(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_emp[4]),
    .i_sel(weight_ff_emp_sel),
    .o_data(weight_ff_emp_5)
);

wire [COL-1 : 0] weight_ff_emp_6;
input_demux#(
    .W_DATA(1),
    .COL(COL)
)north_emp_6(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_emp[5]),
    .i_sel(weight_ff_emp_sel),
    .o_data(weight_ff_emp_6)
);

wire [COL-1 : 0] weight_ff_emp_7;
input_demux#(
    .W_DATA(1),
    .COL(COL)
)north_emp_7(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_emp[6]),
    .i_sel(weight_ff_emp_sel),
    .o_data(weight_ff_emp_7)
);

wire [COL-1 : 0] weight_ff_emp_8;
input_demux#(
    .W_DATA(1),
    .COL(COL)
)north_emp_8(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_emp[7]),
    .i_sel(weight_ff_emp_sel),
    .o_data(weight_ff_emp_8)
);

////////////////////////////////////Weight fifo array occupants///////////////////////////////////
wire [(N_SA * COL * (W_ADDR + 1))-1 : 0] engine_weight_fifo_array_occ;
assign engine_weight_fifo_array_occ = {weight_ff_occ_1, weight_ff_occ_2, weight_ff_occ_3, weight_ff_occ_4, weight_ff_occ_5, weight_ff_occ_6, weight_ff_occ_7, weight_ff_occ_8};
wire [((W_ADDR + 1) * COL)-1 : 0] weight_ff_occ_1;
input_demux#(
    .W_DATA(10),
    .COL(COL)
)north_occ_1(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_occ[9:0]),
    .i_sel(weight_ff_occ_sel),
    .o_data(weight_ff_occ_1)
);

wire [((W_ADDR + 1) * COL)-1 : 0] weight_ff_occ_2;
input_demux#(
    .W_DATA(10),
    .COL(COL)
)north_occ_2(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_occ[19:10]),
    .i_sel(weight_ff_occ_sel),
    .o_data(weight_ff_occ_2)
);

wire [((W_ADDR + 1) * COL)-1 : 0] weight_ff_occ_3;
input_demux#(
    .W_DATA(10),
    .COL(COL)
)north_occ_3(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_occ[29:20]),
    .i_sel(weight_ff_occ_sel),
    .o_data(weight_ff_occ_3)
);

wire [((W_ADDR + 1) * COL)-1 : 0] weight_ff_occ_4;
input_demux#(
    .W_DATA(10),
    .COL(COL)
)north_occ_4(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_occ[39:30]),
    .i_sel(weight_ff_occ_sel),
    .o_data(weight_ff_occ_4)
);

wire [((W_ADDR + 1) * COL)-1 : 0] weight_ff_occ_5;
input_demux#(
    .W_DATA(10),
    .COL(COL)
)north_occ_5(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_occ[49:40]),
    .i_sel(weight_ff_occ_sel),
    .o_data(weight_ff_occ_5)
);

wire [((W_ADDR + 1) * COL)-1 : 0] weight_ff_occ_6;
input_demux#(
    .W_DATA(10),
    .COL(COL)
)north_occ_6(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_occ[59:50]),
    .i_sel(weight_ff_occ_sel),
    .o_data(weight_ff_occ_6)
);

wire [((W_ADDR + 1) * COL)-1 : 0] weight_ff_occ_7;
input_demux#(
    .W_DATA(10),
    .COL(COL)
)north_occ_7(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_occ[69:60]),
    .i_sel(weight_ff_occ_sel),
    .o_data(weight_ff_occ_7)
);

wire [((W_ADDR + 1) * COL)-1 : 0] weight_ff_occ_8;
input_demux#(
    .W_DATA(10),
    .COL(COL)
)north_occ_8(
    .clk(i_clk),
    .i_data(i_weight_fifo_array_occ[79:70]),
    .i_sel(weight_ff_occ_sel),
    .o_data(weight_ff_occ_8)
);

////////////////////////////////////Multiple systolic array instances///////////////////////////////////
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
)sa_enginges_inst (
    .i_clk(i_clk),
    .s_clk(s_clk),
    .i_rst(i_rst),
    .i_trigger_1(i_trigger_1),
    .i_weight_fifo_array_data(engine_weight_fifo_array_data),
    .i_weight_fifo_array_dv(engine_weight_fifo_array_dv),
    .i_weight_fifo_array_empty(engine_weight_fifo_array_empty),
    .i_weight_fifo_array_occupants(engine_weight_fifo_array_occ),
    .i_image_fifo_array_data(image_fifo_array),
    .i_image_fifo_array_wren(i_image_fifo_array_wren),
    .o_psum_ff_array_partial_sums(o_psum),
    .i_psum_ff_array_read_en(i_psum_fifo_array_rden),

    .o_psum_ff_array_empty(o_psum_ff_array_empty),
    .o_psum_ff_array_dv(o_psum_ff_array_dv),
    .o_weight_fifo_array_read_enable(o_weight_fifo_array_read_enable)
);

////////////////////////////////////Image fifo array data///////////////////////////////////

input_demux#(
    .W_DATA(W_DATA),
    .COL(ROW)
)image_demux(
    .clk(i_clk),
    .i_data(i_image),
    .i_sel(i_image_sel),
    .o_data(image_fifo_array)
);

wire [(N_SA * W_DATA)-1 : 0] image_fifo_array;

////////////////////////////////////Partial sum fifo array data///////////////////////////////////
wire [((COL * W_PSUM) * N_SA)-1 : 0] o_psum;
output_mux#(
    .W_PSUM(W_PSUM), 
    .N(COL)
)psum_mux_1_inst(
    .clk(i_clk),
    .i_sel(i_psum_sel),
    .i_data(o_psum[1215:1064]),
    .o_data(psum_mux_1)
);

output_mux#( 
    .W_PSUM(W_PSUM), 
    .N(COL)
)psum_mux_2_inst(
    .clk(i_clk),
    .i_sel(i_psum_sel),
    .i_data(o_psum[1063:912]),
    .o_data(psum_mux_2)
);

output_mux#( 
    .W_PSUM(W_PSUM), 
    .N(COL)
)psum_mux_3_inst(
    .clk(i_clk),
    .i_sel(i_psum_sel),
    .i_data(o_psum[911:760]),
    .o_data(psum_mux_3)
);

output_mux#(
    .W_PSUM(W_PSUM), 
    .N(COL)
)psum_mux_4_inst(
    .clk(i_clk),
    .i_sel(i_psum_sel),
    .i_data(o_psum[759:608]),
    .o_data(psum_mux_4)
);

output_mux#(
    .W_PSUM(W_PSUM), 
    .N(COL)
)psum_mux_5_inst(
    .clk(i_clk),
    .i_sel(i_psum_sel),
    .i_data(o_psum[607:456]),
    .o_data(psum_mux_5)
);

output_mux#(
    .W_PSUM(W_PSUM), 
    .N(COL)
)psum_mux_6_inst(
    .clk(i_clk),
    .i_sel(i_psum_sel),
    .i_data(o_psum[455:304]),
    .o_data(psum_mux_6)
);

output_mux#(
    .W_PSUM(W_PSUM), 
    .N(COL)
)psum_mux_7_inst(
    .clk(i_clk),
    .i_sel(i_psum_sel),
    .i_data(o_psum[303:152]),
    .o_data(psum_mux_7)
);

output_mux#(
    .W_PSUM(W_PSUM), 
    .N(COL)
)psum_mux_8_inst(
    .clk(i_clk),
    .i_sel(i_psum_sel),
    .i_data(o_psum[151:0]),
    .o_data(psum_mux_8)
);

////////////////////////////////////Partial sum fifo array rden///////////////////////////////////
    
endmodule