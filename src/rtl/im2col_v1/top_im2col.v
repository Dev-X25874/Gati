
module top_im2col_v1 #(
    parameter UPPER_BOUND = 224,
    parameter LOWER_BOUND = 1,
    parameter CONV_KW_WIDTH = 4,
    parameter CONV_KH_WIDTH = 4,
    parameter DATA_WIDTH = 8,
    parameter STRIDE = 3,
    parameter ROW = 9,
    parameter CONV_PadLeft_WIDTH = 3, // Left padding width
    parameter CONV_PadRight_WIDTH = 3, // Right padding width
    parameter CONV_PadTop_WIDTH = 3, // Top padding width
    parameter CONV_PadBottom_WIDTH = 3)
    (
        input                                  clk_in,
        input                                  rstn,
        input                                  valid_mat_size,
        input                                  i_start_im2col_index,
        input                                  i_valid_data,
        input  [DATA_WIDTH-1:0]                i_data,
        input  [3:0]                           zero_pad,   // Zero Pad Side
        input  [CONV_KW_WIDTH-1:0]             kw,
        input  [CONV_KH_WIDTH-1:0]             kh,
        //input  [CONV_PAD_WIDTH-1:0]            zero_padded,
        input [CONV_PadLeft_WIDTH-1:0] conv_pad_left,
        input [CONV_PadRight_WIDTH-1:0] conv_pad_right,
        input [CONV_PadTop_WIDTH-1:0] conv_pad_top,
        input [CONV_PadBottom_WIDTH-1:0] conv_pad_bottom,
        
        input  [$clog2(UPPER_BOUND)-1:0]       i_mat_size_col,
        input  [$clog2(UPPER_BOUND)-1:0]       i_mat_size_row,
        output [ROW-1:0]                       valid_sq,           
        output                                 o_valid,
        output [DATA_WIDTH-1:0]                valid_sq_data_o,
        input  [STRIDE-1:0]                    stride,
        output                                 o_valid_buff,
        output                                 o_im2col_done,
        input                                  start_SA,
        input                                  i_stall_on,
        output [$clog2(UPPER_BOUND)-1:0]       o_row,
        output [$clog2(UPPER_BOUND)-1:0]       o_col

    );

    wire valid;
    wire [$clog2(UPPER_BOUND)-1:0] mat_size_col;
    wire [$clog2(UPPER_BOUND)-1:0] mat_size_row;
    wire [DATA_WIDTH-1:0] data;
    wire [$clog2(UPPER_BOUND)-1:0] w_row;
    wire [$clog2(UPPER_BOUND)-1:0] w_col;
    wire [DATA_WIDTH-1:0] w_data;
    wire [ROW-1:0] w_valid_sq;
    wire [ROW-1:0] d_valid_sq;
    wire [ROW-1:0] w_valid_stride;

    
    assign o_row = w_row;
    assign o_col = w_col;


    index_coordinate_v1 #(.UPPER_BOUND(UPPER_BOUND), .LOWER_BOUND(LOWER_BOUND), .DATA_WIDTH(DATA_WIDTH), 
    .CONV_PadLeft_WIDTH(CONV_PadLeft_WIDTH),
    .CONV_PadRight_WIDTH(CONV_PadRight_WIDTH),
    .CONV_PadTop_WIDTH(CONV_PadTop_WIDTH),
    .CONV_PadBottom_WIDTH(CONV_PadBottom_WIDTH)) 
    index_dut(
        .clk(clk_in),
        .rstn(rstn),
        .i_data(i_data),
        .i_start_im2col_index(i_start_im2col_index),
        .i_valid_data(i_valid_data),
        .valid_mat_size(valid_mat_size),
        .zero_pad(zero_pad),
        //.zero_padded(zero_padded),

        .pad_left(conv_pad_left),
        .pad_right(conv_pad_right),
        .pad_top(conv_pad_top),
        .pad_bottom(conv_pad_bottom),

        .mat_size_col(i_mat_size_col),
        .mat_size_row(i_mat_size_row),
        .o_data(data),
        .row(w_row),
        .col(w_col),
        .o_mat_size_col(mat_size_col),
        .o_mat_size_row(mat_size_row),
        .o_valid_data(valid),
        .o_valid_buff(o_valid_buff),
        .o_im2col_done(o_im2col_done),
        .i_stall_on   (i_stall_on),
        .r_start_im2col (r_start_im2col)
    );

    wire r_start_im2col;

    bound_generation_v1 #(.UPPER_BOUND(UPPER_BOUND), .LOWER_BOUND(LOWER_BOUND), .DATA_WIDTH(DATA_WIDTH), .ROW(ROW), .CONV_KH_WIDTH(CONV_KH_WIDTH), .CONV_KW_WIDTH(CONV_KW_WIDTH)) bound_dut(
        .clk(clk_in),
        .rstn(rstn),
        .i_valid(valid),
        .mat_size_col(mat_size_col),
        .mat_size_row(mat_size_row),
        .valid_sq_data_i(data),
        .curr_col(w_col),
        .kw(kw),
        .kh(kh),
        .curr_row(w_row),
        .valid_sq(w_valid_sq),
        .valid_sq_data_o(w_data),
        .o_valid(o_valid),
        .i_stall_on(i_stall_on),
        .r_start_im2col(r_start_im2col),
        .im2col_start(i_start_im2col_index),
        .start_SA(start_SA),
        .im2col_done(o_im2col_done)
    );
    
    // Delay registers to match the initial delay of stride_block
    delay_reg_v1 #(.DATA_WIDTH(DATA_WIDTH), .ROW(ROW)) delay_dut(
    .clk(clk_in),
    .rst(rstn),
    .i_valid_sq(w_valid_sq),
    .i_data(w_data),
    .o_valid_sq(d_valid_sq),
    .o_data(valid_sq_data_o)
    );
    
    stride_block_v1 #(.DATA_WIDTH(DATA_WIDTH), .ROW(ROW), .CONV_KH_WIDTH(CONV_KH_WIDTH), .CONV_KW_WIDTH(CONV_KW_WIDTH), .UPPER_BOUND(UPPER_BOUND), .STRIDE(STRIDE)) stride_dut(
    .clk(clk_in),
    .rst(rstn),
    .stride(stride),
    .curr_col(w_col),
    .curr_row(w_row),
    .kw(kw),
    .kh(kh),
    .start_SA(start_SA),
    .valid_stride(w_valid_stride)
    );
    
    assign valid_sq = (stride == 'd1)? d_valid_sq : (d_valid_sq & w_valid_stride) ;  
    

endmodule