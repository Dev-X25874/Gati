/*
   The design includes 9x3 systolic array, fifo and controllers for storing
   inputs and outputs of systolic array grid.
*/

module top_module_sa_9x3#(
    parameter ROW = 9,
    parameter COL = 3,
    parameter W_DATA = 8,
    parameter W_ADDR = 8,
    parameter RAM_DEPTH = (1 << W_ADDR),
    parameter TOTAL_BYTES = (ROW * COL)
)(
    input i_clk,
    input i_sel_1,                      //Selects first fifo to store weights into it
    input i_sel_2,                      //Selects second fifo to store data into it
    input i_trigger_1,                  //External trigger for loading data into systolic array's column
    input i_trigger_2,                  //External trigger for loading data into systolic array's row
    input [W_DATA-1:0] data_in,
    output [W_DATA-1:0] col_data_out,
    output [W_DATA-1:0] row_data_out,
    output [COL-1:0] sel_out            
);

wire select;
wire [(COL * 32)-1 :0] sa_weights;
wire [(ROW * 9)-1 :0] sa_data;
wire col_wren_dv;   					/*  Data valid signal of last row's input into the systolic array 
                                            used as write enable signal for fifo array which stores 
                                            systolic array's 32 bit output  */

/*
    Multiple fifo and controllers used for storing data and weights,
    and loads it simultanously into the systolic array grid 
    for avoiding delays during runtime in systolic array
*/
i_fifo_design#(
    .ROW(ROW),
    .COL(COL),
    .W_DATA(W_DATA),
    .TOTAL_BYTES(TOTAL_BYTES),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH (RAM_DEPTH)
) input_data_design (
    .i_clk (i_clk),
    .i_data (data_in),
    .i_sel_1 (i_sel_1),
    .i_sel_2 (i_sel_2),
    .i_trigger_1 (i_trigger_1),
    .i_trigger_2 (i_trigger_2),
    .sa_select (select),
    .north_data (sa_weights),
    .west_data (sa_data)
);

wire [(COL*32)-1:0] o_south_data;
wire [(ROW*9)-1:0] o_east_data;

/*
	Sytolic array module takes in weights and data (matrices), 
    does the operation and gives computed output for NxM rows and columns
*/
systolic_array #(
    .ROW(ROW), 
    .COL(COL), 
    .TOTAL_BYTES(TOTAL_BYTES)
) systolic_array_design (
    .in_clk (i_clk), 
    .in_sel (select), 
    .in_north (sa_weights), 
    .in_west (sa_data), 
    .out_sel (sel_out), 
    .out_east (o_east_data), 
    .out_south (o_south_data),
    .last_row_i_data_valid(col_wren_dv)
);

/*
	Stores the output of systolic array into fifo along with controllers 
    required to handle reading and writting data into fifo
*/
o_fifo_design#(
    .ROW(ROW),
    .COL(COL),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(RAM_DEPTH)
) output_data_design (
    .i_clk(i_clk),
    .i_data_32(o_south_data),
    .i_data_8(o_east_data),
    .o_col_data(col_data_out),
    .o_row_data(row_data_out),
    .i_last_row_dv(col_wren_dv)
);

endmodule

