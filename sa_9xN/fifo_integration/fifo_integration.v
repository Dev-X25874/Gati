module fifo_integration #(
    parameter ROW = 9, 
    parameter COL = 1,
    parameter W_DATA = 8,
    parameter W_ADDR = 9, 
    parameter RAM_DEPTH = (1 << W_ADDR)
)(
    input i_clk,
    input i_rx_dv,
    input fifo_sel_1,
    input fifo_sel_2,
    input [W_DATA - 1:0] i_data,
    
    input [COL-1:0] i_north_rden,
    output [COL-1 :0] o_north_empty,
    
    input [ROW-1:0] i_west_rden,
    output [ROW - 1 : 0] o_west_empty,
    
    output [(COL * 32) -1 : 0] out_north_data,
    output [(ROW * 9)-1 : 0] out_west_data,
    
    output [COL-1:0] o_north_array_dv
);

// WRITE ENABLE SIGNALS
wire write_en_1; 
wire write_en_2; 

assign write_en_1 = (fifo_sel_1 & i_rx_dv) ? 1'b1 : 1'b0;
assign write_en_2 = (fifo_sel_2 & i_rx_dv) ? 1'b1 : 1'b0;

wire empty_1; 
wire full_1; 
wire [W_DATA -1 :0] fifo_1_o_data;
reg [W_DATA - 1:0] fifo_1_reg = 0;
wire [W_ADDR:0] write_counter;
wire wb_fifo_rden;
wire [W_ADDR : 0] weight_fifo_occupants;
//wire weight_fifo_valid;

wire column_fifo_read_enable;

//fifo stores input weights
fifo_valid #(
    .DATA_WIDTH(W_DATA), 
    .ADDR_WIDTH(W_ADDR), 
    .RAM_DEPTH(RAM_DEPTH)
)weight_fifo(.clk(i_clk),
            .rst_n(1'b1),
            .data_in(i_data),
            .we(write_en_1),
            .re(column_fifo_read_enable),
            .data_out(fifo_1_o_data),
            .occupants(weight_fifo_occupants),
            .empty(empty_1),
            .full(full_1),
            .data_valid()
);
//fifo#(
//    .DATA_WIDTH(W_DATA), 
//    .ADDR_WIDTH(W_ADDR), 
//    .RAM_DEPTH(RAM_DEPTH)
//) weight_fifo(
//    .clk (i_clk),
//    .rst_n (1'b1) ,
//    .data_in (i_data),
//    .we (write_en_1),
//    .re (wb_fifo_rden),
//    .data_out (fifo_1_o_data),
//    .occupants (weight_fifo_occupants),
//    .empty (empty_1),
//    .full (full_1)
//);    

//col_buff_controller#(
//    .W_ADDR(W_ADDR),
//    .COL(COL),
//    .ROW(ROW)
//) controller_1(
//    .i_clk(i_clk),
//    .i_fifo_empty(empty_1),
//    .occupants(weight_fifo_occupants),
//    .o_read_enable(column_fifo_read_enable),
//    .sr_enable(sr_enable_1)
//);

col_buff_controller#(
    .COL(COL),
    .ROW(ROW),
    .W_ADDR(W_ADDR)
) controller_1 (
    .i_clk(i_clk),
    .i_fifo_empty(empty_1),
    .occupants(weight_fifo_occupants),
    .o_read_enable(column_fifo_read_enable),
    .sr_enable(sr_enable_1)
);

wire row_fifo_read_enable;

//col_buff_controller#(
//    .W_ADDR(W_ADDR),
//    .COL(COL),
//    .ROW(ROW)
//) controller_2(
//    .i_clk(i_clk),
//    .i_fifo_empty(empty_2),
//    .occupants(data_fifo_occupants),
//    .o_read_enable(row_fifo_read_enable),
//    .sr_enable(sr_enable_2)
//);

row_buf_controller#(
    .COL(COL),
    .ROW(ROW),
    .W_ADDR(W_ADDR)
) controller_2 (
    .i_clk(i_clk),
    .i_fifo_empty(empty_2),
    .occupants(data_fifo_occupants),
    .o_read_enable(row_fifo_read_enable),
    .sr_enable(sr_enable_2)
);

wire [7:0] fifo_1_col_o_data;

//fifo_valid 
//weight_fifo_buf_in(
//             .clk(i_clk),
//             .rst_n (1'b1),
//             .data_in (fifo_1_o_data),
//             .we(),
//             .re(),
//             .data_out(fifo_1_col_o_data),
//             .occupants(),
//             .empty(),
//             .full(),
//             .data_valid()
//);

