module top#(
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
   // input [4:0] i_sel_3,
   // input [5:0] i_sel_4,
    // input [(COL * W_DATA)-1 : 0] i_north_data,
    input [W_DATA-1 : 0] i_north_data,
    input [COL-1 : 0] i_north_wren,
    // output [W_DATA : 0] o_data_fc,
    // output [W_DATA : 0] o_data_sa
    output [(N_SA_CNV * ((COL / 2) * (W_DATA + 1)))-1 : 0] sa_data,
    output [(N_SA_FC * (COL * (W_DATA + 1)))-1 : 0] fc_data,
    output sa_dv,
    output fc_dv,
    output mux1_select
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

wire [(COL * (W_DATA + 1))-1 : 0] north_array_data;
append_dv#(
    .N_DIMENSION(COL),  //number of rows or columns
    .W_DATA(W_DATA)
) append_data_valid (  
    .i_data(north_data),
    .i_data_valid(north_dv),
    .o_data(north_array_data)
);

// wire mux1_select;
assign mux1_select = mux_sel1;
wire mux_sel1;
controller mux_ctrl(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_opcode(i_opcode),
    // .i_layer_iteration(i_iteration_status), //1 -> Conv done, 0 -> Conv incomplete
    .o_sel1(mux_sel1)
    // .o_sel2(mux_sel2)
);

wire [(N_SA_FC * (COL * (W_DATA + 1)))-1 : 0] fc_data;
wire [(N_SA_FC * COL)-1 : 0] fc_empty;
wire [(N_SA_FC * (COL * (W_ADDR + 1)))-1 : 0] fc_occ;
wire [(N_SA_CNV * ((COL/2) / N_SA_CNV))-1 : 0] sa_empty;
wire [(N_SA_CNV * (((COL/2) / N_SA_CNV) * (W_ADDR + 1)))-1 : 0] sa_occ;
wire [(N_SA_CNV * ((COL / 2) * (W_DATA + 1)))-1 : 0] sa_data;

mux#(
    .COL(COL),
    .W_DATA(W_DATA),
    .N_SA_FC(N_SA_FC),  //Number of engine in fully connected
    .N_SA_CNV(N_SA_CNV),  //Number of engines in convolution layer
    .W_ADDR(W_ADDR)
)ctrl_mux(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_sel1(mux_sel1),
    .i_sel2(mux_sel2),
    .i_data(north_array_data),
    .i_empty(north_empty),
    .i_occupants(north_occ),
    .o_fc_data(fc_data),
    .o_fc_occ(fc_occ),
    .o_fc_empty(fc_empty),
    .o_sa_data(sa_data),
    .o_sa_empty(sa_empty),
    .o_sa_occ(sa_occ),
    .fc_data_valid(fc_dv),
    .sa_data_valid(sa_dv)
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
    // .i_west_empty(),
    .i_north_occ(fc_occ),
    // .i_west_occ(),
    .i_img_dim(15'd10),
    .o_north_rden(o_fc_rden)
    // .o_west_rden()
);

wire [COL-1 : 0] o_fc_rden;
wire [(COL/2)-1 : 0] o_sa_rden;

//convolution layer controller
// internal_north_rden#(
//    .COL(COL/2),
//    .ROW(9),
//    .W_ADDR(W_ADDR),
//    .W_DATA(W_DATA)
// ) internal_north_rden_inst(
//    .i_clk(i_clk),
//    .i_rst(i_rst),
//    .i_trigger(i_iteration_status),
//    .i_sel1(mux_sel1),
//    .o_sel2(mux_sel2),
//    .i_fifo_empty(sa_empty),
//    .o_fifo_read_enable(o_sa_rden),
//    .i_fifo_occupants(sa_occ)
// );

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
/*
//Checking resources
sa_mux#(
    .COL(COL),
    .W_DATA(W_DATA)
)sa_data_mux(
    .i_data(sa_data),
    .i_sel(i_sel_3),
    .o_data(o_data_sa)
);

fc_mux#(
    .COL(COL),
    .W_DATA(W_DATA)
)fc_data_mux(
    .i_data(fc_data),
    .i_sel(i_sel_4),
    .o_data(o_data_fc)
);
*/


endmodule