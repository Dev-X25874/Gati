/*
    Uart-to-uart flow of a single SA engine
*/
module sa_engine_dsp#(
    parameter W_DATA = 8,
    parameter W_ADDR = 8,
    parameter COL = 4,
    parameter ROW = 9,
    parameter W_PSUM = 19,
    parameter N_SA = 4,
    parameter RAM_DEPTH = (1 << W_ADDR)
)(
    input i_clk,
    input s_clk,
    input i_rstn,
    input i_trigger_1,
    input [W_DATA-1 : 0] i_weight_fifo_array_data,
    input [COL-1 : 0] i_weight_fifo_array_write_en,
    input [W_DATA-1 : 0] i_image_fifo_array_data,
    input [ROW-1 : 0] i_image_fifo_array_wren,
    input [COL-1 : 0] i_psum_ff_array_read_en,
    output [(W_PSUM * COL)-1 : 0] o_psum_ff_array_partial_sums,
    output [COL-1 : 0] o_psum_ff_array_empty,
    output [COL-1 : 0] o_psum_ff_array_dv
);

wire [COL-1 : 0] read_rden_ctrl_weight_ff_array;
wire [COL-1 : 0] dv_weight_ff_array_append_dv;
wire [COL-1 : 0] empty_weight_ff_array_rden_ctrl;
wire [(COL * W_DATA)-1 : 0] data_weight_ff_array_append_dv;
wire [((W_ADDR + 1) * COL)-1 : 0] occ_weight_ff_array_rden_ctrl;

/*
    Each fifo in this array stores its corrosponding column's weights
    before loading it into PE blocks 
*/
fifo_array#(
    .DIMENSION(COL),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(RAM_DEPTH)
) sa_engine_weight_fifo_array (
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .i_data(i_weight_fifo_array_data),
    .i_read_enable(read_rden_ctrl_weight_ff_array),
    .i_write_enable(i_weight_fifo_array_write_en),
    .o_data(data_weight_ff_array_append_dv),
    .o_fifo_empty(empty_weight_ff_array_rden_ctrl),
    .o_fifo_full(),
    .o_fifo_dv(dv_weight_ff_array_append_dv),
    .o_occupants(occ_weight_ff_array_rden_ctrl)
);

wire [(COL * (W_DATA + 1))-1 : 0] weights_append_dv_cdc;
//Appends data valid with weights before sending it into PE blocks
append_dv#(
    .N_DIMENSION(COL),
    .W_DATA(W_DATA)
)weight_fifo_array_dv(
    .i_data(data_weight_ff_array_append_dv),
    .i_data_valid(dv_weight_ff_array_append_dv),
    .o_data(weights_append_dv_cdc)
);

wire enb_weight_rden_ctrl_image_rden_ctrl;
//Control read enable signal of uart_rx_weight_fifo
weight_fifo_aray_rden#(
   .COL(COL),
   .ROW(ROW),
   .W_ADDR(W_ADDR),
   .W_DATA(W_DATA)
) weight_fifo_array_rden_ctrl (
   .i_clk(i_clk),
   .i_rstn(i_rstn),
   .i_trigger(i_trigger_1),
   .image_read_ctrl_enable(enb_weight_rden_ctrl_image_rden_ctrl),
   .i_fifo_empty(empty_weight_ff_array_rden_ctrl),
   .o_fifo_read_enable(read_rden_ctrl_weight_ff_array),
   .i_fifo_occupants(occ_weight_ff_array_rden_ctrl)
);

