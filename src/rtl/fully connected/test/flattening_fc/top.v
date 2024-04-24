module top#(
    parameter N_SA = 1,
    parameter W_DATA = 8,
    parameter W_ADDR = 10,
    parameter COL = 32,
    parameter ROW = 1,
    parameter W_PSUM = 19,
    parameter RAM_DEPTH = (1 << W_ADDR),
    parameter W_ACC = 32,
    parameter N_FIFO = 32,
    parameter N_BRAM = 8, //number of brams in one bank
    parameter N_BANK = 4, //total number of bram banks
    parameter W_KERNAL_CNT = 16,
    parameter W_IMG_DIM = 20,
    parameter W_IMG_ROWS = 16
)(
    input i_clk,
    input s_clk,
    input rst_in,
    input i_image_serial_data,
    input flatten,
    input i_acc_valid,
    input [N_SA-1 : 0] i_rx_serial,
    // input [W_IMG_DIM-1 : 0] i_img_dim,
    input i_sel_1,
    output [N_SA-1 : 0] o_tx_serial
);

/*
    Negation of these input is done because efinity doesn't support 
    weak pulldown for few GPIOs. They are thus linked to ground 
    and configured as weak pullups in order to transmit the signal.
*/
wire i_rst;
assign i_rst = ~rst_in;
wire sel1;
assign sel1 = ~i_sel_1;


wire [N_SA-1 : 0] rx_dv;
wire [(N_SA * W_DATA)-1 : 0] rx_byte;

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

wire [N_SA-1 : 0] north_wren;

wren #(
    .N_SA(N_SA)
)wren_ctrl_weight_ff(
    .i_dv(rx_dv),
    .i_sel(sel1),
    .i_rst(i_rst),
    .o_wren(north_wren)
);

wire [N_SA-1 : 0] north_empty;
wire [N_SA-1 : 0] north_rden;
wire [N_SA-1 : 0] north_dv;
wire [(N_SA * W_DATA)-1 : 0] north_data;
wire [(N_SA * (W_ADDR + 1))-1 : 0] north_occ;

mul_fifo#(
    .W_DATA(W_DATA),
    .N_SA(N_SA),
    .W_ADDR(W_ADDR)
)north_ff(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_write_enable(north_wren),
    .i_read_enable(north_rden),
    .i_data(rx_byte),
    .o_data(north_data),
    .o_occupants(north_occ),
    .o_empty(north_empty),
    .o_valid(north_dv)
);

external_ff_rden_ctrl#(
    .N_SA(N_SA),
    .W_ADDR(W_ADDR),
    .ROW(ROW),
    .COL(COL)
)north_rden_ctrl(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_fifo_empty(north_empty),
    .i_fifo_occupants(north_occ),
    .o_fifo_read_enable(north_rden)
);

wire [(N_SA * W_DATA)-1 : 0] sa_north_data;
wire [N_SA-1 : 0] sa_north_wren;

external_sa_input_ctrl#(
    .N_SA(N_SA),
    .W_DATA(W_DATA)
)north_wren_ctrl(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data_valid(north_dv),
    .i_data(north_data),
    .o_data(sa_north_data),
    .o_wren(sa_north_wren)
);

wire [(N_SA * COL)-1 : 0] engine_north_ff_wren;

engine_north_wren#(
    .COL(COL),
    .N_SA(N_SA)
)sa_engine_north_wren(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_enb(sa_north_wren),
    .o_wren(engine_north_ff_wren)
);

wire [COL-1 : 0] o_north_empty;
wire weight_fifo_array_trigger;
wire flattened_dv;
wire [W_DATA-1 : 0] flattened_data;

