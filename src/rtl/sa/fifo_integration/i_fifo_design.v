module i_fifo_design#(
    parameter ROW = 9,
    parameter COL = 32,
    parameter W_DATA = 8,
    parameter TOTAL_BYTES = ROW * COL,
    parameter W_ADDR = 8,
    parameter RAM_DEPTH = (1 << W_ADDR)
)(
    input i_clk,
    input rx_data_valid,
    input [W_DATA-1:0] in_data,
    input i_sel_1,
    input i_sel_2,
    input i_trigger_1,
    input i_trigger_2,
    output sa_select,
    output [(COL * 32) -1: 0] north_data,
    output [(ROW * 9) -1 : 0] west_data
);

//input data fifo design
wire [(COL * 32) -1 :0] fifo_col_data;   //data output (column fifo array)
wire [(ROW * 9) -1 :0] fifo_row_data;    //data output (row fifo array)
wire [COL-1:0] fifo_col_empty;
wire [COL-1:0] fifo_col_rden;
wire [ROW-1:0] fifo_row_empty;
wire [ROW-1:0] fifo_row_rden;
wire [COL-1:0] north_array_data_valid;

//fifo design for storing inputs
fifo_integration #(
    .ROW(ROW), 
    .COL(COL),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR), 
    .RAM_DEPTH(RAM_DEPTH)
) in_fifo_design (
    .i_clk (i_clk),
    .i_rx_dv(rx_data_valid), 
    .fifo_sel_1 (i_sel_1),
    .fifo_sel_2 (i_sel_2),
    .i_data (in_data),
    .i_north_rden (fifo_col_rden),
    .o_north_empty (fifo_col_empty),
    .i_west_rden (fifo_row_rden),
    .o_west_empty (fifo_row_empty),
    .out_north_data (fifo_col_data),
    .out_west_data (fifo_row_data),
    .o_north_array_dv(north_array_data_valid)
);

//controller for handling weights coming from fifo into systolic array
controller #(
    .COL(COL),
    .ROW(ROW)
) in_fifo_col_controller (
    .i_clk (i_clk),
    .i_trigger (i_trigger_1),
    .i_data (fifo_col_data),
    .i_fifo_empty (fifo_col_empty),
    .i_data_valid(north_array_data_valid),
    .o_fifo_read_enable (fifo_col_rden),
    .o_select (sa_select),
    .o_data (north_data)
);

//controller for handling data coming from fifo into systolic array
controller_row #(
    .ROW(ROW)
) in_fifo_row_controller (
    .i_clk (i_clk),
    .i_trigger (i_trigger_2),
    .i_fifo_empty (fifo_row_empty),
    .i_data (fifo_row_data),
    .o_data (west_data),
    .o_read_enable (fifo_row_rden)
);

endmodule
