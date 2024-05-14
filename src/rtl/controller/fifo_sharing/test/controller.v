/*
    Contains interconnection of weight fifo array,
    demux and read enable mux controllers for loading weights
    either into SA or FC at a time.
*/
module controller#(
    parameter N_SA = 4,         //number of SA engines
    parameter COL_SA = 4,       //columns in one SA engine
    parameter COL_FC = 32,      //columns in FC engine
    parameter W_FC_CNT = 15,    //image dimension signal width
    parameter W_DATA = 8,
    parameter N_DRAM_BYTES = 32,
    parameter COL = 32,
    parameter WEIGHT_FF_DEPTH = 512,
    parameter SA_OPCODE = 0,
    parameter FC_OPCODE = 4
)(
    input i_clk,
    input i_rstn,
    input i_start,              //trigger for SA read enable controller
    input [3:0] i_opcode,
    input [W_DATA-1 : 0] i_weight_ff_array_data,
    input [COL-1 : 0] i_weight_ff_array_wren,
    output [(COL_FC * W_DATA)-1 : 0] out_fc_data,
    output [(COL_SA * W_DATA)-1 : 0] out_sa_data,
    output [COL_FC-1 : 0] out_fc_dv,
    output [COL_SA-1 : 0] out_sa_dv
);

localparam WEIGHT_FF_ADDR = $clog2(WEIGHT_FF_DEPTH);

wire [COL-1 : 0] empty_weight_ff_array_mux;
wire [(COL * (WEIGHT_FF_ADDR + 1))-1 : 0] occ_weight_ff_array_mux;
wire [COL-1 : 0] o_weight_ff_array_dv;
wire [(COL * W_DATA)-1 : 0] o_weight_ff_array_data;
//north fifo array
weight_ff_array#(
    .COL(COL),
    .W_DATA(W_DATA),
    .WEIGHT_FF_DEPTH(WEIGHT_FF_DEPTH)
)weight_fifo_array(
    .i_clk(i_clk),
    .i_rstn(i_rstn),
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
wire [(N_SA * (COL_SA * (WEIGHT_FF_ADDR + 1)))-1 : 0] sa_occupants;
wire o_demux_sel;
wire [COL_FC-1 : 0] fc_empty;
wire [(COL_FC * (WEIGHT_FF_ADDR + 1))-1 : 0] fc_occupants;
//mux to load data into SA or FC block based upon the required conditions
demux#(
    .WEIGHT_FF_DEPTH(WEIGHT_FF_DEPTH),
    .COL(COL),
    .N_SA(N_SA),                    //number of SA engines
    .COL_SA(COL_SA),                //columns in each SA engine
    .COL_FC(COL_FC),                //columns in FC engine
    .N_DRAM_BYTES(N_DRAM_BYTES),    //number of DRAM burst bytes
    .SA_OPCODE(SA_OPCODE),
    .FC_OPCODE(FC_OPCODE),
    .W_DATA(W_DATA)
)(
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .i_opcode(i_opcode),
    .i_sel_sa_rden_ctrl(sel_sa_rden_mux),
    .i_weight_ff_array_data(o_weight_ff_array_data),
    .i_weight_ff_array_empty(empty_weight_ff_array_mux),
    .i_weight_ff_array_dv(o_weight_ff_array_dv),
    .i_weight_ff_array_occupants(occ_weight_ff_array_mux),
    .o_fc_occupants(fc_occupants),
    .o_fc_data(out_fc_data),
    .o_fc_empty(fc_empty),
    .o_fc_dv(out_fc_dv),
    .o_sa_dv(out_sa_dv),
    .o_sa_empty(sa_empty),
    .o_sa_data(out_sa_data),
    .o_sa_occupants(sa_occupants),
    .demux_sel(o_demux_sel)
);

wire sel_sa_rden_mux;
assign sel_sa_rden_mux = &(w_sel2);
wire [N_SA-1 : 0] w_sel2;
wire [(N_SA * COL_SA)-1 : 0] sa_rden_req;

//SA rden controller
sa_rden_controller#(
    .COL_SA(COL_SA),
    .WEIGHT_FF_DEPTH(WEIGHT_FF_DEPTH),
    .ROW(9),
    .N_SA(N_SA),
    .N_DRAM_BYTES(N_DRAM_BYTES)
)sa_rden_ctrl(
    .i_clk(i_clk),
    .i_rstn(i_rstn),
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
fc_rden_controller#(
    .COL(COL_FC),
    .ROW(1),
    .W_FC_CNT(W_FC_CNT),
    .WEIGHT_FF_DEPTH(WEIGHT_FF_DEPTH)
)fc_rden_ctrl(
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .i_trigger(i_start),
    .i_sel_mux(o_demux_sel),
    .i_north_empty(fc_empty),
    .i_north_occ(fc_occupants),
    .i_img_dim(15'd10),
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
    .COL(COL),
    .COL_FC(COL_FC),
    .N_SA(N_SA),
    .COL_SA(COL_SA),
    .N_DRAM_BYTES(N_DRAM_BYTES)
)sa_fc_rden_mux(
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .i_fc_rden(fc_rden_req),
    .i_sa_rden(sa_rden_req),
    .i_sel_1(o_demux_sel),
    .i_sel_2(sel_sa_rden_mux),
    .o_north_rden(weight_ff_array_rden)
);

endmodule