//Include controllers and fifo used to store outputs of systolic array
module o_fifo_design#(
    parameter ROW = 9,
    parameter COL = 4,
    parameter W_DATA = 8,
    parameter W_ADDR = 8,
    parameter RAM_DEPTH = (1 << W_ADDR)
)(
    input i_clk,
    input i_last_row_dv,
    input [(COL * 32) - 1 : 0] i_data_32,
    input [(ROW * (W_DATA + 1)) - 1 : 0] i_data_8,
    output [W_DATA - 1 : 0] o_col_data,
    output [W_DATA - 1 : 0] o_row_data,
    output column_fifo_valid,
    output row_fifo_valid,
    output fifo_out_col_rden,
    output fifo_out_row_rden
);

wire [ROW-1:0] fifo_row_read_enable;
wire [ROW-1:0] row_fifo_array_empty;
wire [(ROW * W_DATA)-1:0] o_east_data;
wire [ROW-1:0] o_east_data_valid;

//Array of fifo to store systolic array row's outputs
o_row_fifo#(
    .ROW(ROW),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(RAM_DEPTH)
) row_fifo_array (
    .i_clk (i_clk),
    .i_data (i_data_8),
    .i_read_enable (fifo_row_read_enable),
    .o_fifo_empty (row_fifo_array_empty),
    .o_fifo_full (),
    .o_data (o_east_data),
    .o_data_valid (o_east_data_valid)
);

wire [((W_DATA + 1) * ROW)-1:0] out_east_data;
//Appending data valid signal with the output data of row
out_sa_row#(
    .ROW(ROW),
    .W_DATA(W_DATA)
) sa_row_data (
    .i_data (o_east_data),
    .i_data_valid (o_east_data_valid),
    .o_data (out_east_data)
);


wire [COL-1:0] col_fifo_array_wren;
wire [W_DATA-1:0] relu_data_out;
wire [W_DATA : 0] o_fifo_row_data;

//Controll signals to load output data from row fifo array into a single fifo
wire fifo_row_wren;
row_data_controller#(
    .ROW(ROW),
    .W_DATA(W_DATA)
) row_fifo_data_controller (
    .i_clk (i_clk),
    .i_fifo_empty (row_fifo_array_empty),
    .i_data (out_east_data),
    .o_data (o_fifo_row_data),
    .o_read_enable (fifo_row_read_enable),
    .wren(fifo_row_wren)
);

//Stores all the row's data from fifo array
fifo_valid fifo_out_row (
    .clk (i_clk),
    .rst_n (1'b1),
    .data_in (o_fifo_row_data[W_DATA-1 : 0]),
    .we(fifo_row_wren),
    .re(1'b1),
    .data_out(o_row_data),
    .occupants(),
    .empty(out_row_fifo_empty),
    .full(),
    .data_valid(row_fifo_valid)
); 

//Controlls read enable signal of fifo storing row's data output
fifo_re_controller
out_row_ff_re (
    .i_clk(i_clk),
    .i_fifo_empty(out_row_fifo_empty),
    .o_fifo_read_enable(fifo_out_row_rden)
);

//Handles write enable signal of fifo array storing partial sum outputs from systolic array
column_reg_gen#(
    .COL(COL)
) column_reg (
    .i_clk(i_clk),
    .i_data(i_last_row_dv),
    .o_data(col_fifo_array_wren)
);

/*  Array of relu blocks 
    It clips 32 bits of data into 8 bits */
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

wire [COL-1:0] col_fifo_array_empty;
wire [COL-1:0] col_fifo_array_rden;



wire [(W_DATA * COL)-1:0] o_col_array_data;
wire [COL-1:0] col_array_data_valid;
//Array of fifo to store output of relu array block column-wise
o_col_fifo#(
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

//Appends data valid signal with the output of column
wire [((W_DATA + 1) * COL)-1:0] out_south_data;
o_sa_column#(
    .COL(COL),
    .W_DATA(W_DATA)
) sa_column_data (
    .i_clk (i_clk),
    .i_data (o_col_array_data),
    .i_data_valid (col_array_data_valid),
    .o_data (out_south_data)
 );

wire [W_DATA:0] o_fifo_col_data;
wire o_fifo_wren;
wire final_wren;

//Controll signals to load partial sums from column fifo array into a single fifo
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

//Store all the column's data from array          
fifo_valid 
fifo_out_col (
    .clk (i_clk),
    .rst_n (1'b1),
    .data_in (o_fifo_col_data[W_DATA-1 : 0]),
    .we(final_wren),
    .re(fifo_out_col_rden),
    .data_out(o_col_data),
    .occupants(),
    .empty(out_col_fifo_empty),
    .full(),
    .data_valid(column_fifo_valid)
); 

//Controlls read enable signal of fifo storing column's data output
fifo_re_controller
out_col_ff_re (
    .i_clk(i_clk),
    .i_fifo_empty(out_col_fifo_empty),
    .o_fifo_read_enable(fifo_out_col_rden)
);

    
endmodule
