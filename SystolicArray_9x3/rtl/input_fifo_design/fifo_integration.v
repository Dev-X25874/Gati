/*
    Includes all the fifo that stores input data and weights before 
    loading it into systolic array. 
    Controllers handles the write and read enable signals of fifo.
*/
module fifo_integration #(
    parameter ROW = 9, 
    parameter COL = 3,
    parameter W_DATA = 8,
    parameter W_ADDR = 9, 
    parameter RAM_DEPTH = (1 << W_ADDR)
)(
    input i_clk, 
    input fifo_sel_1,
    input fifo_sel_2,
    input [W_DATA - 1:0] i_data,

    input [COL-1:0] i_north_rden,
    output [COL-1 :0] o_north_empty,
    output [COL - 1 :0] o_north_full,

    input [ROW-1:0] i_west_rden,
    output [ROW - 1 : 0] o_west_empty,
    output [ROW - 1 : 0] o_west_full,

    output [(COL * 32) -1 : 0] out_north_data,
    output [(ROW * 9)-1 : 0] out_east_data
);

wire [W_DATA-1:0] o_weight_1; 
wire [W_DATA -1:0] o_weight_2; 
wire [W_DATA -1:0] o_weight_3;

wire [W_DATA -1:0] o_data_1;
wire [W_DATA -1:0] o_data_2;
wire [W_DATA -1:0] o_data_3;
wire [W_DATA -1:0] o_data_4;
wire [W_DATA -1:0] o_data_5;
wire [W_DATA -1:0] o_data_6;
wire [W_DATA -1:0] o_data_7;
wire [W_DATA -1:0] o_data_8;
wire [W_DATA -1:0] o_data_9;

wire r_dv1;
wire r_dv2;
wire r_dv3;
wire r_dv4;
wire r_dv5;
wire r_dv6;
wire r_dv7;
wire r_dv8;
wire r_dv9;


assign out_north_data[95:64] = o_weight_1;
assign out_north_data[63:32] = o_weight_2;
assign out_north_data [31:0] = o_weight_3;

assign out_east_data = {{r_dv1,o_data_1}, {r_dv2, o_data_2}, {r_dv3, o_data_3},
                        {r_dv4, o_data_4} , {r_dv5, o_data_5} , {r_dv6, o_data_6},
                        {r_dv7, o_data_7}, {r_dv8, o_data_8}, {r_dv9, o_data_9}};    

//Write enable signals for storing weights and data
wire write_en_1; 
wire write_en_2; 

assign write_en_1 = (fifo_sel_1) ? 1'b1 : 1'b0;
assign write_en_2 = (fifo_sel_2) ? 1'b1 : 1'b0;

wire empty_1; 
wire full_1; 
wire [W_DATA -1 :0] fifo_1_o_data;
reg [W_DATA - 1:0] fifo_1_reg = 0;
wire [W_ADDR : 0] occupants_1; 
wire [W_ADDR:0] write_counter;
wire wb_fifo_rden;

