/*
	Stores input data and weights into fifo by using controllers
    before loading it into systolic array grid, such that, data gets loaded
    in parallel fashion into systolic array's rows and columns.
*/
module i_fifo_design#(
    parameter ROW = 9,
    parameter COL = 3,
    parameter W_DATA = 8,
    parameter TOTAL_BYTES = ROW * COL,
    parameter W_ADDR = 8,
    parameter RAM_DEPTH = (1 << W_ADDR)
)(
    input i_clk,
    input [W_DATA-1:0] i_data,
    input i_sel_1,
    input i_sel_2,
    input i_trigger_1,
    input i_trigger_2,
    output sa_select,
    output [(COL * 32) -1: 0] north_data,
    output [(ROW * 9) -1 : 0] west_data
);


wire [(COL * 32) -1 :0] fifo_col_data;   
wire [(ROW * 9) -1 :0] fifo_row_data;    
wire [COL-1:0] fifo_col_empty;
wire [COL-1:0] fifo_col_rden;
wire [ROW-1:0] fifo_row_empty;
wire [ROW-1:0] fifo_row_rden;

/*
    Includes all the fifo and controllers for storing 
    input data and weights, and loading it in parallel fashion
    into columns and rows of systolic array.
    Fifo and fifo_valid modules can be found in sync FIFO
    and sync FIFO_V directories
*/
    fifo_integration #(
    .ROW(ROW), 
    .COL(COL),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR), 
    .RAM_DEPTH(RAM_DEPTH)
) in_fifo_design (
    .i_clk (i_clk), 
    .fifo_sel_1 (i_sel_1),
    .fifo_sel_2 (i_sel_2),
    .i_data (i_data),
    .i_north_rden (fifo_col_rden),
    .o_north_empty (fifo_col_empty),
    .o_north_full (),
    .i_west_rden (fifo_row_rden),
    .o_west_empty (fifo_row_empty),
    .o_west_full (),
    .out_north_data (fifo_col_data),
    .out_east_data (fifo_row_data)
);

/*
    Reads weights from fifo's array and loads it simultaneously
    into systolic array's columns
*/
controller #(
    .COL(COL),
    .ROW(ROW)
) in_fifo_col_controller (
    .i_clk (i_clk),
    .i_trigger (i_trigger_1),
    .i_data (fifo_col_data),
    .i_fifo_empty (fifo_col_empty),
    .o_fifo_read_enable (fifo_col_rden),
    .o_select (sa_select),
    .o_data (north_data)
);

/*
    Reads data from fifo's array and loads it simultaneously 
    into systolic array's rows
*/
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
