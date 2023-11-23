/*
    Stores output of systolic array into fifo with the help of
    controllers to handle reading and writing in fifo.
    Fifo and fifo_valid modules can be found in sync FIFO
    and sync FIFO_V directories
*/
module o_fifo_design#(
    parameter ROW = 9,
    parameter COL = 3,
    parameter W_DATA = 8,
    parameter W_ADDR = 8,
    parameter RAM_DEPTH = (1 << W_ADDR)
)(
    input i_clk,
    input i_last_row_dv,
    input [(COL * 32)-1:0] i_data_32,
    input [(ROW * 9)-1 : 0] i_data_8,
    output [W_DATA-1:0] o_col_data,
    output [W_DATA-1:0] o_row_data
);

wire [ROW-1:0] row_fifo_array_empty;
wire [W_DATA -1 : 0] row_data_1;
wire [W_DATA -1 : 0] row_data_2;
wire [W_DATA -1 : 0] row_data_3;
wire [W_DATA -1 : 0] row_data_4;
wire [W_DATA -1 : 0] row_data_5;
wire [W_DATA -1 : 0] row_data_6;
wire [W_DATA -1 : 0] row_data_7;
wire [W_DATA -1 : 0] row_data_8;
wire [W_DATA -1 : 0] row_data_9;

wire [ROW-1:0] row_fifo_array_rden;
wire data_valid_1;
wire data_valid_2;
wire data_valid_3;
wire data_valid_4;
wire data_valid_5;
wire data_valid_6;
wire data_valid_7;
wire data_valid_8;
wire data_valid_9;

wire [8:0] row_mux_data_1;
wire [8:0] row_mux_data_2;
wire [8:0] row_mux_data_3;
wire [8:0] row_mux_data_4;
wire [8:0] row_mux_data_5;
wire [8:0] row_mux_data_6;
wire [8:0] row_mux_data_7;
wire [8:0] row_mux_data_8;
wire [8:0] row_mux_data_9;

assign row_mux_data_1 = {data_valid_1, row_data_1};
assign row_mux_data_2 = {data_valid_2, row_data_2};
assign row_mux_data_3 = {data_valid_3, row_data_3};
assign row_mux_data_4 = {data_valid_4, row_data_4};
assign row_mux_data_5 = {data_valid_5, row_data_5};
assign row_mux_data_6 = {data_valid_6, row_data_6};
assign row_mux_data_7 = {data_valid_7, row_data_7};
assign row_mux_data_8 = {data_valid_8, row_data_8};
assign row_mux_data_9 = {data_valid_9, row_data_9};

wire [ROW-1:0] fifo_row_read_enable;

/*
	Array of fifo that stores output of all the rows
	of systolic array simultaneously.
*/
o_row_fifo_array#(
    .ROW(ROW),
    .COL(COL),
    .W_DATA(W_DATA)
) row_fifo_array (  
    .i_clk (i_clk),
    .i_data (i_data_8),
    .i_read_enable (fifo_row_read_enable),
    .o_data_1 (row_data_1),
    .o_data_2 (row_data_2),
    .o_data_3 (row_data_3),
    .o_data_4 (row_data_4),
    .o_data_5 (row_data_5),
    .o_data_6 (row_data_6),
    .o_data_7 (row_data_7),
    .o_data_8 (row_data_8),
    .o_data_9 (row_data_9),
    .o_empty (row_fifo_array_empty),
    .dv1(data_valid_1),
    .dv2(data_valid_2),
    .dv3(data_valid_3),
    .dv4(data_valid_4),
    .dv5(data_valid_5),
    .dv6(data_valid_6),
    .dv7(data_valid_7),
    .dv8(data_valid_8),
    .dv9(data_valid_9)
);

wire [COL-1:0] col_fifo_array_wren;
wire [W_DATA-1:0] col_1_data;
wire [W_DATA-1:0] col_2_data;
wire [W_DATA-1:0] col_3_data;

wire [W_DATA-1:0] relu_data_out;

wire [8:0] o_fifo_row_data;

