//TODO
//1. Add Stall logic 
//2. Remove data in and out  -- DONE
//3. Integrate it 
//4. 
//5. 

module top_im2col_v1 #(
    parameter KERNEL_SIZE = 4,
    parameter UPPER_BOUND = 224,
    parameter LOWER_BOUND = 1,
    parameter DATA_WIDTH = 8,
    parameter STRIDE = 3)
    (
        input                                   i_clk,   
        input                                   rstn, 
        input                                   stall_on,                            // added signal for stalling the module 
        input                                   valid_mat_size,                      // input image matrix size 
        input                                   i_start_im2col_index,                // start signal 
      //input                                   i_valid_data,                        // redundant
      //input  [DATA_WIDTH-1:0]                 i_data,                              // redundant
        input  [3:0]                            zero_pad,                            
        input  [$clog2(KERNEL_SIZE):0]          ksize,                               
        input  [1:0]                            zero_padded,                         // no of zero pad
        input  [$clog2(UPPER_BOUND)-1:0]        i_mat_size,                          // image dimension 
        output [(KERNEL_SIZE*KERNEL_SIZE)-1:0]  valid_sq,                            // valid to im2col Buff     
      //output                                  o_valid,                             // reduntand
      //output [DATA_WIDTH-1:0]                 valid_sq_data_o,                     // redundant
        input  [$clog2(STRIDE):0]               stride,                
        output                                  o_valid_buff                         //               
    );

    wire                                valid;
    wire [$clog2(UPPER_BOUND)-1:0]      mat_size_col;
    wire [$clog2(UPPER_BOUND)-1:0]      mat_size_row;
    wire [DATA_WIDTH-1:0]               data;
    wire [$clog2(UPPER_BOUND)-1:0]      row;
    wire [$clog2(UPPER_BOUND)-1:0]      col;
  //wire [DATA_WIDTH-1:0]               w_data;
    wire [KERNEL_SIZE*KERNEL_SIZE-1:0]  w_valid_sq;
    wire [KERNEL_SIZE*KERNEL_SIZE-1:0]  d_valid_sq;
    wire [KERNEL_SIZE*KERNEL_SIZE-1:0]  w_valid_stride;


    index_coordinate_v1 #(.UPPER_BOUND(UPPER_BOUND), .LOWER_BOUND(LOWER_BOUND), .DATA_WIDTH(DATA_WIDTH)) index_dut(
        .clk(i_clk),
        .rstn(rstn),
        .stall_on(stall_on), // added logic for stalling the design 
      //  .i_data(i_data),
        .i_start_im2col_index(i_start_im2col_index),
        //.i_valid_data(i_valid_data),
        .valid_mat_size(valid_mat_size),
        .zero_pad(zero_pad),
        .zero_padded(zero_padded),
        .mat_size(i_mat_size),
        .o_data(data),
        .row(row),
        .col(col),
        .o_mat_size_col(mat_size_col),
        .o_mat_size_row(mat_size_row),
       // .o_valid_data(valid),
        .o_valid_buff(o_valid_buff)
    );

    bound_generation_v1 #(.UPPER_BOUND(UPPER_BOUND), .LOWER_BOUND(LOWER_BOUND), .DATA_WIDTH(DATA_WIDTH), .KERNEL_SIZE(KERNEL_SIZE)) bound_dut(
        .clk(i_clk),
        .rstn(rstn),
    //    .i_valid(valid),
        .mat_size_col(mat_size_col),
        .mat_size_row(mat_size_row),
      //  .valid_sq_data_i(data),
        .curr_col(col),
        .ksize(ksize),
        .curr_row(row),
        .valid_sq(w_valid_sq)
        //.valid_sq_data_o(w_data),
        //.stride(stride),
      //  .o_valid(o_valid)
    );
    
    // Delay registers to match the initial delay of stride_block
    delay_reg_v1 #(.DATA_WIDTH(DATA_WIDTH), .KERNEL_SIZE(KERNEL_SIZE)) delay_dut(
    .clk(i_clk),
    .rst(rstn),
    .i_valid_sq(w_valid_sq),
  //  .i_data(w_data),
    .o_valid_sq(d_valid_sq)
    //.o_data(valid_sq_data_o)
    );
    
    stride_block_v1 #(.DATA_WIDTH(DATA_WIDTH), .KERNEL_SIZE(KERNEL_SIZE), .UPPER_BOUND(UPPER_BOUND)) stride_dut(
    .clk(i_clk),
    .rst(rstn),
    .stride(stride),
    .curr_col(col),
    .curr_row(row),
    .ksize(ksize),
    .valid_stride(w_valid_stride)
    );
    
    assign valid_sq = d_valid_sq & w_valid_stride;  
    

endmodule
