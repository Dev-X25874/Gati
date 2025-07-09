/*
    Contains weight fifo array, demux and mux
    for laoding weights either into SA or FC 
    block at a time.
*/
module top_fifo_sharing#(
    parameter W_DATA = 8,
    parameter N_SA = 8,                 //Number of SA engines                 
    parameter COL_SA = 8,               //columns in one SA engine
    parameter COL_FC = 32,              //total columns in FC
    parameter N_DRAM_BYTES = 32,        //number of DRAM bytes
    parameter SA_OPCODE = 0,            
    parameter FC_OPCODE = 4,
    parameter WEIGHT_FF_DEPTH = 512,
    parameter ROW = 9,
    parameter W_OPCODE = 4
)(
    input clk,
    input i_rstn,
    input i_done,
    //input i_sel_sa_rden_ctrl,                       //select signal coming from weight fifo array read enable ctrl in SA
    input [W_OPCODE-1:0] i_opcode,                           //comes from config block
    input [(N_FIFOS * COL_SA * W_DATA)-1 : 0] i_data_weight_ff_array,
    input [N_FIFOS-1 : 0] i_write_en_weight_ff_array,
    input [N_FIFO_FC-1 : 0] i_read_en_fc,              //weight fifo array read enable signal, coming form FC
    input [(N_SA)-1 : 0] i_read_en_sa,     //weight fifo array read enable signal, coming from SA
    
    `ifdef FC
    output o_demux_select,
    output [(N_FIFO_FC * (WEIGHT_FF_ADDR + 1))-1 : 0] o_occupants_mux_fc,
    output [(COL_FC * W_DATA)-1 : 0] o_data_mux_fc,
    output o_empty_mux_fc,
    output o_almost_empty_mux_fc,
    output [N_FIFO_FC-1 : 0] o_dv_mux_fc,
    `endif //FC

    output [(N_SA)-1 : 0] o_dv_mux_sa,
    output [(N_SA * ((WEIGHT_FF_ADDR + 1)))-1 : 0] o_occupants_mux_sa,
    output [(N_SA)-1 : 0] o_empty_mux_sa,
    output [(N_SA * COL_SA * W_DATA)-1 : 0] o_data_mux_sa,
    output [(N_FIFOS * (WEIGHT_FF_ADDR + 1))-1 : 0] o_weight_ff_array_occupants
);

localparam WEIGHT_FF_ADDR = $clog2(WEIGHT_FF_DEPTH);
localparam N_FIFOS = ((N_SA * COL_SA) > N_DRAM_BYTES) ? (N_SA) : (N_DRAM_BYTES/COL_SA);
localparam N_FIFO_FC = N_DRAM_BYTES/COL_SA;

wire [N_FIFOS-1 : 0] weight_ff_array_read_en;
wire [N_FIFOS-1 : 0] weight_ff_array_empty;
wire [N_FIFOS-1 : 0] weight_ff_array_almost_empty;
wire [N_FIFOS-1 : 0] weight_ff_array_dv;
wire [(N_FIFOS * COL_SA * W_DATA)-1 : 0] weight_ff_array_data;
wire [(N_FIFOS * (WEIGHT_FF_ADDR + 1))-1 : 0] weight_ff_array_occupants;
wire i_sel_sa_rden_ctrl;

assign o_weight_ff_array_occupants = weight_ff_array_occupants;

//weight fifo array
weight_ff_array#(
    .COL(N_FIFOS),
    .W_DATA(COL_SA*W_DATA),
    .WEIGHT_FF_DEPTH(WEIGHT_FF_DEPTH)
) weight_fifo_array(
    .i_clk(clk),
    .i_rstn(i_rstn),
    .i_data(i_data_weight_ff_array),
    .i_read_enable(weight_ff_array_read_en),
    .i_write_enable(i_write_en_weight_ff_array),
    .o_data(weight_ff_array_data),
    .o_fifo_empty(weight_ff_array_empty),
    .o_fifo_almost_empty(weight_ff_array_almost_empty),
    .o_fifo_full(),
    .o_fifo_dv(weight_ff_array_dv),
    .o_occupants(weight_ff_array_occupants)
);

wire o_demux_select;

//handles toggling of read enable signal for SA or FC
demux#(
    .WEIGHT_FF_DEPTH(WEIGHT_FF_DEPTH),
    .COL(N_FIFOS),
    .N_SA(N_SA),     
    .COL_SA(COL_SA),   
    .COL_FC(COL_FC),  
    .N_DRAM_BYTES(N_DRAM_BYTES),
    .SA_OPCODE(SA_OPCODE),
    .FC_OPCODE(FC_OPCODE),
    .W_DATA(COL_SA*W_DATA),
    .W_OPCODE(W_OPCODE)
)sa_fc_demux(
    .i_clk(clk),
    .i_rstn(i_rstn),
    .i_opcode(i_opcode),
    .i_sel_sa_rden_ctrl(i_sel_sa_rden_ctrl),
    .i_weight_ff_array_dv(weight_ff_array_dv),
    .i_weight_ff_array_data(weight_ff_array_data),
    .i_weight_ff_array_empty(weight_ff_array_empty),
    .i_weight_ff_array_almost_empty(weight_ff_array_almost_empty),
    .i_weight_ff_array_occupants(weight_ff_array_occupants),

    `ifdef FC
    .o_fc_occupants(o_occupants_mux_fc),
    .o_fc_empty(o_empty_mux_fc),
    .o_fc_almost_empty(o_almost_empty_mux_fc),
    .o_fc_data(o_data_mux_fc),
    .o_fc_dv(o_dv_mux_fc),
    `endif //FC

    .o_sa_empty(o_empty_mux_sa),
    .o_sa_occupants(o_occupants_mux_sa),
    .demux_sel(o_demux_select),
    .o_sa_data(o_data_mux_sa),
    .o_sa_dv(o_dv_mux_sa)
);


//mux to send read enable signal from SA and FC into weight fifo array
rden_mux#(
    .COL(N_FIFOS),
    .COL_FC(COL_FC),
    .ROW(ROW),
    .N_SA(N_SA),
    .COL_SA(COL_SA),
    .N_DRAM_BYTES(N_DRAM_BYTES)
)sa_fc_read_mux(
    .i_clk(clk),
    .i_rstn(i_rstn),
    .i_done(i_done),
    .o_sel(i_sel_sa_rden_ctrl),
    .i_fc_rden(i_read_en_fc),
    .i_sa_rden(i_read_en_sa),
    .i_sel_1(o_demux_select),
    .o_north_rden(weight_ff_array_read_en)
);

endmodule
