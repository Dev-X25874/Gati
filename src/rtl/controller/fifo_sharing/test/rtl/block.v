module block#(
    parameter COL = 16,
    parameter W_DATA = 8,
    parameter W_ADDR = 8,
    parameter RAM_DEPTH = (1 << W_ADDR),
    parameter N_SA_CNV = 4,
    parameter N_SA_FC = 1
)(
    input i_clk,
    input i_rst,
    input i_start,
    input [3:0] i_opcode,
    input [W_DATA-1 : 0] i_north_data,
    input [COL-1 : 0] i_north_wren,
    output [(COL * (W_DATA + 1))-1 : 0] north_array_data
);

wire [(COL * W_DATA)-1 : 0] north_data;
wire [COL-1 : 0] north_empty;
wire [(COL * (W_ADDR + 1))-1 : 0] north_occ;
wire [COL-1 : 0] north_fifo_read_enable;
wire [COL-1 : 0] north_dv;
fifo_north#(
    .COL(COL),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(RAM_DEPTH)
)north_fifo_array(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(i_north_data),
    .i_read_enable(north_fifo_read_enable),
    .i_write_enable(i_north_wren),
    .o_data(north_data),
    .o_fifo_empty(north_empty),
    .o_fifo_full(),
    .o_fifo_dv(north_dv),
    .o_occupants(north_occ)
);

append_dv#(
    .N_DIMENSION(COL),  //number of rows or columns
    .W_DATA(W_DATA)
) append_data_valid (  
    .i_data(north_data),
    .i_data_valid(north_dv),
    .o_data(north_array_data)
);

wire mux_sel1;
controller mux_ctrl(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_opcode(i_opcode),
    .o_sel1(mux_sel1)
);

wire [(N_SA_FC * COL)-1 : 0] fc_empty;
wire [(N_SA_FC * (COL * (W_ADDR + 1)))-1 : 0] fc_occ;
wire [(N_SA_CNV * ((COL/2) / N_SA_CNV))-1 : 0] sa_empty;
wire [(N_SA_CNV * (((COL/2) / N_SA_CNV) * (W_ADDR + 1)))-1 : 0] sa_occ;

mux#(
    .COL(COL),
    .N_SA_FC(N_SA_FC),  //Number of engine in fully connected
    .N_SA_CNV(N_SA_CNV),  //Number of engines in convolution layer
    .W_ADDR(W_ADDR)
)ctrl_mux(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_sel1(mux_sel1),
    .i_sel2(mux_sel2),
    .i_empty(north_empty),
    .i_occupants(north_occ),
    .o_fc_occ(fc_occ),
    .o_fc_empty(fc_empty),
    .o_sa_empty(sa_empty),
    .o_sa_occ(sa_occ)
);

//Fully connected layer controller
wire mux_sel2;
rden_controller#(
    .COL(COL),
    .ROW(1),
    .W_FC_CNT(15),
    .W_ADDR(W_ADDR)
)fc_weight_ff_array_rden(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_trigger(i_start),
    .i_sel1(mux_sel1),
    .i_north_empty(fc_empty),
    .i_north_occ(fc_occ),
    .i_img_dim(15'd10),
    .o_north_rden(o_fc_rden)
);

wire [COL-1 : 0] o_fc_rden;
wire [(COL/2)-1 : 0] o_sa_rden;

//convolution layer controller
internal_north_rden#(
    .COL(COL/2),
    .W_ADDR(W_ADDR),
    .ROW(9)
)sa_weight_ff_array_rden(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_start(i_start),
    .i_done(w_done),
    .i_layer_done(w_layer_done),
    .i_sel_1(mux_sel1),
    .i_fifo_empty(sa_empty),
    .i_fifo_occupants(sa_occ),
    .o_fifo_read_enable(o_sa_rden),
    .o_sel(mux_sel2)
);

wire w_layer_done;
wire w_done;
counters test_signals(
    .i_clk(i_clk),
    .i_start(i_start),
    .o_layer_done(w_layer_done),
    .o_done(w_done)
);

rden_mux#(
    .COL(COL)
) rden_mux_ctrl(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_fc_rden(o_fc_rden),
    .i_sa_rden(o_sa_rden),
    .i_sel_1(mux_sel1),
    .i_sel_2(mux_sel2),
    .o_north_rden(north_fifo_read_enable)
);


endmodule