flattening_test_top#(
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .N_FIFO(N_FIFO),
    .N_BRAM(N_BRAM), //number of brams in one bank
    .N_BANK(N_BANK), //total number of bram banks
    .W_KERNAL_CNT(W_KERNAL_CNT),
    .W_IMG_DIM(W_IMG_DIM),
    .W_IMG_ROWS(W_IMG_ROWS)
)flattening_controller(
    .clk(i_clk),
    .rst(i_rst),
    .rx_serial(i_image_serial_data),
    .flatten(flatten),
    .i_acc_valid(i_acc_valid),
    .i_weight_ff_array_empty(o_north_empty),
    .i_img_dim(20'd49),
    .o_data_mux(flattened_data),
    .o_data_valid(flattened_dv),
    .weight_fifo_array_trigger(weight_fifo_array_trigger)
);

wire [(COL * N_SA)-1 : 0] acc_dv;
wire [((COL * W_ACC) * N_SA)-1 : 0] acc_data;
// wire [COL-1 : 0] rden_ctrl;

mul_engines#(
    .N_SA(N_SA),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .COL(COL),
    .ROW(ROW),
    .W_PSUM(W_PSUM),
    .RAM_DEPTH(RAM_DEPTH),
    .W_ACC(W_ACC),
    .W_FC_CNT(W_IMG_DIM)
) engines_inst(
    .i_clk(i_clk),
    .s_clk(s_clk),
    .i_rst(i_rst),
    .i_trigger_1(weight_fifo_array_trigger),
    .i_mux_sel_1(1'b0),
    .i_north_data(sa_north_data),
    .i_north_wren(engine_north_ff_wren),
    // .i_west_data(8'd12),
    .i_west_data(flattened_data),
    // .i_west_dv(8'd1),
    .i_west_dv(flattened_dv),
    // .i_west_empty(west_async_empty),
    // .i_west_occ(west_async_occ),
    // .i_acc_image_dim(15'd15),
    .i_acc_image_dim(20'd784),
    // .o_west_rden(west_async_rden),
    .o_acc_dv(acc_dv),
    .o_acc_data(acc_data),
    .o_north_empty(o_north_empty)
);

wire [COL-1 : 0] south_empty;
wire [COL-1 : 0] south_rden;
wire [((COL * W_ACC) * N_SA)-1 : 0] south_data;

mul_fifo#(
    .W_DATA(W_ACC),
    .N_SA(COL),
    .W_ADDR(W_ADDR)
)south_ff_array(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_write_enable(acc_dv),
    .i_read_enable(south_rden),
    .i_data(acc_data),
    .o_data(south_data),
    .o_occupants(),
    .o_empty(south_empty),
    .o_valid()
);

wire [W_ACC-1 : 0] last_ff_data;
wire last_ff_wren;

col_fifo_data#(
    .COL(COL),
    .W_PSUM(W_ACC)
)last_ff_ctrl(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(south_data),
    .i_fifo_empty(south_empty),
    .o_data(last_ff_data),
    .wr_en_final_fifo(last_ff_wren),
    .o_read_enable(south_rden)
);

wire [W_ACC-1 : 0] last_ff_data_out;
wire last_ff_rden;
wire last_ff_empty;

sync_fifo #(
    .W_DATA(W_ACC)
) last_sync_ff (
    .full_o(),
    .empty_o(last_ff_empty),
    .clk_i(i_clk),
    .wr_en_i(last_ff_wren),
    .rd_en_i(last_ff_rden),
    .wdata(last_ff_data),
    .datacount_o(),
    .rst_busy(),
    .rdata(last_ff_data_out),
    .a_rst_i(),
    .o_valid()
);

wire [N_SA-1 : 0] tx_dv;
wire [N_SA-1 : 0] tx_done;
wire [(N_SA * W_DATA)-1 : 0] tx_byte;

controller_fifo_tx#(
    .N_SA(N_SA),
    .W_ACC(W_ACC),
    .W_DATA(W_DATA)
)south_controller(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_fifo_empty(last_ff_empty),
    .o_fifo_rden(last_ff_rden),
    .i_data(last_ff_data_out),
    .i_tx_done(tx_done),
    .o_tx_dv(tx_dv),
    .o_tx_data(tx_byte)
);

uart_tx#(
    .W_DATA(W_DATA),
    .N_SA(N_SA)
)transmitter_array(  
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_tx_dv(tx_dv),
    .i_tx_byte(tx_byte),
    .o_tx_done(tx_done),
    .o_tx_serial(o_tx_serial)
);

endmodule