wire empty_2; 
wire full_2; 
wire [W_DATA -1 :0] fifo_2_o_data; 
wire [W_ADDR : 0] data_fifo_occupants;
wire dt_fifo_rden;

//fifo stores input data
fifo#(
    .DATA_WIDTH(W_DATA),
    .ADDR_WIDTH(W_ADDR),
    .RAM_DEPTH(RAM_DEPTH) )
data_fifo(
    .clk (i_clk),
    .rst_n (1'b1) ,
    .data_in (i_data),
    .we (write_en_2),
//    .re (dt_fifo_rden),
    .re(row_fifo_read_enable),
    .data_out (fifo_2_o_data),
    .occupants (data_fifo_occupants),
    .empty (empty_2),
    .full (full_2)
);

wire sr_enable_1;    
wire [COL - 1 :0] o_north_full;
//controller for handling read enable signal of fifo having weights  
//fifo_controller_col#(
//    .COL(COL),
//    .ROW(ROW),
//    .W_ADDR(W_ADDR)
//) fifo_rden_col (
//    .i_clk (i_clk),
//    .occupants(weight_fifo_occupants),
//    .i_fifo_empty (),
//    .fifo_array_full (o_north_full),
//    .fifo_read_enable (wb_fifo_rden),
//    .sr_enable ()
//);

wire sr_enable_2;
wire [ROW - 1 : 0] o_west_full;
//controller for handling read enable signal of fifo having data
//fifo_controller_row#(
//    .ROW(ROW),
//    .COL(COL),
//    .W_ADDR(W_ADDR)
//)
//fifo_rden_row(
//    .i_clk (i_clk),
//    .occupants(data_fifo_occupants),
//    .i_fifo_empty (empty_2),
//    .fifo_array_full(o_west_full),
//    .fifo_read_enable (dt_fifo_rden),
//    .sr_enable (sr_enable_2)
//);    

wire [COL-1:0] o_data_sr_1;

//handles write enable signal of array of fifo that stores weights of each column
shift_reg_col #(
    .COL (COL)
)sr_column(
    .i_clk (i_clk),
    .i_enable (sr_enable_1),
  //  .i_fifo_valid(weight_fifo_valid),
    .o_data (o_data_sr_1)
);

wire [ROW-1:0] o_data_sr_2;

//handles write enable signal of array of fifo that stores data of each row
shift_reg_row #(
    .ROW (ROW)
)sr_row(
    .i_clk (i_clk),
    .i_enable (sr_enable_2),
    .o_data (o_data_sr_2)
);

//array of fifo for storing weight of each column
//no. of column of systolic array = no. of fifo in this array

wire [(COL * W_DATA) -1 : 0] o_north_data;
wire [COL-1:0] i_north_array_dv;
//TODO: Correct the logic for write enable assertion
fifo_north#(
    .COL(COL),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR)
) fifo_for_column (
    .i_clk (i_clk),
    .i_data (fifo_1_o_data),
//    .i_data(fifo_1_col_o_data),
    .i_read_enable (i_north_rden),
    .i_write_enable (o_data_sr_1),
    .o_data (o_north_data),
    .o_fifo_empty (o_north_empty),
    .o_fifo_full (o_north_full),
    .o_fifo_dv(i_north_array_dv)
);

in_sa_column_data#(
    .COL(COL),
    .W_DATA(W_DATA)
) i_sa_column (
    .i_data (o_north_data),
    .i_dv(i_north_array_dv),
    .o_data (out_north_data),
    .o_dv(o_north_array_dv)
);

//array of fifo for storing data of each row
//no. of row of systolic array = no. of fifo in row
wire [(ROW * W_DATA) -1 :0] o_west_data;
wire [ROW-1:0] o_west_data_valid;
//TODO: Correct logic for write enable assertion
fifo_west#(
    .ROW(ROW),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(RAM_DEPTH)
) fifo_for_row (
    .i_clk (i_clk),
    .i_data (fifo_2_o_data),
    .i_write_enable (o_data_sr_2),
    .i_read_enable (i_west_rden),
    .o_data (o_west_data),
    .o_fifo_empty (o_west_empty),
    .o_fifo_full (o_west_full),
    .o_fifo_data_valid (o_west_data_valid)
);

in_sa_row_data#(
    .ROW(ROW),
    .W_DATA(W_DATA)
) i_sa_row (
    .i_data (o_west_data),
    .i_data_valid (o_west_data_valid),
    .o_data (out_west_data)
);

endmodule
