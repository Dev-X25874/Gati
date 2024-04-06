module implementation#(
    parameter N_SA = 8,     //number of SA engines
    parameter COL_SA = 8,   //columns in one SA engine
    parameter COL_FC = 32,   //columns in FC engine
    parameter W_FC_CNT = 15,  //image dimension signal width
    parameter W_DATA = 8,
    parameter W_ADDR = 9,
    parameter RAM_DEPTH = (1 << W_ADDR),
    parameter N_BRAM_BYTES = 32
)( 
    input i_clk,
    input i_rx_serial,
    input in_rst,
    input in_start, 
    input i_opcode_sel,
    //output [(COL * (W_DATA + 1))-1 : 0] o_weight_ff_data,
    output [COL-1 : 0] o_weight_ff_dv
);
localparam COL = ((N_SA * COL_SA) > COL_FC) ? (N_SA * COL_SA) : COL_FC;
wire i_start;
assign i_start = ~in_start;

wire i_rst;
assign i_rst = ~in_rst;
wire rx_dv;
wire [W_DATA-1 : 0]rx_byte;

wire [3:0] i_opcode;
assign i_opcode = (i_opcode_sel) ? 4'b1111 : 4'b0000; 
uart_rx#(
    .CLOCKS_PER_BIT(50)
)receiver(
    .i_Clock(i_clk),
    .i_Rst(i_rst),
    .i_RX_Serial(i_rx_serial),
    .o_RX_DV(rx_dv),
    .o_RX_Byte(rx_byte)
);

wire o_empty;
wire [W_ADDR : 0] o_occupants;
wire o_valid;
wire [W_DATA-1 : 0] o_data;
sync_fifo #(
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR)
)external_input_fifo(
    .prog_full_o(),
    .full_o(),
    .empty_o(o_empty),
    .clk_i(i_clk),
    .wr_en_i(rx_dv),
    .rd_en_i(o_rden),
    .wdata(rx_byte),
    .datacount_o(o_occupants),
    .rst_busy(),
    .rdata(o_data),
    .a_rst_i(i_rst),
    .o_valid(o_valid)
);

wire o_rden;

external_ff_rden#(
    .N_SA(1),
    .W_ADDR(W_ADDR),
    .COL(COL)
)external_fifo_rden(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_fifo_empty(o_empty),
    .i_fifo_occupants(o_occupants),
    .o_fifo_read_enable(o_rden)
);

wire [W_DATA-1 : 0] north_data;
wire north_wren_ctrl_enb;
external_sa_input_ctrl#(
    .W_DATA(W_DATA),
    .COL(COL)
)north_array_wren_ctrl_enb(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data_valid(o_valid),
    .i_data(o_data),
    .o_data(north_data),
    .o_wren(north_wren_ctrl_enb)
);

wire [COL-1 : 0] north_wren;
north_array_wren#(
    .COL(COL),
    .N_SA(1)
) weight_ff_wren (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_enb(north_wren_ctrl_enb),
    .o_wren(north_wren)
);

// wire [(COL * (W_DATA + 1))-1 : 0] o_weight_ff_data;
/*
block#(
    .COL(COL),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(RAM_DEPTH),
    .N_SA_CNV(N_SA_CNV),
    .N_SA_FC(N_SA_FC),
    .N_BRAM_BYTES(N_BRAM_BYTES)
)controller_inst(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_start(i_start),
    .i_opcode(i_opcode),
    .i_north_data(north_data),
    .i_north_wren(north_wren),
    .north_array_data(o_weight_ff_data)
);*/
wire [(COL * (W_DATA + 1))-1 : 0] o_weight_ff_data;
top#(
    .N_SA(N_SA),     //number of SA engines
    .COL_SA(COL_SA),   //columns in one SA engine
    .COL_FC(COL_FC),   //columns in FC engine
    .W_FC_CNT(W_FC_CNT),  //image dimension signal width
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(RAM_DEPTH),
    .N_BRAM_BYTES(N_BRAM_BYTES)
)ff_sharing_controller(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_start(i_start),  //trigger for SA read enable controller
    .i_opcode(i_opcode),
    .i_weight_ff_array_data(north_data),
    .i_weight_ff_array_wren(north_wren),
    .o_weight_ff_array_dv(o_weight_ff_dv),
    .o_weight_ff_array_data(o_weight_ff_data)
);
endmodule