/*
	Handles read enable flags of all the fifo in array which stores 
	systolic array's row's output data.
*/
row_data_controller#(
    .ROW(ROW)
) row_fifo_data_controller (
    .i_clk (i_clk),
    .i_fifo_empty (row_fifo_array_empty),
    .i_data_1(row_mux_data_1),
    .i_data_2(row_mux_data_2),
    .i_data_3(row_mux_data_3),
    .i_data_4(row_mux_data_4),
    .i_data_5(row_mux_data_5),
    .i_data_6(row_mux_data_6),
    .i_data_7(row_mux_data_7),
    .i_data_8(row_mux_data_8),
    .i_data_9(row_mux_data_9),
    .o_data(o_fifo_row_data),
    .o_fifo_read_enable (fifo_row_read_enable)
);

/*
	Stores the output of fifo's array that contains output data of 
	systolic array, into one fifo.
*/
fifo_valid 
fifo_out_row (
    .clk (i_clk),
    .rst_n (1'b1),
    .data_in (o_fifo_row_data[7:0]),
    .we(o_fifo_row_data[8]),
    .re(1'b1),
    .data_out(o_row_data),
    .occupants(),
    .empty(out_row_fifo_empty),
    .full(),
    .data_valid()
); 

/*
	Asserts write enable of array of fifo that stores column's output
	of systolic array only, when the output of systolic array is valid. 
*/ 
column_reg_gen#(
    .COL(COL)
) column_reg (
    .i_clk(i_clk),
    .i_data(i_last_row_dv),
    .o_data(col_fifo_array_wren)
);

/*
	Array of relu module, that clips 32 bits of systolic array's
	column output(weights) into 8 bits to store it into fifo.
*/
wire [COL-1:0] relu_data_valid;
col_relu_array#(
.W_DATA(W_DATA),
    .COL(COL)
) relu_array (
    .i_clk (i_clk),
    .data_in (i_data_32),
    .in_data_valid(col_fifo_array_wren),
    .data_out_1 (col_1_data),
    .data_out_2 (col_2_data),
    .data_out_3 (col_3_data),
    .out_data_valid(relu_data_valid)
);

wire [W_DATA -1 :0] col_o_data1;
wire [W_DATA -1 :0] col_o_data2;
wire [W_DATA -1 :0] col_o_data3;

wire [COL-1:0] col_fifo_array_empty;
wire [COL-1:0] col_fifo_array_rden;

wire col_data_valid_1;
wire col_data_valid_2;
wire col_data_valid_3;

wire [8:0] col_mux_data_1;
wire [8:0] col_mux_data_2;
wire [8:0] col_mux_data_3;

assign col_mux_data_1 = {col_data_valid_1, col_o_data1};
assign col_mux_data_2 = {col_data_valid_2, col_o_data2};
assign col_mux_data_3 = {col_data_valid_3, col_o_data3};    

//Output from array of relu blocks is stored into this array of fifo.
o_col_fifo_array#(
    .ROW(ROW),
    .COL(COL),
    .W_DATA(W_DATA)
) col_fifo_array (
    .i_clk (i_clk),
    .i_data1 (col_1_data),
    .i_data2 (col_2_data),
    .i_data3 (col_3_data),
    .i_read_enable (col_fifo_array_rden),
    .i_write_enable (relu_data_valid),
    .o_data_1 (col_o_data1),
    .o_data_2 (col_o_data2),
    .o_data_3 (col_o_data3),
    .o_empty (col_fifo_array_empty),
    .dv1 (col_data_valid_1),
    .dv2 (col_data_valid_2),
    .dv3 (col_data_valid_3)
);

wire [8:0] o_fifo_col_data;
wire o_fifo_wren;

/*
	Handles read enable flags of all the fifo in array which stores 
	systolic array's column's output(weights).
*/
    col_data_controller#(
    .COL(COL)
) col_fifo_data_controller (
    .i_clk (i_clk),
    .i_fifo_empty (col_fifo_array_empty),
    .i_data_1 (col_mux_data_1),
    .i_data_2 (col_mux_data_2),
    .i_data_3 (col_mux_data_3),
    .o_data (o_fifo_col_data),
    .o_fifo_read_enable (col_fifo_array_rden)
);

/*
    Stores the output of fifo's array that contains output data of 
    systolic array, into one fifo.
*/
fifo_valid 
fifo_out_col (
    .clk (i_clk),
    .rst_n (1'b1),
    .data_in (o_fifo_col_data[7:0]),
    .we(o_fifo_col_data[8]),
    .re(1'b1),
    .data_out(o_col_data),
    .occupants(),
    .empty(out_col_fifo_empty),
    .full(),
    .data_valid()
); 
    
endmodule
