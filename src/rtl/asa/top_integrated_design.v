//top module for single 9XN systolic array design
module top_integrated_design#(
    parameter ROW = 9,
    parameter COL = 1,
    parameter W_DATA = 8,
    parameter W_ADDR = 9,
    parameter RAM_DEPTH = (1 << W_ADDR),
    parameter TOTAL_BYTES = (ROW * COL)
)(
    input i_clk,
    //input i_rx_serial,
    input i_trigger_1,
    input i_trigger_2,
    input i_sel_1,
    input i_sel_2,
    input [W_DATA-1:0] rx_byte,
    output [W_DATA-1:0] tx_col_byte,
    output [W_DATA-1:0] tx_row_byte,
    output tx_col_dv,
    output tx_row_dv
    //output o_tx_serial_column,
    //output o_tx_serial_row
    //output [4:0] o_row_trigger_counter
);

/*
wire rx_dv;
wire [W_DATA-1 : 0] rx_byte;

uart_rx#(
    .CLOCKS_PER_BIT(40)
) receiver (
    .i_Clock(i_clk),
    .i_RX_Serial(i_rx_serial),
    .o_RX_DV(rx_dv),
    .o_RX_Byte(rx_byte)
);*/

wire select1;
wire select2;
assign select1 = ~i_sel_1;
assign select2 = ~i_sel_2;

wire systolic_array_select;
wire [(COL * W_DATA)-1 : 0] o_north_data;
wire [(ROW * 9)-1 : 0] o_west_data;

i_fifo_design#(
    .ROW(ROW),
    .COL(COL),
    .W_DATA(W_DATA),
    .TOTAL_BYTES(TOTAL_BYTES),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(RAM_DEPTH)
) input_storage (
    .i_clk(i_clk),
    .rx_data_valid(rx_dv),
    .in_data(rx_byte),
    .i_sel_1(select1),
    .i_sel_2(select2),
    .i_trigger_1(i_trigger_1),
    .i_trigger_2(i_trigger_2),
    .sa_select(systolic_array_select),
    .north_data(o_north_data),
    .west_data(o_west_data)
   // .o_serial_debug_data_1(),
   // .o_serial_debug_data_2(),
    //.row_trigger_counter(o_row_trigger_counter)
);

wire [(COL * 32)-1 : 0] o_south_data;
wire [(ROW * 9)-1 : 0] o_east_data;
wire last_row_dv;

systolic_array#(
    .ROW(ROW),
    .COL(COL),
    .TOTAL_BYTES(TOTAL_BYTES)
) systolic_array_top(
    .in_clk(i_clk),
    .in_sel(systolic_array_select),
    .in_north(o_north_data),
    .in_west(o_west_data),
    .out_east(o_east_data),
    .out_south(o_south_data),
    .last_row_i_data_valid(last_row_dv)
);

//wire [W_DATA-1 : 0] tx_col_byte;
//wire [W_DATA-1 : 0] tx_row_byte;
//wire tx_col_dv;
//wire tx_row_dv;

o_fifo_design#(
    .ROW(ROW),
    .COL(COL),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(RAM_DEPTH)
) output_storage(
    .i_clk(i_clk),
    .i_last_row_dv(last_row_dv),
    .i_data_32(o_south_data),
    .i_data_8(o_east_data),
    .o_col_data(tx_col_byte),
    .o_row_data(tx_row_byte),
    .column_fifo_valid(tx_col_dv),
    .row_fifo_valid(tx_row_dv),
    .fifo_out_col_rden(),
    .fifo_out_row_rden()
);
/*
uart_tx 
  #(.CLKS_PER_BIT(40))
   transmitter_col (
   .i_Rst_L(1'b1),
   .i_Clock(i_clk),
   .i_TX_DV(tx_col_dv),
   .i_TX_Byte(tx_col_byte), 
   .o_TX_Active(),
   .o_TX_Serial(o_tx_serial_column),
   .o_TX_Done()
);

uart_tx 
  #(.CLKS_PER_BIT(40))
   transmitter_row (
   .i_Rst_L(1'b1),
   .i_Clock(i_clk),
   .i_TX_DV(tx_row_dv),
   .i_TX_Byte(tx_row_byte), 
   .o_TX_Active(),
   .o_TX_Serial(o_tx_serial_row),
   .o_TX_Done()
);
*/
endmodule
