module top#(
    parameter W_DATA = 8,
    parameter W_ADDR = 9,
    parameter N_FIFO = 32,
    parameter N_BRAM = 8, //number of brams in one bank
    parameter N_BANK = 4, //total number of bram banks
    parameter W_KERNAL_CNT = 16,
    parameter W_IMG_DIM = 20,
    parameter W_IMG_ROWS = 16
)(
    input clk,
    input i_rst,
    input rx_serial,
    input i_flattening,
    input i_start,
    input i_accumulator_valid,
    input [N_FIFO-1 : 0] i_weight_ff_array_empty,
    input [W_IMG_DIM-1 : 0] i_img_dim,
    output o_done_rden_ctrl,
    output [W_DATA-1 : 0] o_data_mux,
    output o_data_valid
);

//TODO: Invert all single bit input signals.
wire rst;
wire start;
wire flatten;
wire i_acc_valid;

assign rst = ~i_rst;
assign start = ~i_start;
assign flatten = ~i_flattening;
assign i_acc_valid = ~ i_accumulator_valid;

wire rx_dv;
wire [W_DATA-1 : 0] rx_byte;

//uart receiver to serially receive weight matrix
uart_rx#(
    .CLOCKS_PER_BIT(50)
)receiver(
    .i_Clock(clk),
    .i_Rst(rst),
    .i_RX_Serial(rx_serial),
    .o_RX_DV(rx_dv),
    .o_RX_Byte(rx_byte)
);

wire rx_fifo_dv;
wire [W_DATA-1 : 0] rx_fifo_data;
wire rx_fifo_empty;
wire [W_ADDR : 0] rx_fifo_occ;
//satores weights received through uart trx
fifo#(
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR)
)rx_fifo(
    .prog_full_o(),
    .full_o(),
    .empty_o(rx_fifo_empty),
    .clk_i(clk),
    .wr_en_i(rx_dv),
    .rd_en_i(rx_fifo_rden),
    .wdata(rx_byte),
    .datacount_o(rx_fifo_occ),
    .rst_busy(),
    .rdata(rx_fifo_data),
    .a_rst_i(rst),
    .o_valid(rx_fifo_dv)
);

wire rx_fifo_rden;
//handles read enable signal of fifo connected with uart rx
rx_fifo_rden_ctrl#(
    .N_FIFO(N_FIFO),
    .W_ADDR(W_ADDR)
)rx_fifo_read_enable(
    .clk(clk),
    .rst(rst),
    .i_fifo_empty(rx_fifo_empty),
    .i_fifo_occupants(rx_fifo_occ),
    .o_fifo_read_enable(rx_fifo_rden)
);

wire weight_ff_ctrl_enb;
wire [W_DATA-1 : 0] weight_ff_array_data_in;
//send data from single uart rx fifo to array of fifo
weight_fifo_array_data#(
    .W_DATA(W_DATA)
)weight_ff_array_data(
    .clk(clk),
    .rst(rst),
    .i_data_valid(rx_fifo_dv),
    .i_data(rx_fifo_data),
    .o_enable(weight_ff_ctrl_enb),
    .o_data(weight_ff_array_data_in)
);

wire [N_FIFO-1 : 0] weight_ff_array_wren;
//asserts write enable signal of weight fifo array
weight_fifo_array_wren#(
    .N_FIFO(N_FIFO)
)weight_ff_array_wren_ctrl(
    .clk(clk),
    .rst(rst),
    .i_enable(weight_ff_ctrl_enb),
    .o_data(weight_ff_array_wren) 
);

wire [(N_FIFO * W_DATA)-1 : 0] weight_ff_array_data_out;
wire [N_FIFO-1 : 0] weight_ff_array_rden;
wire [N_FIFO-1 : 0] weight_ff_array_empty;
wire [(N_FIFO * (W_ADDR+1))-1 : 0] weight_ff_array_occ;
wire [(N_BANK * N_BRAM)-1 : 0] valid_weight_ff_array_flattening_ctrl;
//each fifo in this array stores an element of each channel
weight_fifo_array#(
    .W_DATA(W_DATA),
    .N_FIFO(N_FIFO),
    .W_ADDR(W_ADDR)
)weight_fifo_array(
    .clk(clk),
    .rst(rst),
    .i_write_enable(weight_ff_array_wren),
    .i_read_enable(weight_ff_array_rden),
    .i_data(weight_ff_array_data_in),
    .o_data(weight_ff_array_data_out),
    .o_occupants(weight_ff_array_occ),
    .o_empty(weight_ff_array_empty),
    .o_valid(valid_weight_ff_array_flattening_ctrl)
);

//asserts read enable signal of weight fifo array
weight_fifo_array_rden#(
    .N_FIFO(N_FIFO),
    .W_ADDR(W_ADDR)
)weight_ff_array_rden_ctrl(
    .clk(clk),
    .rst(rst),
    .i_fifo_empty(weight_ff_array_empty),
    .i_fifo_occupants(weight_ff_array_occ),
    .o_fifo_read_enable(weight_ff_array_rden)
);

block#(
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .N_BRAM(N_BRAM), //number of brams in one bank
    .N_BANK(N_BANK), //total number of bram banks
    .W_KERNAL_CNT(W_KERNAL_CNT),
    .W_IMG_DIM(W_IMG_DIM),
    .W_IMG_ROWS(W_IMG_ROWS)
)integration_block(
    .clk(clk),
    .rst(rst),
    .flatten(flatten),
    .start(start),
    .i_valid(valid_weight_ff_array_flattening_ctrl),
    .i_acc_valid(i_acc_valid),
    .i_weight_ff_array_empty(i_weight_ff_array_empty),
    .i_img_dim(i_img_dim),
    .i_data(weight_ff_array_data_out),
    .o_done_rden_ctrl(o_done_rden_ctrl),
    .o_data_mux(o_data_mux),
    .o_data_valid(o_data_valid)
);

endmodule