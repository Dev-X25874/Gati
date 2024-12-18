module stride_mod_v1 #(
    parameter DATA_WIDTH = 8,
    parameter UPPER_BOUND = 224,
    parameter STRIDE = 3)
    (
        input clk,
        input rst,
        input [$clog2(UPPER_BOUND)-1:0] row,
        input [$clog2(UPPER_BOUND)-1:0] lower_bound_row,
        input [$clog2(UPPER_BOUND)-1:0] lower_bound_col,
        input [$clog2(UPPER_BOUND)-1:0] col,
        input [$clog2(STRIDE):0] stride,
        output o_mod
    );

    wire [$clog2(STRIDE*64):0] theta;
    wire [DATA_WIDTH-1:0] mod_row;
    wire [DATA_WIDTH-1:0] mod_col;

    assign theta = stride * 64;
   
   // MOD operation for row coordinate
    gen_mod_op_v1 #(.DATA_WIDTH(DATA_WIDTH), .UPPER_BOUND(UPPER_BOUND), .STRIDE(STRIDE)) rowdut(
        .clk(clk),
        .rst(rst),
        .crd(row),
        .lower_bound(lower_bound_row),
        .theta(theta),
        .o_partial(mod_row),
        .o_shift()
    );

    // MOD operation for column coordinate
    gen_mod_op_v1 #(.DATA_WIDTH(DATA_WIDTH), .UPPER_BOUND(UPPER_BOUND), .STRIDE(STRIDE)) coldut(
        .clk(clk),
        .rst(rst),
        .crd(col),
        .lower_bound(lower_bound_col),
        .theta(theta),
        .o_partial(mod_col),
        .o_shift()
    );

    assign o_mod = ~(mod_col || mod_row);

endmodule
