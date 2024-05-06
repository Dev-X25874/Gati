/*
    Receives weight matrix serially through UART receiver,
    store it into a fifo and send it into fifo sharing controller.
    Consider this as top module for checking functionality
    of fifo sharing controller on board.
*/
module test_top#(
    parameter W_DATA = 8,
    parameter N_SA = 4,
    parameter COL_SA = 4,
    parameter N_BRAM_BYTES = 32,
    parameter COL_FC = 32,
    parameter W_FC_CNT = 15,
    parameter WEIGHT_FF_DEPTH = 1024,
    parameter SA_OPCODE = 0,
    parameter FC_OPCODE = 4
)(
    input clk,
    input i_rstn,
    input rx_serial,
    input i_start,
    input i_opcode,
    output [(COL_FC * W_DATA)-1 : 0] out_fc_data,
    output [(COL_SA * W_DATA)-1 : 0] out_sa_data,
    output [COL_FC-1 : 0] out_fc_dv,
    output [COL_SA-1 : 0] out_sa_dv
);

localparam WEIGHT_FF_ADDR = $clog2(WEIGHT_FF_DEPTH);

wire [3:0] opcode;
assign opcode = i_opcode ? 4'b1111 : 4'b0000;

wire start;
wire rstn;
assign start = ~i_start;
assign rstn = ~i_rstn;

localparam COL = ((N_SA * COL_SA) > COL_FC) ? (N_SA * COL_SA) : COL_FC;

wire rx_dv;
wire [W_DATA-1 : 0] rx_byte;

//uart receiver
uart_rx#(
    .CLOCKS_PER_BIT(50)
)receiver(
    .i_Clock(clk),
    .i_Rst(~rstn),
    .i_RX_Serial(rx_serial),
    .o_RX_DV(rx_dv),
    .o_RX_Byte(rx_byte)
);

wire rx_ff_dv;
wire [W_DATA-1 : 0] rx_ff_data_out;
//fifo storing data received serially through uart rx
sync_fifo #(
    .W_DATA(W_DATA),
    .W_ADDR(WEIGHT_FF_ADDR)
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
    .a_rst_i(~rstn),
    .o_valid(rx_ff_dv)
);

wire rx_ff_rden;
wire rx_ff_empty;
wire [WEIGHT_FF_ADDR : 0] rx_ff_occ;

//controller to read data from uart rx fifo
rx_ff_rden#(
    .N_SA(1),
    .W_ADDR(WEIGHT_FF_ADDR)
)rx_ff_rden_ctrl(
    .i_clk(clk),
    .i_rstn(rstn),
    .i_fifo_empty(rx_ff_empty),
    .i_fifo_occupants(rx_ff_occ),
    .o_fifo_read_enable(rx_ff_rden)
);

wire [W_DATA-1 : 0] data_rx_fifo_weight_fifo_array;
wire wren_rx_fifo_weight_fifo_array;

//send data from uart rx fifo into fifo sharing controller
weight_ff_array_data#(
    .W_DATA(W_DATA)
)data_rx_weight_ff_array(
    .i_clk(clk),
    .i_rstn(rstn),
    .i_data_valid(rx_ff_dv),
    .i_data(rx_ff_data_out),
    .o_data(data_rx_fifo_weight_fifo_array),
    .o_wren(wren_rx_fifo_weight_fifo_array)
);

wire [COL-1 : 0] weight_ff_array_write_en;
//asserts write enable signal of one fifo at a time (in weight fifo array)
weight_ff_array_wren#(
    .COL(COL)
)weight_ff_array_wren_ctrl(
    .i_clk(clk),
    .i_rstn(rstn),
    .i_enb(wren_rx_fifo_weight_fifo_array),
    .o_wren(weight_ff_array_write_en)
);

//weight fifo array and controller to handle whether to load data into SA or FC block from it
controller#(
    .N_SA(N_SA),            //number of SA engines
    .COL_SA(COL_SA),        //columns in one SA engine
    .COL_FC(COL_FC),        //columns in FC engine
    .W_FC_CNT(W_FC_CNT),    //image dimension signal width
    .W_DATA(W_DATA),
    .WEIGHT_FF_DEPTH(WEIGHT_FF_DEPTH),
    .N_DRAM_BYTES(N_BRAM_BYTES),
    .COL(COL),
    .SA_OPCODE(SA_OPCODE),
    .FC_OPCODE(FC_OPCODE)
)block(
    .i_clk(clk),
    .i_rstn(rstn),
    .i_start(start),        //trigger for SA read enable controller
    .i_opcode(opcode),
    .i_weight_ff_array_data(data_rx_fifo_weight_fifo_array),
    .i_weight_ff_array_wren(weight_ff_array_write_en),
    .out_fc_data(out_fc_data),
    .out_sa_data(out_sa_data),
    .out_fc_dv(out_fc_dv),
    .out_sa_dv(out_sa_dv)
);

endmodule