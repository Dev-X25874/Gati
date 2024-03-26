module top#(
    parameter N_SA = (NSA_DSP + NSA_BOOTH),
    parameter W_DATA = 8,
    parameter W_ADDR = 8,
    parameter COL = 4,
    parameter ROW = 9,
    parameter W_PSUM = 19,
    parameter RAM_DEPTH = (1 << W_ADDR),
    parameter NSA_DSP = 2,
    parameter NSA_BOOTH = 2
)(
    input i_clk,
    input s_clk,
    input in_rst,
    input [N_SA-1 : 0] i_rx_serial,
    input i_trigger_1,
    input i_weight_ff_sel,
    input i_image_ff_sel,
    output [N_SA-1 : 0] o_tx_serial
);

/*
    The signals i_weight_ff_sel, i_image_ff_Sel, i_trigger_1, and i_trigger_2 
    are mapped to GPIOs that are connected to LEDs on the board, so they are all
    configured for weak pullup, which causes their inverted values to be sent into the blocks. 
    However, the inversion of these inputs should be removed if these signals are mapped to any other GPIOs.
*/
wire weight_ff_sel;
assign weight_ff_sel = ~i_weight_ff_sel;
wire image_ff_sel;
assign image_ff_sel = ~i_image_ff_sel;
wire trigg1;
assign trigg1 = ~i_trigger_1;
wire i_rst;
assign i_rst = ~in_rst;
wire [N_SA-1 : 0] rx_dv;
wire [(N_SA * W_DATA)-1 : 0] rx_byte;

//multiple uart receivers, one for each SA engine
uart_rx#(
    .W_DATA(W_DATA),
    .N_SA(N_SA)
) multiple_uart_rx (  
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_rx_serial(i_rx_serial),
    .o_rx_dv(rx_dv),
    .o_rx_byte(rx_byte)
);

wire [N_SA-1 : 0] write_wren_ctrl_rx_weight_ff_array;

//assert write enable signal of uart_rx_weight_fifo
uart_rx_ff_array_wren#(
    .N_SA(N_SA)
)uart_rx_weight_fifo_wren(
    .i_dv(rx_dv),
    .i_sel(weight_ff_sel),
    .i_rst(i_rst),
    .o_wren(write_wren_ctrl_rx_weight_ff_array)
);
wire [N_SA-1 : 0] empty_rx_weight_ff_array_rden_ctrl;
wire [N_SA-1 : 0] read_rden_ctrl_rx_north_ff_array;
wire [N_SA-1 : 0] dv_rx_weight_ff_array_wren_ctrl;
wire [(N_SA * W_DATA)-1 : 0] data_rx_weight_ff_array_wren_ctrl;
wire [(N_SA * (W_ADDR + 1))-1 : 0] occ_rx_weight_ff_array_rden_ctrl;

/*
    Creates a N_SA number of fifo for N_SA SA engines to load 
    and save atleast (ROW * COL) number of weights in each engine
*/
mul_fifo#(
    .W_DATA(W_DATA),
    .N_SA(N_SA),
    .W_ADDR(W_ADDR)
)uart_rx_weight_fifo(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_write_enable(write_wren_ctrl_rx_weight_ff_array),
    .i_read_enable(read_rden_ctrl_rx_north_ff_array),
    .i_data(rx_byte),
    .o_data(data_rx_weight_ff_array_wren_ctrl),
    .o_occupants(occ_rx_weight_ff_array_rden_ctrl),
    .o_empty(empty_rx_weight_ff_array_rden_ctrl),
    .o_valid(dv_rx_weight_ff_array_wren_ctrl)
);

//assert write enable signal of uart_rx_image_fifo
wire [N_SA-1 : 0] write_wren_ctrl_rx_image_ff_array;
uart_rx_ff_array_wren#(
    .N_SA(N_SA)
)uart_rx_image_fifo_wren(
    .i_dv(rx_dv),
    .i_sel(image_ff_sel),
    .i_rst(i_rst),
    .o_wren(write_wren_ctrl_rx_image_ff_array)
);

wire [N_SA-1 : 0] empty_rx_image_ff_array_rden_ctrl;
wire [N_SA-1 : 0] read_rden_ctrl_rx_image_ff_array;
wire [N_SA-1 : 0] dv_rx_image_ff_array_wren_ctrl;
wire [(N_SA * W_DATA)-1 : 0] data_rx_image_ff_array_wren_ctrl;
wire [(N_SA * (W_ADDR + 1))-1 : 0] occ_rx_image_ff_array_rden_ctrl;

