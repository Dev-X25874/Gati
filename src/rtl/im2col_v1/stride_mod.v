module stride_mod_v1 #(
    parameter DATA_WIDTH = 8,
    parameter UPPER_BOUND = 224,
    parameter STRIDE_ROW = 3,
    parameter STRIDE_COL = 3,
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
        input [STRIDE_COL-1:0] stride_col,
        input [STRIDE_ROW-1:0] stride_row,
        
        output o_mod
    );

    localparam THETA_WIDTH = STRIDE << (N_MOD_STAGES-2);

    wire [$clog2(THETA_WIDTH)-1:0] theta_col;
    wire [$clog2(THETA_WIDTH)-1:0] theta_row;
    wire [DATA_WIDTH-1:0] mod_row;
    wire [DATA_WIDTH-1:0] mod_col;

    assign theta_row = stride_row << (N_MOD_STAGES-2);
    assign theta_col = stride_col << (N_MOD_STAGES-2);
   
   // MOD operation for row coordinate
    gen_mod_op_v1 #(.DATA_WIDTH(DATA_WIDTH), .UPPER_BOUND(UPPER_BOUND), .STRIDE(STRIDE), .N_MOD_STAGES(N_MOD_STAGES)) rowdut(
        .clk(clk),
        .rst(rst),
        .crd(row),
        .lower_bound(lower_bound_row),
        .theta(theta_row),
        .o_partial(mod_row),
        .o_shift()
    );

    // MOD operation for column coordinate
    gen_mod_op_v1 #(.DATA_WIDTH(DATA_WIDTH), .UPPER_BOUND(UPPER_BOUND), .STRIDE(STRIDE), .N_MOD_STAGES(N_MOD_STAGES)) coldut(
        .clk(clk),
        .rst(rst),
        .crd(col),
        .lower_bound(lower_bound_col),
        .theta(theta_col),
        .o_partial(mod_col),
        .o_shift()
    );

    assign o_mod = ~(mod_col || mod_row);

endmodule