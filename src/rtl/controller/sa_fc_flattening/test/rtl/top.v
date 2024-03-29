module top#(
    parameter W_DATA = 8,
    parameter W_ADDR = 9,
    parameter N_FIFO = 32
)(
    input clk,
    input rst,
    input rx_serial,
    input flatten,
    input start,
    input [N_FIFO-1 : 0] bram_rden,
    output [(N_FIFO * (W_ADDR + 1))-1 : 0] bram_data
);

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
    .o_valid()
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
    .N_FIFO(N_FIFO)
)integration_inst(
    .clk(clk),
    .rst(rst),
    .flatten(flatten),
    .start(start),
    .i_data(weight_ff_array_data_out),
    .bram_array_rden(bram_rden),
    .bram_array_data_out(bram_data)
);

endmodule