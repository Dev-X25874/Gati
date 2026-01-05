module stride_block_v1 #(
    parameter DATA_WIDTH = 8,
    parameter ROW = 9,
    parameter N_MOD_STAGES = 8,
    parameter CONV_KH_WIDTH = 4,
    parameter CONV_KW_WIDTH = 4,
    parameter UPPER_BOUND = 224,
    parameter STRIDE_COL = 3,
    parameter STRIDE_ROW = 3,
    parameter STRIDE = 3)
    (
        input  clk,
        input  rst,
        input  [(UPPER_BOUND)-1:0] curr_row,
        input  [(UPPER_BOUND)-1:0] curr_col,
        input  [(DATA_WIDTH*ROW)-1:0] lower_bound_row,
        input  [(DATA_WIDTH*ROW)-1:0] lower_bound_col, 
        input  [STRIDE_COL-1:0] stride_col,
        input  [STRIDE_ROW-1:0] stride_row,
        input  [CONV_KH_WIDTH-1:0]   kh,
        input  [CONV_KW_WIDTH-1:0]   kw,
        input  start_SA,
        output [ROW-1:0] valid_stride
    );

    wire [(UPPER_BOUND)-1:0] row;
    wire [(UPPER_BOUND)-1:0] col;
    
    reg bound_gen_done_row = 0; 
    reg bound_gen_done_col = 0;
    
    assign row = curr_row;
    assign col = curr_col;

    // Stride block for each valid_sq row
    genvar sq;
    generate 
        for(sq=0; sq<ROW; sq=sq+1) begin
            stride_mod_v1 #(.DATA_WIDTH(DATA_WIDTH), .UPPER_BOUND(UPPER_BOUND), .STRIDE(STRIDE),.STRIDE_ROW(STRIDE_ROW),.STRIDE_COL(STRIDE_COL),.N_MOD_STAGES(N_MOD_STAGES)) 
            finaldut(
                .clk(clk),
                .rst(rst),
                .row(row),
                .col(col),
                .stride_row(stride_row),
                .stride_col(stride_col),
                .o_mod(valid_stride[sq]),
                .lower_bound_col(lower_bound_col[(DATA_WIDTH*(ROW-sq))-1 -:DATA_WIDTH]),
                .lower_bound_row(lower_bound_row[(DATA_WIDTH*(ROW-sq))-1 -:DATA_WIDTH])
            );
        end
    endgenerate

endmodule