module top#(
    parameter N_SA = 4,     //number of SA engines
    parameter COL_SA = 4,   //columns in one SA engine
    parameter COL_FC = 32,   //columns in FC engine
    parameter W_FC_CNT = 15,  //image dimension signal width
    parameter W_DATA = 8,
    parameter W_ADDR = 9,
    parameter RAM_DEPTH = (1 << W_ADDR),
    parameter N_BRAM_BYTES = 32
)(
    input i_clk,
    input i_rst,
    input i_start,  //trigger for SA read enable controller
    input [3:0] i_opcode,
    input [W_DATA-1 : 0] i_weight_ff_array_data,
    input [COL-1 : 0] i_weight_ff_array_wren,
    output [COL-1 : 0] o_weight_ff_array_dv,
    output [(COL * W_DATA)-1 : 0] o_weight_ff_array_data
);

localparam COL = ((N_SA * COL_SA) > COL_FC) ? (N_SA * COL_SA) : COL_FC;

wire [COL-1 : 0] empty_weight_ff_array_mux;
wire [(COL * (W_ADDR + 1))-1 : 0] occ_weight_ff_array_mux;

//north fifo array
weight_ff_array#(
    .COL(COL),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(RAM_DEPTH)
)weight_fifo_array(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(i_weight_ff_array_data),
    .i_read_enable(weight_ff_array_rden),
    .i_write_enable(i_weight_ff_array_wren),
    .o_data(o_weight_ff_array_data),
    .o_fifo_empty(empty_weight_ff_array_mux),
    .o_fifo_full(),
    .o_fifo_dv(o_weight_ff_array_dv),
    .o_occupants(occ_weight_ff_array_mux)
);

wire [(N_SA * COL_SA)-1 : 0] sa_empty;
wire [(N_SA * (COL_SA * (W_ADDR + 1)))-1 : 0] sa_occupants;
wire w_sel1;
wire [COL_FC-1 : 0] fc_empty;
wire [(COL_FC * (W_ADDR + 1))-1 : 0] fc_occupants;
//sa fc mux
mux#(
    .W_ADDR(W_ADDR),
    .COL(COL),
    .N_SA(N_SA),     //number of SA engines
    .SA_COL(COL_SA),   //columns in each SA engine
    .FC_COL(COL_FC),  //columns in FC engine
    .N_BRAM_BYTES(N_BRAM_BYTES)     //number of BRAM burst bytes
)sa_fc_mux(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_opcode(i_opcode),
    .i_sel_sa_rden_ctrl(sel_sa_rden_mux),
    .i_weight_ff_array_empty(empty_weight_ff_array_mux),
    .i_weight_ff_array_occupants(occ_weight_ff_array_mux),
    .o_fc_occupants(fc_occupants),
    .o_fc_empty(fc_empty),
    .o_sa_empty(sa_empty),
    .o_sa_occupants(sa_occupants),
    .o_sel1(w_sel1)
);

//SA rden controller
wire sel_sa_rden_mux;
assign sel_sa_rden_mux = &(w_sel2);
wire [N_SA-1 : 0] w_sel2;
wire [(N_SA * COL_SA)-1 : 0] sa_rden_req;
// sa_north_rden#(
//     .COL(COL_SA),
//     .N_SA(N_SA),
//     .W_ADDR(W_ADDR),
//     .ROW(9),
//     .N_BRAM_BYTES(N_BRAM_BYTES)
// )(
//     .clk(i_clk),
//     .rst(i_rst),
//     .start(i_start),
//     .done(w_done),
//     .layer_done(w_layer_done),
//     .i_north_empty(sa_empty),
//     .i_north_occ(sa_occupants),
//     .o_fifo_rden(sa_rden_req),
//     .o_sel(w_sel2)
// );

sa_weight_ff_rden#(
    .COL_SA(COL_SA),
    .W_ADDR(W_ADDR),
    .ROW(9),
    .N_SA(N_SA),
    .N_BRAM_BYTES(N_BRAM_BYTES)
)sa_rden_ctrl(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_start(i_start),
    .i_done(w_done),
    .i_layer_done(w_layer_done),
    .i_weight_ff_empty(sa_empty),
    .i_weight_ff_occupants(sa_occupants),
    .o_weight_ff_read_en(sa_rden_req),
    .o_sel(w_sel2)
);

wire [COL_FC-1 : 0] fc_rden_req;
//FC rden controller
rden_controller#(
    .COL(COL_FC),
    .ROW(1),
    .W_FC_CNT(W_FC_CNT),
    .W_ADDR(W_ADDR)
)fc_rden_ctrl(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_trigger(i_start),
    .i_sel1(w_sel1),
    .i_north_empty(fc_empty),
    .i_north_occ(fc_occupants),
    .i_img_dim(15'd10),    //TODO: Check the value
    .o_north_rden(fc_rden_req)
);

wire w_layer_done;
wire w_done;
//test counters to generate done and layer done flags
counters test_counters(
    .i_clk(i_clk),
    .i_start(i_start),
    .o_layer_done(w_layer_done),
    .o_done(w_done)
);
wire [COL-1 : 0] weight_ff_array_rden;
//mux to select read enable signal among SA and FC read request
rden_mux#(
    .COL(COL)
)sa_fc_rden_mux(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_fc_rden(fc_rden_req),
    .i_sa_rden(sa_rden_req),
    .i_sel_1(w_sel1),
    .i_sel_2(w_sel2),
    .o_north_rden(weight_ff_array_rden)
);

endmodule