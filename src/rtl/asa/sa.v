//9xN systolic array design
module sa#(
    parameter N_COLS = 1,
    parameter N_ROWS = 9,
    parameter W_DATA = 8
)(
    input i_clk,
    input i_sel,
    input  [(N_COLS * W_DATA)-1:0] i_weights,
    input  [(N_ROWS * (W_DATA + 1))-1 : 0] i_data,
    output  [(N_COLS * 32)-1 : 0] o_partial_sums,
    output  [(N_ROWS * (W_DATA + 1)) -1 : 0] o_data
);

//Controlls when to load weights into pe grid
sel_block #(
    .COL(N_COLS),
    .ROW(N_ROWS),
    .W_DATA(W_DATA)
) top_mux(
    .i_sel(i_sel),
    .i_weight(i_weights),
    .o_weight(north_weight),
    .o_sel(select)
);

wire select;
wire signed [(N_COLS * W_DATA)-1 : 0] north_weight;

//Array of processing elements
pe_grid#(
    .COL(N_COLS),
    .ROW(N_ROWS),
    .W_DATA(W_DATA)
) pe_array(
    .i_clk(i_clk),
    .i_sel(select),
    .i_weight(north_weight),
    .in_data(i_data),
    .o_partial_sum(o_partial_sums),
    .o_select(),
    .o_data(o_data)
);



endmodule