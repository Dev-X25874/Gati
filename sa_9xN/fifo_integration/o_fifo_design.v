module o_fifo_design#(
    parameter ROW = 9,
    parameter COL = 3,
    parameter W_DATA = 8,
    parameter W_ADDR = 8,
    parameter RAM_DEPTH = (1 << W_ADDR)
)(
    input i_clk,
    input i_last_row_dv,
    input [(COL * 32) - 1 : 0] i_data_32,
    input [(ROW * 9) - 1 : 0] i_data_8,
    output [W_DATA - 1 : 0] o_col_data,
    output [W_DATA - 1 : 0] o_row_data,
    output column_fifo_valid,
    output row_fifo_valid
);

//Row fifo array 
wire [ROW-1:0] fifo_row_read_enable;

/*  Fifo of array for storing row's output of systolic array
    no. of fifo in arrray = no. of rows in systolic array   */
wire [ROW-1:0] row_fifo_array_empty;
wire [(ROW * W_DATA)-1:0] o_east_data;
wire [ROW-1:0] o_east_data_valid;

o_row_fifo#(
    .ROW(ROW),
    .W_DATA(W_DATA)
) row_fifo_array (
    .i_clk (i_clk),
    .i_data (i_data_8),
    .i_read_enable (fifo_row_read_enable),
    .o_fifo_empty (row_fifo_array_empty),
    .o_fifo_full (),
    .o_data (o_east_data),
    .o_data_valid (o_east_data_valid)
);

wire [(9 * ROW)-1:0] out_east_data;


out_sa_row#(
    .ROW(ROW),
    .W_DATA(W_DATA)
) sa_row_data (
    .i_data (o_east_data),
    .i_data_valid (o_east_data_valid),
    .o_data (out_east_data)
);


wire [COL-1:0] col_fifo_array_wren;
wire [W_DATA-1:0] col_1_data;
wire [W_DATA-1:0] col_2_data;
wire [W_DATA-1:0] col_3_data;

wire [W_DATA-1:0] relu_data_out;

//Row data controller
wire [8:0] o_fifo_row_data;

/*  Controller for handling reead enable signal of fifo array that stores data of row
    it also fetches data from array of fifo and stores it into one fifo
    and reads data from all the fifo in array one by one    */
wire fifo_row_wren;
row_data_controller#(
    .ROW(ROW)
) row_fifo_data_controller (
    .i_clk (i_clk),
    .i_fifo_empty (row_fifo_array_empty),
    .i_data (out_east_data),
    .o_data (o_fifo_row_data),
    .o_read_enable (fifo_row_read_enable),
    .wren(fifo_row_wren)
);

//Fifo stores all the row's data from fifo array
fifo_valid fifo_out_row (
    .clk (i_clk),
    .rst_n (1'b1),
    .data_in (o_fifo_row_data[7:0]),
    .we(fifo_row_wren),
    .re(1'b1),
    .data_out(o_row_data),
    .occupants(),
    .empty(out_row_fifo_empty),
    .full(),
    .data_valid(row_fifo_valid)
); 

/*  Array of register for storing and handling write enable signal of fifo array 
    that stores 32 bit output of systolic array */
column_reg_gen#(
    .COL(COL)
) column_reg (
    .i_clk(i_clk),
    .i_data(i_last_row_dv),
    .o_data(col_fifo_array_wren)
);

/*  Array of relu blocks 
    it clips 32 bits of data into 8 bits */
wire [COL-1:0] relu_data_valid;
wire [(W_DATA * COL) -1 : 0] o_relu_data;
col_relu_array#(
    .COL(COL),
    .W_DATA(W_DATA)
) relu_array (
    .i_clk (i_clk),
    .i_data_valid (col_fifo_array_wren),
    .i_data (i_data_32),
    .o_data (o_relu_data),
    .o_data_valid (relu_data_valid)
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

//Array of fifo that stores output of relu array block

wire [(W_DATA * COL)-1:0] o_col_array_data;
wire [COL-1:0] col_array_data_valid;

o_col_fifo_array#(
    .COL(COL),
    .W_DATA(W_DATA)
) col_fifo_array (
    .i_clk (i_clk),
    .i_data (o_relu_data),
    .i_write_enable (relu_data_valid),
    .i_read_enable (col_fifo_array_rden),
    .o_data (o_col_array_data),
    .o_fifo_empty (col_fifo_array_empty),
    .o_data_valid (col_array_data_valid)
);

wire [(9 * COL)-1:0] out_south_data;
o_sa_column#(
    .COL(COL),
    .W_DATA(W_DATA)
) sa_column_data (
    .i_clk (i_clk),
    .i_data (o_col_array_data),
    .i_data_valid (col_array_data_valid),
    .o_data (out_south_data)
 );

wire [8:0] o_fifo_col_data;
wire o_fifo_wren;

/*  Controller that fetches data from array of fifo and stores it into one fifo
    it reads data from all the fifo in array one by one */
wire final_wren;
col_data_controller#(
    .COL(COL)
) col_fifo_data_controller (
    .i_clk (i_clk),
    .i_fifo_empty (col_fifo_array_empty),
    .i_data (out_south_data),
    .o_data ( o_fifo_col_data),
    .o_read_enable (col_fifo_array_rden),
    .wren(final_wren)
);

//Output of all the columns are finally stored in this fifo           
fifo_valid 
fifo_out_col (
    .clk (i_clk),
    .rst_n (1'b1),
    .data_in (o_fifo_col_data[7:0]),
    .we(final_wren),
    .re(1'b1),
    .data_out(o_col_data),
    .occupants(),
    .empty(out_col_fifo_empty),
    .full(),
    .data_valid(column_fifo_valid)
); 
    
endmodule
