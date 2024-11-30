//top module for single fc engine
module top_fc#(
    parameter W_DATA = 8,
    parameter COL = 32,
    parameter ROW = 1,
    parameter W_KERNAL_CNT = 10,
    parameter W_PSUM = 19,
    parameter N_SA = 1,
    parameter W_ACC = 32,
    parameter W_IMG_DIM = 15,
    parameter WEIGHT_FF_DEPTH = 512,
    parameter IMAGE_FF_DEPTH = 512
)(
    input                                       i_clk,
    input                                       s_clk,
    input                                       i_rstn,
    input                                       i_sel_fifo_sharing_mux, //select signal coming from fifo sharing, indicates whether to load weights into SA or FC
    input                                       i_image_data_valid,     //data valid signal of image, comes from output mux in flattening
    input                                       i_weight_rden_trigger,  //signal to start loading weights  
    input  [W_IMG_DIM-1 : 0]                    i_img_dim,              //comes from config block
    input  [(COL * W_DATA)-1 : 0]               i_weight_ff_array_data,
    input  [COL-1 : 0]                          i_weight_ff_array_dv,
    input  [COL-1 : 0]                          i_weight_ff_array_empty,
    input  [COL-1 : 0]                          i_weight_ff_array_almost_empty,
    input  [(COL * (WEIGHT_FF_ADDR + 1))-1 : 0] i_weight_ff_array_occ,
    input  [W_DATA-1 : 0]                       i_image_data,
    input  [W_KERNAL_CNT-1 : 0]                 i_kernal_count,
    output [COL-1 : 0]                          o_weight_ff_array_rden,
    // output [ROW-1 : 0]                          o_image_ff_array_rden,
    output [(COL * N_SA)-1 : 0]                 accumulator_dv,
    output [((COL * W_ACC) * N_SA)-1 : 0]       accumulator_data
);

localparam WEIGHT_FF_ADDR = $clog2(WEIGHT_FF_DEPTH);
	assign accumulator_data=r_accumulator_data;
	assign accumulator_dv=r_accumulator_dv;
wire [(COL * (W_DATA + 1))-1 : 0] weights_ff_array_synch;   //weights going into synchronizers

//along with the data coming from weight fifo array, append it's data valid signal
append_dv#(
    .N_DIMENSION(COL), 
    .W_DATA(W_DATA)
)weight_array_dv_append(
    .i_data(i_weight_ff_array_data),
    .i_data_valid(i_weight_ff_array_dv),
    .o_data(weights_ff_array_synch)
);

//weight fifo array read enable controller
weight_ff_rden#(
    .COL(COL),
    .ROW(ROW),
    .W_IMG_DIM(W_IMG_DIM),
    .W_KERNAL_CNT(W_KERNAL_CNT),
    .WEIGHT_FF_DEPTH(WEIGHT_FF_DEPTH)
)weight_fifo_array_read_en_controller(
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .i_trigger(i_weight_rden_trigger),                            
    .i_sel_mux(i_sel_fifo_sharing_mux),
    .i_kernal_count(i_kernal_count),
    .i_accumulator_valid(&(r_accumulator_dv)),
    .i_north_empty(i_weight_ff_array_empty),
    .i_north_almost_empty(i_weight_ff_array_almost_empty),
    .i_north_occ(i_weight_ff_array_occ),
    .i_img_dim(i_img_dim),
    .o_north_rden(o_weight_ff_array_rden)
);

//along with the data coming from image fifo array, append it's data valid signal
append_dv#(
    .N_DIMENSION(ROW), 
    .W_DATA(W_DATA)
)image_array_dv_append(
    .i_data(i_image_data),
    .i_data_valid(i_image_data_valid),
    .o_data(image_ff_array_synch)
);

wire [((W_DATA + 1) * ROW)-1 : 0] image_ff_array_synch;     //image going into synchronizers

//synchronizers for CDC
(* async_reg = "true" *) reg [(COL * (W_DATA + 1))-1 : 0] r_weights = 0;
(* async_reg = "true" *) reg [(COL * (W_DATA + 1))-1 : 0] pe_weights = 0;
(* async_reg = "true" *) reg [(ROW * (W_DATA + 1))-1 : 0] r_image = 0;
(* async_reg = "true" *) reg [(ROW * (W_DATA + 1))-1 : 0] pe_image = 0;
always @(posedge s_clk)
begin 
    r_weights  <= weights_ff_array_synch;
    pe_weights <= r_weights;
    r_image    <= image_ff_array_synch;
    pe_image   <= r_image;
end

wire  [((W_PSUM + 1) * COL)-1 : 0] out_south_data;

//grid of processing elements using DSP blocks for multiplication operation
dsp_pe_grid#(
    .COL(COL),
    .ROW(ROW),
    .W_DATA(W_DATA),
    .W_PSUM(W_PSUM)
)pe_blocks(
    .i_clk(s_clk),
    .i_rstn(i_rstn),
    .i_weight(pe_weights),
    .in_data(pe_image),
    .o_partial_sum(out_south_data),
    .o_data() 
);

wire [(COL * N_SA)-1 : 0] o_acc_dv;
wire [((COL * W_ACC) * N_SA)-1 : 0] o_acc_data;

//accumulates output of PE blocks
accumulator#(
    .COL(COL),
    .W_ACC(W_ACC),
    .W_PSUM(W_PSUM),
    .W_IMG_DIM(W_IMG_DIM)
)accumulator_array(
    .i_clk(s_clk),
    .i_rstn(i_rstn),
    .i_img_dim(i_img_dim),
    .i_psum_data(out_south_data),
    .o_dv(o_acc_dv),
    .o_data(o_acc_data)
);

//synchronizers for CDC
(*async_reg = "true" *) reg [(COL * N_SA)-1 : 0] r_acc_dv = 0;
(*async_reg = "true" *) reg [(COL * N_SA)-1 : 0] r_accumulator_dv = 0;
(*async_reg = "true" *) reg [((COL * W_ACC) * N_SA)-1 : 0] r_acc_data = 0;
(*async_reg = "true" *) reg [((COL * W_ACC) * N_SA)-1 : 0] r_accumulator_data = 0;

always @(posedge i_clk)begin
    r_acc_dv         <= o_acc_dv;
    r_accumulator_dv   <= r_acc_dv;
    r_acc_data       <= o_acc_data;
    r_accumulator_data <= r_acc_data;
end

endmodule