wire [ROW-1 : 0] read_rden_ctrl_image_ff_array;
wire [ROW-1 : 0] empty_image_ff_array_rden_ctrl;
wire[(ROW * W_DATA)-1 : 0] data_image_ff_array_append_dv;
wire [ROW-1:0] dv_image_ff_array_append_dv;
wire [(((W_ADDR + 1) * ROW) -1): 0] occ_image_ff_array_rden_ctrl;
/*
    Each fifo in this array stores its corrosponding row's image 
    before sending it to delay registers
*/
fifo_array#(
    .DIMENSION(ROW),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(RAM_DEPTH)
) sa_engine_image_fifo_array (
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .i_data(i_image_fifo_array_data),
    .i_write_enable(i_image_fifo_array_wren),
    .i_read_enable(read_rden_ctrl_image_ff_array),
    .o_data(data_image_ff_array_append_dv),
    .o_fifo_empty(empty_image_ff_array_rden_ctrl),
    .o_fifo_full(),
    .o_fifo_dv(dv_image_ff_array_append_dv),
    .o_occupants(occ_image_ff_array_rden_ctrl)
);
//Appends data valid signal with image before sending it to delay registers
append_dv#(
    .N_DIMENSION(ROW),
    .W_DATA(W_DATA)
) image_fifo_array_dv (
    .i_data(data_image_ff_array_append_dv),
    .i_data_valid(dv_image_ff_array_append_dv),
    .o_data(image_append_dv_cdc)
);
wire [((W_DATA + 1) * ROW)-1 : 0] image_append_dv_cdc;
//Control read enable signal of uart_rx_image_fifo
image_fifo_array_rden#(
    .ROW(ROW),
    .W_ADDR(W_ADDR),
    .W_DATA(W_DATA)
) image_fifo_array_rden_ctrl (
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .i_occupants(occ_image_ff_array_rden_ctrl),
    .i_trigger(enb_weight_rden_ctrl_image_rden_ctrl),
    .i_fifo_empty(empty_image_ff_array_rden_ctrl),
    .o_read_enable(read_rden_ctrl_image_ff_array)
);
//synchronizers for CDC, receives weights and image from weight & image fifo array respectively
(* async_reg = "true" *) reg [(COL * (W_DATA + 1))-1 : 0] weight_reg = 0;
(* async_reg = "true" *) reg [(COL * (W_DATA + 1))-1 : 0] weights_cdc_sa = 0;
(* async_reg = "true" *) reg [(ROW * (W_DATA + 1))-1 : 0] image_reg = 0;
(* async_reg = "true" *) reg [(ROW * (W_DATA + 1))-1 : 0] image_cdc_sa = 0;
always @(posedge s_clk)
begin 
    weight_reg <= weights_append_dv_cdc;
    weights_cdc_sa <= weight_reg;
    
    image_reg <= image_append_dv_cdc;
    image_cdc_sa <= image_reg;
end
wire [(ROW * (W_DATA + 1)) - 1 : 0] image_delay_reg_dsp_pe;
//Provides delay to image before loading it into PE grid
delay_reg #(
    .ROW(ROW),
    .W_DATA(W_DATA)
) sa_image_delay_registers (
    .in_clk(s_clk),
    .i_rstn(i_rstn),
    .in_west(image_cdc_sa),
    .pe_grid_image(image_delay_reg_dsp_pe)
);
wire  [((W_PSUM + 1) * COL)-1 : 0] partial_sums_sa_cdc;
//PE grid using DSP blocks as multipliers
dsp_pe_grid#(
    .COL(COL),
    .ROW(ROW),
    .W_DATA(W_DATA),
    .W_PSUM(W_PSUM)
) dsp_sa_block (
    .i_clk(s_clk),
    .i_rstn(i_rstn),
    .i_weight(weights_cdc_sa),
    .in_data(image_delay_reg_dsp_pe),
    .o_partial_sum(partial_sums_sa_cdc),
    .o_data() 
);
//synchronizers for CDC, receive partial sums from PE grid
(* async_reg = "true" *) reg [(COL * (W_PSUM + 1))-1 : 0] psum_reg = 0;
(* async_reg = "true" *) reg [(COL * (W_PSUM + 1))-1 : 0] partial_sums_cdc_seperate_dv = 0;
always@(posedge i_clk)
begin 
    psum_reg <= partial_sums_sa_cdc;
    partial_sums_cdc_seperate_dv <= psum_reg;
end
wire [(COL * W_PSUM)-1 : 0] psum_seperate_dv_psum_ff_array;
wire [COL-1 : 0] dv_seperate_dv_psum_ff_array;
//Seperated data valid signal from partial sums output coming out of each column of PE grid
seperate_psum_dv#(
    .COL(COL),
    .W_PSUM(W_PSUM)
) partial_sum_dv (
    .in_data(partial_sums_cdc_seperate_dv),
    .out_data(psum_seperate_dv_psum_ff_array),
    .out_data_valid(dv_seperate_dv_psum_ff_array)
);
/*
    Each fifo in this array stores its corrosponding column's partial sums after
    receiving it from PE blocks 
*/
psum_fifo_array#(
    .COL(COL),
    .W_DATA(W_PSUM),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(RAM_DEPTH)
) partial_sum_array (
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .i_data(psum_seperate_dv_psum_ff_array),
    .i_write_enable(dv_seperate_dv_psum_ff_array),
    .i_read_enable(i_psum_ff_array_read_en),
    .o_data(o_psum_ff_array_partial_sums),
    .o_fifo_empty(o_psum_ff_array_empty),
    .o_data_valid(o_psum_ff_array_dv)
);
endmodule