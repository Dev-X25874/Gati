module top#(
    parameter N_SA = 4,
    parameter W_DATA = 8,
    parameter W_ADDR = 8,
    parameter COL = 4,
    parameter ROW = 9,
    parameter W_PSUM = 19,
    parameter RAM_DEPTH = (1 << W_ADDR)
)(
    input i_clk,
    input s_clk,
    input i_rst,
    input [N_SA-1 : 0] i_rx_serial,
    input i_trigger_1,
    input i_trigger_2,
    input i_sel_1,
    input i_sel_2,
    output [N_SA-1 : 0] o_tx_serial
);
wire sel1;
assign sel1 = ~i_sel_1;
wire sel2;
assign sel2 = ~i_sel_2;
wire trigg1;
wire trigg2;
assign trigg1 = ~i_trigger_1;
assign trigg2 = ~i_trigger_2;
wire [N_SA-1 : 0] rx_dv;
wire [(N_SA * W_DATA)-1 : 0] rx_byte;
mul_receiver#(
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

wire [N_SA-1 : 0] west_wren;
wren #(
    .N_SA(N_SA)
)wren_ctrl_img_ff(
    .i_dv(rx_dv),
    .i_sel(sel2),
    .i_rst(i_rst),
    .o_wren(west_wren)
);

wire [N_SA-1 : 0] west_empty;
wire [N_SA-1 : 0] west_rden;
wire [N_SA-1 : 0] west_dv;
wire [(N_SA * W_DATA)-1 : 0] west_data;
wire [(N_SA * (W_ADDR + 1))-1 : 0] west_occ;
mul_fifo#(
    .W_DATA(W_DATA),
    .N_SA(N_SA),
    .W_ADDR(W_ADDR)
)west_ff(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_write_enable(west_wren),
    .i_read_enable(west_rden),
    .i_data(rx_byte),
    .o_data(west_data),
    .o_occupants(west_occ),
    .o_empty(west_empty),
    .o_valid(west_dv)
);

external_north_rden#(
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

external_west_rden#(
    .N_SA(N_SA),
    .W_ADDR(W_ADDR)
)west_rden_ctrl(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_fifo_empty(west_empty),
    .i_fifo_occupants(west_occ),
    .o_fifo_read_enable(west_rden)
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

wire [(N_SA * W_DATA)-1 : 0] sa_west_data;
wire [N_SA-1 : 0] sa_west_wren;
external_sa_input_ctrl#(
    .N_SA(N_SA),
    .W_DATA(W_DATA)
)west_wren_ctrl(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data_valid(west_dv),
    .i_data(west_data),
    .o_data(sa_west_data),
    .o_wren(sa_west_wren)
);

wire [(N_SA * COL)-1 : 0] engine_north_ff_wren;
internal_north_wren_gen#(
    .COL(COL),
    .N_SA(N_SA)
)sa_engine_north_wren(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_enb(sa_north_wren),
    .o_wren(engine_north_ff_wren)
);

wire [(N_SA * ROW)-1 : 0] engine_west_ff_wren;
internal_west_wren_gen#(
    .ROW(ROW),
    .N_SA(N_SA)
)sa_engine_west_wren(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_enb(sa_west_wren),
    .o_wren(engine_west_ff_wren)
);

wire [(COL * N_SA)-1 : 0] i_south_array_rden;
wire [((COL * W_PSUM) * N_SA)-1 : 0] out_partial_sums;
wire [(COL * N_SA)-1 : 0] out_south_empty;
wire [(COL * N_SA)-1 : 0] out_south_dv;
mul_engines#(
    .N_SA(N_SA),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .COL(COL),
    .ROW(ROW),
    .W_PSUM(W_PSUM),
    .RAM_DEPTH(RAM_DEPTH)
)mul_sa_engines(
    .i_clk(i_clk),
    .s_clk(s_clk),
    .i_rst(i_rst),
    .i_trigger_1(trigg1),
    .i_trigger_2(trigg2),
    .i_north_data(sa_north_data),
    .i_north_wren(engine_north_ff_wren),
    .i_west_data(sa_west_data),
    .i_west_wren(engine_west_ff_wren),
    .i_south_array_rden(i_south_array_rden),
    .out_partial_sums(out_partial_sums),
    .out_south_empty(out_south_empty),
    .out_south_dv(out_south_dv)
);

wire [N_SA-1 : 0] last_ff_wren;
wire [(N_SA * W_PSUM)-1 : 0] last_ff_input;
external_sa_output_ctrl#(
    .COL(COL),
    .W_PSUM(W_PSUM),
    .N_SA(N_SA)
) p_sum_array_rden_controller(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(out_partial_sums),
    .i_fifo_empty(out_south_empty),
    .o_fifo_read_enable(i_south_array_rden),
    .o_fifo_write_enable(last_ff_wren),
    .o_data(last_ff_input)
);
wire [N_SA-1 : 0] last_ff_rden;
wire [(W_PSUM * N_SA)-1 : 0] last_ff_data;
wire [(N_SA * (W_ADDR + 1))-1 : 0] last_ff_occ;
wire [N_SA-1 : 0] last_ff_empty;
mul_fifo#(
    .N_SA(N_SA),
    .W_DATA(W_PSUM),
    .W_ADDR(W_ADDR)
)south_ff(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_write_enable(last_ff_wren),
    .i_read_enable(last_ff_rden),
    .i_data(last_ff_input),
    .o_data(last_ff_data),
    .o_empty(last_ff_empty),
    .o_valid(),
    .o_occupants(last_ff_occ)
);

tx_controller_gen#(
    .N_SA(N_SA),
    .W_PSUM(W_PSUM),
    .W_DATA(W_DATA)
)fifp_tx_ctrl(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_fifo_empty(last_ff_empty),
    .o_fifo_rden(last_ff_rden),
    .i_data(last_ff_data),
    .i_tx_done(tx_done),
    .o_tx_dv(tx_dv),
    .o_tx_data(tx_byte)
);

wire [N_SA-1 : 0] tx_dv;
wire [N_SA-1 : 0] tx_done;
wire [(W_DATA * N_SA)-1 : 0] tx_byte;

mul_transmitter#(
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
