/*
    Based on the value of select line, 
    either weights will be loaded into weight buffer,
    or partial sum from previous block will be loaded into next block.
*/

module sel_block#(
    parameter COL = 1,
    parameter ROW = 9,
    parameter W_DATA = 8
)(
    input i_sel,
    input  [(COL * W_DATA)-1:0] i_weight,
    output  [(COL * W_DATA)-1:0] o_weight,
    output o_sel
);

assign o_sel = i_sel;
assign o_weight = (i_sel) ? i_weight : 0;

endmodule