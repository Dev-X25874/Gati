//top module for single sa engine
module sa_engine#(
    parameter W_DATA = 8,
    parameter W_ADDR = 8,
    parameter COL = 4,
    parameter ROW = 9,
    parameter W_PSUM = 19,
    parameter N_SA = 2,
    parameter RAM_DEPTH = (1 << W_ADDR)
)(
    input i_clk,
    input s_clk,
    input i_rst,
    input i_trigger_1,
    input i_trigger_2,
    input [W_DATA-1 : 0] i_north_data,
    input [COL-1 : 0] i_north_wren,
    input [W_DATA-1 : 0] i_west_data,
    input [ROW-1 : 0] i_west_wren,
    input [COL-1 : 0] i_south_array_rden,
    output [(W_PSUM * COL)-1 : 0] out_partial_sums,
    output [COL-1 : 0] south_empty,
    output [COL-1 : 0] south_data_valid
);

wire [COL-1 : 0] north_rden;
wire [COL-1 : 0] north_dv;
wire [COL-1 : 0] north_empty;
wire [(COL * W_DATA)-1 : 0] north_data;
wire [((W_ADDR + 1) * COL)-1 : 0] north_occupants;

fifo_north#(
    .COL(COL),
    .ROW(ROW),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(RAM_DEPTH)
) north_fifo_array (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(i_north_data),
    .i_read_enable(north_rden),
    .i_write_enable(i_north_wren),
    .o_data(north_data),
    .o_fifo_empty(north_empty),
    .o_fifo_full(),
    .o_fifo_dv(north_dv),
    .o_occupants(north_occupants)
);

wire [(COL * (W_DATA + 1))-1 : 0] o_north_data;

append_dv#(
    .N_DIMENSION(COL),  //number of rows or columns
    .W_DATA(W_DATA)
)north_array_dv(
    .i_data(north_data),
    .i_data_valid(north_dv),
    .o_data(o_north_data)
);

internal_north_rden#(
   .COL(COL),
   .ROW(ROW),
   .W_ADDR(W_ADDR),
   .W_DATA(W_DATA)
) fifo_north_array_controller (
   .i_clk(i_clk),
   .i_rst(i_rst),
   .i_trigger(i_trigger_1),
   .i_fifo_empty(north_empty),
   .o_fifo_read_enable(north_rden),
   .i_fifo_occupants(north_occupants)
);

wire [ROW-1 : 0] west_rden;
wire [ROW-1 : 0] west_empty;
wire[(ROW * W_DATA)-1 : 0] west_data;
wire [ROW-1:0] west_dv;
wire [(((W_ADDR + 1) * ROW) -1): 0] o_west_occupants;

fifo_west#(
    .ROW(ROW),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(RAM_DEPTH)
) west_fifo_array (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(i_west_data),
    .i_write_enable(i_west_wren),
    .i_read_enable(west_rden),
    .o_data(west_data),
    .o_fifo_empty(west_empty),
    .o_fifo_full(),
    .o_fifo_data_valid(west_dv),
    .o_occupants(o_west_occupants)
);

append_dv#(
    .N_DIMENSION(ROW),  //number of rows or columns
    .W_DATA(W_DATA)
)west_array_dv(
    .i_data(west_data),
    .i_data_valid(west_dv),
    .o_data(o_west_data)
);

wire [((W_DATA + 1) * ROW)-1 : 0] o_west_data;

internal_west_rden#(
    .ROW(ROW),
    .W_ADDR(W_ADDR),
    .W_DATA(W_DATA)
) fifo_west_array_controller (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_occupants(o_west_occupants),
    .i_trigger(i_trigger_2),
    .i_fifo_empty(west_empty),
    .o_read_enable(west_rden)
);

//synchronizers for CDC
(* async_reg = "true" *) reg [(COL * (W_DATA + 1))-1 : 0] x1=0,x2=0;
(* async_reg = "true" *) reg [(ROW * (W_DATA + 1))-1 : 0] y1=0,y2=0;
always @(posedge s_clk)
begin 
    x1<=o_north_data;
    x2<=x1;
    
    y1<=o_west_data;
    y2<=y1;
end

wire [(ROW * (W_DATA + 1))-1 : 0] temp;
wire sa_last_row_dv;
wire  [((W_PSUM + 1) * COL)-1 : 0] out_south_data;

systolic_array#(
    .ROW(ROW),
    .COL(COL/2),
    .TOTAL_BYTES((ROW * (COL/2))),
    .W_DATA(W_DATA),
    .W_PSUM(W_PSUM)
) systolic_array_top(
    .in_clk(s_clk),
    .i_rst(i_rst),
    .in_north(x2[((COL) * (W_DATA+1))-1 : ((COL/2) * (W_DATA + 1))]),
    .in_west(y2),
    .out_east(temp),
    .out_south(out_south_data[((COL) * (W_PSUM + 1))-1 : ((COL/2) * (W_PSUM + 1))])
);

booth_pe_grid#(
    .COL(COL/2),
    .ROW(ROW),
    .W_DATA(W_DATA),
    .W_PSUM(W_PSUM)
) booth_sa_block (
    .i_clk(s_clk),
    .i_rst(i_rst),
    .i_weight(x2[((COL/2) * (W_DATA + 1))-1 : 0]),
    .in_data(temp),
    .o_partial_sum(out_south_data[((COL/2) * (W_PSUM + 1))-1 : 0]),
    .o_data() 
);

(* async_reg = "true" *) reg [(COL * (W_PSUM + 1))-1 : 0] b1=0,b2=0;

always@(posedge i_clk)
begin 
    b1<=out_south_data;
    b2<=b1;
end

wire [(COL * W_PSUM)-1 : 0] o_p_sum;
wire [COL-1 : 0] o_ps_data_valid;

rem_dv_array#(
    .COL(COL),
    .W_PSUM(W_PSUM)
) partial_sum_dv (
    .in_data(b2),
    .out_data(o_p_sum),
    .out_data_valid(o_ps_data_valid)
);

fifo_south#(
    .COL(COL),
    .W_DATA(W_PSUM),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(RAM_DEPTH)
) partial_sum_array (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(o_p_sum),
    .i_write_enable(o_ps_data_valid),
    .i_read_enable(i_south_array_rden),
    .o_data(out_partial_sums),
    .o_fifo_empty(south_empty),
    .o_data_valid(south_data_valid)
);

endmodule