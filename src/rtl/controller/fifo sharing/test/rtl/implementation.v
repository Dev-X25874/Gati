/*
    Receives weight matrix serially through UART receiver,
    store it into a fifo and send it into fifo sharing controller.
    Consider this as top module for implementing the controller on board as
    this is used only for checking the functionality of fifo sharing controller.
*/
module implementation#(
    parameter W_DATA = 8,
    parameter W_ADDR = 9,
    parameter N_SA = 4,
    parameter COL_SA = 4,
    parameter N_BRAM_BYTES = 32,
    parameter COL_FC = 32,
    parameter W_FC_CNT = 15,
    parameter RAM_DEPTH = (1 << W_ADDR)
)(
    input clk,
    input i_rst,
    input rx_serial,
    input i_start,
    input i_opcode,
    output [COL-1 : 0] o_weight_ff_array_dv,
    output [(COL * W_DATA)-1 : 0] o_weight_ff_array_data
);

wire [3:0] opcode;
assign opcode = i_opcode ? 4'b1111 : 4'b0000;

wire start;
wire rst;
assign start = ~i_start;
assign rst = ~i_rst;

localparam COL = ((N_SA * COL_SA) > COL_FC) ? (N_SA * COL_SA) : COL_FC;

wire rx_dv;
wire [W_DATA-1 : 0] rx_byte;

//uart receiver
uart_rx#(
    .CLOCKS_PER_BIT(50)
)receiver(
    .i_Clock(clk),
    .i_Rst(rst),
    .i_RX_Serial(rx_serial),
    .o_RX_DV(rx_dv),
    .o_RX_Byte(rx_byte)
);

wire rx_ff_dv;
wire [W_DATA-1 : 0] rx_ff_data_out;
//fifo storing data received serially through uart rx
sync_fifo #(
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR)
)rx_sync_fifo(
    .prog_full_o(),
    .full_o(),
    .empty_o(rx_ff_empty),
    .clk_i(clk),
    .wr_en_i(rx_dv),
    .rd_en_i(rx_ff_rden),
    .wdata(rx_byte),
    .datacount_o(rx_ff_occ),
    .rst_busy(),
    .rdata(rx_ff_data_out),
    .a_rst_i(rst),
    .o_valid(rx_ff_dv)
);

wire rx_ff_rden;
wire rx_ff_empty;
wire [W_ADDR : 0] rx_ff_occ;
//controller to read data from uart rx fifo
external_ff_rden#(
    .N_SA(1),
    .W_ADDR(W_ADDR)
)rx_ff_rden_ctrl(
    .i_clk(clk),
    .i_rst(rst),
    .i_fifo_empty(rx_ff_empty),
    .i_fifo_occupants(rx_ff_occ),
    .o_fifo_read_enable(rx_ff_rden)
);

wire [W_DATA-1 : 0] north_data;
wire north_wren_en;
//send data from uart rx fifo into fifo sharing controller
external_sa_input_ctrl#(
    .W_DATA(W_DATA)
)weight_ff_array_data(
    .i_clk(clk),
    .i_rst(rst),
    .i_data_valid(rx_ff_dv),
    .i_data(rx_ff_data_out),
    .o_data(north_data),
    .o_wren(north_wren_en)
);

wire [COL-1 : 0] weight_ff_array_wren;
//asserts write enable signal of one fifo at a time (in weight fifo array)
north_array_wren#(
    .COL(COL)
)weight_ff_array_wren_ctrl(
    .i_clk(clk),
    .i_rst(rst),
    .i_enb(north_wren_en),
    .o_wren(weight_ff_array_wren)
);

//weight fifo array and controller to handle whether to load data into SA or FC block from it
controller#(
    .N_SA(N_SA),     //number of SA engines
    .COL_SA(COL_SA),   //columns in one SA engine
    .COL_FC(COL_FC),   //columns in FC engine
    .W_FC_CNT(W_FC_CNT),  //image dimension signal width
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(RAM_DEPTH),
    .N_BRAM_BYTES(N_BRAM_BYTES),
    .COL(COL)
)block(
    .i_clk(clk),
    .i_rst(rst),
    .i_start(start),  //trigger for SA read enable controller
    .i_opcode(opcode),
    .i_weight_ff_array_data(north_data),
    .i_weight_ff_array_wren(weight_ff_array_wren),
    .o_weight_ff_array_dv(o_weight_ff_array_dv),
    .o_weight_ff_array_data(o_weight_ff_array_data)
);

endmodule