/*
    Generate N_SA number of fifo N_SA number of SA engine to 
    load and save images in each engine
*/
mul_fifo#(
    .W_DATA(W_DATA),
    .N_SA(N_SA),
    .W_ADDR(W_ADDR)
)uart_rx_image_fifo(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_write_enable(write_wren_ctrl_rx_image_ff_array),
    .i_read_enable(read_rden_ctrl_rx_image_ff_array),
    .i_data(rx_byte),
    .o_data(data_rx_image_ff_array_wren_ctrl),
    .o_occupants(occ_rx_image_ff_array_rden_ctrl),
    .o_empty(empty_rx_image_ff_array_rden_ctrl),
    .o_valid(dv_rx_image_ff_array_wren_ctrl)
);

//handles reading of weights from uart_rx_weight_fifo
uart_rx_weight_ff_rden#(
    .N_SA(N_SA),
    .W_ADDR(W_ADDR),
    .ROW(ROW),
    .COL(COL)
)uart_rx_weight_fifo_rden(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_fifo_empty(empty_rx_weight_ff_array_rden_ctrl),
    .i_fifo_occupants(occ_rx_weight_ff_array_rden_ctrl),
    .o_fifo_read_enable(read_rden_ctrl_rx_north_ff_array)
);

//handles reading of image from uart_rx_image_fifo
uart_rx_image_ff_rden#(
    .N_SA(N_SA),
    .W_ADDR(W_ADDR)
)uart_rx_image_fifo_rden(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_fifo_empty(empty_rx_image_ff_array_rden_ctrl),
    .i_fifo_occupants(occ_rx_image_ff_array_rden_ctrl),
    .o_fifo_read_enable(read_rden_ctrl_rx_image_ff_array)
);

wire [(N_SA * W_DATA)-1 : 0] data_weight_wren_ctrl_sa;
wire [N_SA-1 : 0] enb_weight_wren_ctrl_wren_gen;

//send weights from uart_rx_weight_fifo to sa_engine_weight_fifo_array
sa_fifo_array_wren_ctrl#(    //TODO: Rename controller and signals
    .N_SA(N_SA),
    .W_DATA(W_DATA)
)sa_engine_weight_fifo_array_data(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data_valid(dv_rx_weight_ff_array_wren_ctrl),
    .i_data(data_rx_weight_ff_array_wren_ctrl),
    .o_data(data_weight_wren_ctrl_sa),
    .o_wren(enb_weight_wren_ctrl_wren_gen)
);

wire [(N_SA * W_DATA)-1 : 0] data_image_wren_ctrl_sa;
wire [N_SA-1 : 0] enb_image_wren_ctrl_wren_gen;

//send images from uart_rx_image_fifo to sa_engine_image_fifo_array
sa_fifo_array_wren_ctrl#(    //TODO: Rename controller and signals
    .N_SA(N_SA),
    .W_DATA(W_DATA)
)sa_engine_image_fifo_array_data(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data_valid(dv_rx_image_ff_array_wren_ctrl),
    .i_data(data_rx_image_ff_array_wren_ctrl),
    .o_data(data_image_wren_ctrl_sa),
    .o_wren(enb_image_wren_ctrl_wren_gen)
);

wire [(N_SA * COL)-1 : 0] engine_north_ff_wren;

//assert sa_engine_weight_fifo_array write enable signal of one fifo at a time in the array
sa_fifo_array_wren_gen#(
    .DIMENSION(COL),
    .N_SA(N_SA)
)weight_fifo_array_wren_ctrl(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_enb(enb_weight_wren_ctrl_wren_gen),
    .o_wren(engine_north_ff_wren)
);

wire [(N_SA * ROW)-1 : 0] engine_west_ff_wren;

//assert sa_engine_image_fifo_array write enable signal of one fifo at a time in the array
sa_fifo_array_wren_gen#(
    .DIMENSION(ROW),
    .N_SA(N_SA)
)image_fifo_array_wren_ctrl(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_enb(enb_image_wren_ctrl_wren_gen),
    .o_wren(engine_west_ff_wren)
);