//Stores all the input weights
fifo#(
    .DATA_WIDTH(W_DATA), 
    .ADDR_WIDTH(W_ADDR), 
    .RAM_DEPTH(RAM_DEPTH)
) weight_fifo(
    .clk (i_clk),
    .rst_n (1'b1) ,
    .data_in (i_data),
    .we (write_en_1),
    .re (wb_fifo_rden),
    .data_out (fifo_1_o_data),
    .occupants (occupants_1),
    .empty (empty_1),
    .full (full_1)
);    

wire empty_2; 
wire full_2; 
wire [W_DATA -1 :0] fifo_2_o_data; 
wire [W_ADDR : 0] occupants_2;
wire dt_fifo_rden;

//Stores all the input data
fifo#(
    .DATA_WIDTH(W_DATA),
    .ADDR_WIDTH(W_ADDR),
    .RAM_DEPTH(RAM_DEPTH) 
) data_fifo (
    .clk (i_clk),
    .rst_n (1'b1) ,
    .data_in (i_data),
    .we (write_en_2),
    .re (dt_fifo_rden),
    .data_out (fifo_2_o_data),
    .occupants (occupants_2),
    .empty (empty_2),
    .full (full_2)
);

wire sr_enable_1;

//Sending full signal to fifo controller 
wire north_array_full;
wire west_array_full;
assign north_array_full = (o_north_full == 3'd7) ? 1'b1 : 1'b0;
assign west_array_full = (o_west_full == 9'd511) ? 1'b1 : 1'b0;

/*
    Controller handles read enable signal of fifo that stores weights,
    and enables a mux which handles writting weights into fifo array
    that loads weights into columns of systolic array.
*/
fifo_controller 
fifo_rden_col(
    .i_clk (i_clk),
    .i_fifo_empty (empty_1),
    .fifo_array_full(north_array_full),
    .fifo_read_enable (wb_fifo_rden),
    .sr_enable (sr_enable_1)
);    

wire sr_enable_2;

/*
    Controller handles read enable signal of fifo that stores data,
    and enables a mux which handles writting data into fifo array
    that loads data into rows of systolic array.
*/
fifo_controller 
fifo_rden_row(
    .i_clk (i_clk),
    .i_fifo_empty (empty_2),
    .fifo_array_full(west_array_full),
    .fifo_read_enable (dt_fifo_rden),
    .sr_enable (sr_enable_2)
);    

wire [COL-1:0] o_data_sr_1;

/*
    Handles write enable signal of array of fifo
    that stores weights of each column
*/
shift_reg_col #(
    .COL (COL)
)sr_column(
    .i_clk (i_clk),
    .i_enable (sr_enable_1),
    .o_data (o_data_sr_1)
);

wire [ROW-1:0] o_data_sr_2;

/*
    Handles write enable signal of array of fifo 
    that stores data of each row
*/
shift_reg_row #(
    .ROW (ROW)
)sr_row(
    .i_clk (i_clk),
    .i_enable (sr_enable_2),
    . o_data (o_data_sr_2)
);

/*
    Array of fifo stores and load weights simultaneously 
    into all the columns of systolic array.
*/
fifo_north#(
    .W_DATA (W_DATA), 
    .W_ADDR(W_ADDR), 
    .RAM_DEPTH (RAM_DEPTH),
    .ROW (ROW),
    .COL (COL)
)fifo_for_column(
    .i_clk (i_clk),
    .we (o_data_sr_1),
    .i_north_rden(i_north_rden),
    .i_data(fifo_1_o_data),
    .o_data1 (o_weight_1),
    .o_data2 (o_weight_2),
    .o_data3 (o_weight_3),
    .o_north_empty(o_north_empty),
    .o_north_full(o_north_full),
    .o_dv1(),
    .o_dv2(),
    .o_dv3()
);

/*
    Array of fifo stores and load data simultaneously 
    into all the rows of systolic array.
*/
fifo_west#(
    .W_DATA (W_DATA), 
    .W_ADDR (W_ADDR), 
    .RAM_DEPTH (RAM_DEPTH),
    .ROW (ROW),
    .COL (COL)
)fifo_for_row(
    .i_clk (i_clk), 
    .we (o_data_sr_2),
    .i_west_rden(i_west_rden),
    .i_data (fifo_2_o_data),
    .o_data1 (o_data_1),
    .o_data2 (o_data_2),
    .o_data3 (o_data_3),
    .o_data4 (o_data_4),
    .o_data5 (o_data_5),
    .o_data6 (o_data_6),
    .o_data7 (o_data_7),
    .o_data8 (o_data_8),
    .o_data9 (o_data_9),
    .o_west_empty(o_west_empty),
    .o_west_full(o_west_full),
    .o_dv1(r_dv1),
    .o_dv2(r_dv2),
    .o_dv3(r_dv3),
    .o_dv4(r_dv4),
    .o_dv5(r_dv5),
    .o_dv6(r_dv6),
    .o_dv7(r_dv7),
    .o_dv8(r_dv8),
    .o_dv9(r_dv9)
);

endmodule