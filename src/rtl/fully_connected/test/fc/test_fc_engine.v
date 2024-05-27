//top module for single fc engine
module test_fc_engine#(
    parameter W_DATA = 8,
    parameter COL = 4,
    parameter ROW = 1,
    parameter W_PSUM = 19,
    parameter W_ACC = 32,
    parameter W_IMG_DIM = 15,
    parameter WEIGHT_FF_DEPTH = 512,
    parameter IMAGE_FF_DEPTH = 512
)(
    input i_clk,
    input s_clk,
    input i_rstn,
    input i_trigger_1,
    input [W_IMG_DIM-1 : 0] i_img_dim,
    input [W_DATA-1 : 0] i_weight_ff_array_data,
    input [COL-1 : 0] i_weight_ff_array_wren,
    input [W_DATA-1 : 0] i_image_ff_array_data,
    input [ROW-1 : 0] i_image_ff_array_empty,
    input [(ROW * (IMG_FF_ADDR + 1))-1 : 0] i_image_ff_array_occ,
    output [ROW-1 : 0] o_image_ff_array_rden,
    input i_image_ff_array_dv,
    output [COL-1 : 0] o_acc_data_valid,
    output [(COL * W_ACC)-1 : 0] o_acc_data
);

localparam IMG_FF_ADDR = $clog2(IMAGE_FF_DEPTH);
localparam WEIGHT_FF_ADDR = $clog2(WEIGHT_FF_DEPTH);

wire [COL-1 : 0] rden_weight_ff_array_ctrl;
wire [COL-1 : 0] valid_weight_ff_array_append_dv;
wire [COL-1 : 0] empty_weight_ff_array_rden_ctrl;
wire [(COL * W_DATA)-1 : 0] data_weight_ff_array_append_dv;
wire [((WEIGHT_FF_ADDR + 1) * COL)-1 : 0] occ_weight_ff_array_rden_ctrl;

//array of fifo to store weights before loading them into PE blocks
weight_ff_array#(
    .COL(COL),
    .ROW(ROW),
    .W_DATA(W_DATA),
    .W_ADDR(WEIGHT_FF_ADDR),
    .RAM_DEPTH(WEIGHT_FF_DEPTH)
)weight_fifo_array(
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .i_data(i_weight_ff_array_data),
    .i_read_enable(rden_weight_ff_array_ctrl),
    .i_write_enable(i_weight_ff_array_wren),
    .o_data(data_weight_ff_array_append_dv),
    .o_fifo_empty(empty_weight_ff_array_rden_ctrl),
    .o_fifo_full(),
    .o_fifo_dv(valid_weight_ff_array_append_dv),
    .o_occupants(occ_weight_ff_array_rden_ctrl)
);

wire [(COL * (W_DATA + 1))-1 : 0] weight_ff_array_synch;

//appends valid signal along with the weights coming from weight fifo array
append_dv#(
    .N_DIMENSION(COL),
    .W_DATA(W_DATA)
)weight_ff_array_dv(
    .i_data(data_weight_ff_array_append_dv),
    .i_data_valid(valid_weight_ff_array_append_dv),
    .o_data(weight_ff_array_synch)
);

//handles read enable signal of all the weight and image fifo
rden_controller#(
    .COL(COL),
    .ROW(ROW),
    .W_IMG_DIM(W_IMG_DIM),
    .WEIGHT_FF_ADDR(WEIGHT_FF_ADDR),
    .IMAGE_FF_ADDR(IMG_FF_ADDR)
)fifo_read_enable(
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .i_trigger(i_trigger_1),
    .i_weight_ff_array_empty(empty_weight_ff_array_rden_ctrl),
    .i_image_ff_array_empty(i_image_ff_array_empty),
    .i_weight_ff_array_occ(occ_weight_ff_array_rden_ctrl),
    .i_image_ff_array_occ(i_image_ff_array_occ),
    .i_img_dim(i_img_dim),
    .o_weight_ff_array_rden(rden_weight_ff_array_ctrl),
    .o_image_ff_array_rden(o_image_ff_array_rden)
);

//appends valid signal along with the image coming from image fifo 
append_dv#(
    .N_DIMENSION(ROW), 
    .W_DATA(W_DATA)
)image_ff__array_dv(
    .i_data(i_image_ff_array_data),
    .i_data_valid(i_image_ff_array_dv),
    .o_data(image_ff_array_synch)
);

wire [((W_DATA + 1) * ROW)-1 : 0] image_ff_array_synch;

//synchronizers for CDC
(* async_reg = "true" *) reg [(COL * (W_DATA + 1))-1 : 0] r_weights=0;
(* async_reg = "true" *) reg [(COL * (W_DATA + 1))-1 : 0] pe_weights=0;
(* async_reg = "true" *) reg [(ROW * (W_DATA + 1))-1 : 0] r_image=0;
(* async_reg = "true" *) reg [(ROW * (W_DATA + 1))-1 : 0] pe_image=0;
always @(posedge s_clk)
begin 
    r_weights  <= weight_ff_array_synch;
    pe_weights <= r_weights;
    r_image    <= image_ff_array_synch;
    pe_image   <= r_image;
end

wire  [((W_PSUM + 1) * COL)-1 : 0] psum_pe_grid_acc;

//grid of PE blocks
dsp_pe_grid#(
    .COL(COL),
    .ROW(ROW),
    .W_DATA(W_DATA),
    .W_PSUM(W_PSUM)
)fc_pe_block(
    .i_clk(s_clk),
    .i_rstn(i_rstn),
    .i_weight(pe_weights),
    .in_data(pe_image),
    .o_partial_sum(psum_pe_grid_acc),
    .o_data() 
);

wire [COL-1 : 0] valid_acc_synch;
wire [(COL * W_ACC)-1 : 0] data_acc_synch;

//accumulates outputs of PE blocks
accumulator#(
    .COL(COL),
    .W_ACC(W_ACC),
    .W_IMG_DIM(W_IMG_DIM),
    .W_PSUM(W_PSUM)
)accumulator_array(
    .i_clk(s_clk),
    .i_rstn(i_rstn),
    .i_img_dim(i_img_dim),
    .i_psum_data(psum_pe_grid_acc),
    .o_dv(valid_acc_synch),
    .o_data(data_acc_synch)
);

//synchronizers for CDC
(*async_reg = "true" *) reg [COL-1 : 0] r_acc_valid = 0;
(*async_reg = "true" *) reg [COL-1 : 0] o_acc_data_valid = 0;
(*async_reg = "true" *) reg [(COL * W_ACC)-1 : 0] r_acc_data = 0;
(*async_reg = "true" *) reg [(COL * W_ACC)-1 : 0] o_acc_data = 0;

always @(posedge i_clk)begin
    r_acc_valid      <= valid_acc_synch;
    o_acc_data_valid <= r_acc_valid;
    r_acc_data       <= data_acc_synch;
    o_acc_data       <= r_acc_data;
end

endmodule