wire [(COL * N_SA)-1 : 0] psum_ff_array_read_ctrl_sa;
wire [((COL * W_PSUM) * N_SA)-1 : 0] psum_ff_array_data_sa_psum_ff;
wire [(COL * N_SA)-1 : 0] psum_ff_array_empty_sa_psum_ff;
// wire [(COL * N_SA)-1 : 0] out_south_dv;

//Generates SA engine N_SA times
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
)multiple_sa_engines(
    .i_clk(i_clk),
    .s_clk(s_clk),
    .i_rst(i_rst),
    .i_trigger_1(trigg1),
    .i_weight_fifo_array_data(data_weight_wren_ctrl_sa),
    .i_weight_fifo_array_write_en(engine_north_ff_wren),
    .i_image_fifo_array_data(data_image_wren_ctrl_sa),
    .i_image_fifo_array_wren(engine_west_ff_wren),
    .i_psum_ff_array_read_en(psum_ff_array_read_ctrl_sa),
    .o_psum_ff_array_partial_sums(psum_ff_array_data_sa_psum_ff),
    .o_psum_ff_array_empty(psum_ff_array_empty_sa_psum_ff),
    .o_psum_ff_array_dv()
);

wire [N_SA-1 : 0] wren_psum_ff_ctrl_tx_fifo;
wire [(N_SA * W_PSUM)-1 : 0] data_psum_ff_ctrl_tx_fifo;

/*
    Takes partial sums from all column in the PE grid and 
    sends the partial sum of each column sequentially
*/
psum_fifo_ctrl#(
    .COL(COL),
    .W_PSUM(W_PSUM),
    .N_SA(N_SA)
) psum_fifo_controller(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(psum_ff_array_data_sa_psum_ff),
    .i_fifo_empty(psum_ff_array_empty_sa_psum_ff),
    .o_fifo_read_enable(psum_ff_array_read_ctrl_sa),
    .o_fifo_write_enable(wren_psum_ff_ctrl_tx_fifo),
    .o_data(data_psum_ff_ctrl_tx_fifo)
);

wire [N_SA-1 : 0] rden_tx_ctrl_psum_tx_ff;
wire [(W_PSUM * N_SA)-1 : 0] data_tx_psum_ff_tx_ctrl;
wire [(N_SA * (W_ADDR + 1))-1 : 0] occ_tx_ctrl_psum_tx_ff;
wire [N_SA-1 : 0] empty_tx_ctrl_psum_tx_ff;

//Stores the partial sums of all the column in a SA engine one by one
mul_fifo#(
    .N_SA(N_SA),
    .W_DATA(W_PSUM),
    .W_ADDR(W_ADDR)
)uart_tx_psum_fifo(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_write_enable(wren_psum_ff_ctrl_tx_fifo),
    .i_read_enable(rden_tx_ctrl_psum_tx_ff),
    .i_data(data_psum_ff_ctrl_tx_fifo),
    .o_data(data_tx_psum_ff_tx_ctrl),
    .o_empty(empty_tx_ctrl_psum_tx_ff),
    .o_valid(),
    .o_occupants(occ_tx_ctrl_psum_tx_ff)
);

/*
    Takes 19 bits of partial sums and converts it into 
    multiple bytes to send it to uart transmitter
*/
controller_psum_fifo_tx#(
    .N_SA(N_SA),
    .W_PSUM(W_PSUM),
    .W_DATA(W_DATA)
)psum_fifo_tx_controller(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_fifo_empty(empty_tx_ctrl_psum_tx_ff),
    .o_fifo_rden(rden_tx_ctrl_psum_tx_ff),
    .i_data(data_tx_psum_ff_tx_ctrl),
    .i_tx_done(tx_done),
    .o_tx_dv(tx_dv),
    .o_tx_data(tx_byte)
);

wire [N_SA-1 : 0] tx_dv;
wire [N_SA-1 : 0] tx_done;
wire [(W_DATA * N_SA)-1 : 0] tx_byte;

//multiple uart transmitter, one for each SA engine
uart_tx#(
    .W_DATA(W_DATA),
    .N_SA(N_SA)
)multiple_transmitter(  
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_tx_dv(tx_dv),
    .i_tx_byte(tx_byte),
    .o_tx_done(tx_done),
    .o_tx_serial(o_tx_serial)
);
endmodule
