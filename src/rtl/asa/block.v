//systolic array with all the fifo elements to store inputs and outputs of systolic array
module block#(
    parameter ROW = 9,
    parameter COL = 3,
    parameter W_DATA = 8,
    parameter W_ADDR = 8,
    parameter RAM_DEPTH = (1 << W_ADDR),
    parameter TOTAL_BYTES = (ROW * COL)
)(
    input in_clk,
    input in_sel1,
    input in_sel2,
    input in_trigger1,
    input in_trigger2,
    input in_rx_dv,
    input [W_DATA-1 : 0] in_data,
    output [W_DATA-1 : 0] out_column_data,
    output [W_DATA-1 : 0] out_row_data,
    output out_column_dv,
    output out_row_dv
);

wire systolic_array_select;
wire [(COL * W_DATA)-1 : 0] o_north_data;
wire [(ROW * 9)-1 : 0] o_west_data;

//Integration of fifo and controllers to store input data and weights 
i_fifo_design#(
    .ROW(ROW),
    .COL(COL),
    .W_DATA(W_DATA),
    .TOTAL_BYTES(TOTAL_BYTES),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(RAM_DEPTH)
) input_storage (
    .i_clk(in_clk),
    .rx_data_valid(in_rx_dv),
    .in_data(in_data),
    .i_sel_1(in_sel1),
    .i_sel_2(in_sel2),
    .i_trigger_1(in_trigger1),
    .i_trigger_2(in_trigger2),
    .sa_select(systolic_array_select),
    .north_data(o_north_data),
    .west_data(o_west_data)
);

wire [(COL * 32)-1 : 0] o_south_data;
wire [(ROW * 9)-1 : 0] o_east_data;
wire last_row_dv;

//single systolic array block with delay registers
systolic_array#(
    .ROW(ROW),
    .COL(COL),
    .TOTAL_BYTES(TOTAL_BYTES),
    .W_DATA(W_DATA)
) systolic_array_top(
    .in_clk(in_clk),
    .in_sel(systolic_array_select),
    .in_north(o_north_data),
    .in_west(o_west_data),
    .out_east(o_east_data),
    .out_south(o_south_data),
    .last_row_i_data_valid(last_row_dv)
);

wire [W_DATA-1 : 0] tx_col_byte;
wire [W_DATA-1 : 0] tx_row_byte;
wire tx_col_dv;
wire tx_row_dv;

//integration of fifo to store the output partial sums and data from systolic array
o_fifo_design#(
    .ROW(ROW),
    .COL(COL),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(RAM_DEPTH)
) output_storage(
    .i_clk(in_clk),
    .i_last_row_dv(last_row_dv),
    .i_data_32(o_south_data),
    .i_data_8(o_east_data),
    .o_col_data(out_column_data),
    .o_row_data(out_row_data),
    .column_fifo_valid(out_column_dv),
    .row_fifo_valid(out_row_dv),
    .fifo_out_col_rden(),
    .fifo_out_row_rden()
);

endmodule