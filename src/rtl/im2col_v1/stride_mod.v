module stride_mod_v1 #(
    parameter DATA_WIDTH = 8,
    parameter UPPER_BOUND = 224,
    parameter STRIDE = 3,
    parameter N_MOD_STAGES = 8
    )
    (
        input clk,
        input rst,
        input [(UPPER_BOUND)-1:0] row,
        input [(DATA_WIDTH)-1:0] lower_bound_row,
        input [(DATA_WIDTH)-1:0] lower_bound_col,
        input [(UPPER_BOUND)-1:0] col,
        input [STRIDE-1:0] stride,
        output o_mod
    );

    localparam THETA_WIDTH = STRIDE << (N_MOD_STAGES-2);

    wire [$clog2(THETA_WIDTH)-1:0] theta;
    wire [DATA_WIDTH-1:0] mod_row;
    wire [DATA_WIDTH-1:0] mod_col;

    assign theta = stride << (N_MOD_STAGES-2);
   
   // MOD operation for row coordinate
    gen_mod_op_v1 #(.DATA_WIDTH(DATA_WIDTH), .UPPER_BOUND(UPPER_BOUND), .STRIDE(STRIDE), .N_MOD_STAGES(N_MOD_STAGES)) rowdut(
        .clk(clk),
        .rst(rst),
        .crd(row),
        .lower_bound(lower_bound_row),
        .theta(theta),
        .o_partial(mod_row),
        .o_shift()
    );

    // MOD operation for column coordinate
    gen_mod_op_v1 #(.DATA_WIDTH(DATA_WIDTH), .UPPER_BOUND(UPPER_BOUND), .STRIDE(STRIDE), .N_MOD_STAGES(N_MOD_STAGES)) coldut(
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