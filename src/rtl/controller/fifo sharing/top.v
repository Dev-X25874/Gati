module top#(
    parameter W_DATA = 8,                   
    parameter W_ADDR = 9,
    parameter N_SA = 4,                 //Number of SA engines                 
    parameter COL_SA = 4,               //columns in one SA engine
    parameter COL_FC = 32,              //total columns in FC
    parameter RAM_DEPTH = (1 << W_ADDR),
    parameter N_DRAM_BYTES = 32,        //number of BRAM bytes
    parameter SA_OPCODE = 0,            
    parameter FC_OPCODE = 4
)(
    input clk,
    input i_rstn,
    input i_sel_sa_rden_ctrl,
    input [3:0] i_opcode,
    input [(COL * W_DATA)-1 : 0] i_data_weight_ff_array,
    input [COL-1 : 0] i_write_en_weight_ff_array,
    input [COL_FC-1 : 0] i_read_en_fc,
    input [(N_SA * COL_SA)-1 : 0] i_read_en_sa,
    output o_sel_mux,
    output [(COL_FC * (W_ADDR + 1))-1 : 0] o_occupants_mux_fc,
    output [COL_FC-1 : 0] o_empty_mux_fc,
    output [COL_FC-1 : 0] o_dv_mux_fc,
    output [(N_SA * COL_SA)-1 : 0] o_dv_mux_sa,
    output [(N_SA * (COL_SA * (W_ADDR + 1)))-1 : 0] o_occupants_mux_sa,
    output [(N_SA * COL_SA)-1 : 0] o_empty_mux_sa,
    output [(COL_FC * W_DATA)-1 : 0] o_data_mux_fc,
    output [(N_SA * COL_SA * W_DATA)-1 : 0] o_data_mux_sa
);

localparam COL = ((N_SA * COL_SA) > COL_FC) ? (N_SA * COL_SA) : COL_FC;

wire [COL-1 : 0] weight_ff_array_empty;
wire [COL-1 : 0] weight_ff_array_dv;
wire [(COL * W_DATA)-1 : 0] weight_ff_array_data;
wire [(COL * (W_ADDR + 1))-1 : 0] weight_ff_array_occupants;
//weight fifo array
weight_ff_array#(
    .COL(COL),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(RAM_DEPTH)
) weight_fifo_array(
    .i_clk(clk),
    .i_rstn(i_rstn),
    .i_data(i_data_weight_ff_array),
    .i_read_enable(weight_ff_array_read_en),
    .i_write_enable(i_write_en_weight_ff_array),
    .o_data(weight_ff_array_data),
    .o_fifo_empty(weight_ff_array_empty),
    .o_fifo_full(),
    .o_fifo_dv(weight_ff_array_dv),
    .o_occupants(weight_ff_array_occupants)
);

wire o_sel_mux;
//handles toggling of read enable signal for SA or FC
mux#(
    .W_ADDR(W_ADDR),
    .COL(COL),
    .N_SA(N_SA),     
    .COL_SA(COL_SA),   
    .COL_FC(COL_FC),  
    .N_DRAM_BYTES(N_DRAM_BYTES),
    .SA_OPCODE(SA_OPCODE),
    .FC_OPCODE(FC_OPCODE)
)sa_fc_demux(
    .i_clk(clk),
    .i_rstn(i_rstn),
    .i_opcode(i_opcode),
    .i_sel_sa_rden_ctrl(i_sel_sa_rden_ctrl),
    .i_weight_ff_array_dv(weight_ff_array_dv),
    .i_weight_ff_array_data(weight_ff_array_data),
    .i_weight_ff_array_empty(weight_ff_array_empty),
    .i_weight_ff_array_occupants(weight_ff_array_occupants),
    .o_fc_occupants(o_occupants_mux_fc),
    .o_fc_empty(o_empty_mux_fc),
    .o_sa_empty(o_empty_mux_sa),
    .o_sa_occupants(o_occupants_mux_sa),
    .o_sel1(o_sel_mux),
    .o_sa_data(o_data_mux_sa),
    .o_fc_data(o_data_mux_fc),
    .o_fc_dv(o_dv_mux_fc),
    .o_sa_dv(o_dv_mux_sa),
);

wire [COL-1 : 0] weight_ff_array_read_en;
//mux to load weight into either SA or FC
rden_mux#(
    .COL(COL),
    .COL_FC(COL_FC),
    .N_SA(N_SA),
    .COL_SA(COL_SA),
    .N_DRAM_BYTES(N_DRAM_BYTES)
)sa_fc_read_mux(
    .i_clk(clk),
    .i_rstn(i_rstn),
    .i_fc_rden(i_read_en_fc),
    .i_sa_rden(i_read_en_sa),
    .i_sel_1(o_sel_mux),
    .i_sel_2(i_sel_sa_rden_ctrl),
    .o_north_rden(weight_ff_array_read_en)
);

endmodule
