module psuedo_index_coordinate_v1 #(
    parameter UPPER_BOUND = 28,
    parameter DATA_WIDTH = 8,
    parameter LOWER_BOUND = 1,
    parameter CONV_PadLeft_WIDTH = 3, // Left padding width
    parameter CONV_PadRight_WIDTH = 3, // Right padding width
    parameter CONV_PadTop_WIDTH = 3, // Top padding width
    parameter CONV_PadBottom_WIDTH = 3, // Bottom padding width
    parameter CONV_StartRowSkip_WIDTH = 4, // Start row skip for im2col
    parameter CONV_EndRowSkip_WIDTH = 4 // End row skip for im2col
     ) 
(
    input                                   valid_mat_size,
    input                                   i_start_im2col_index,
    input                                   i_valid_data,
    input                                   clk,
    output [$clog2(UPPER_BOUND)-1:0]        row,
    output [$clog2(UPPER_BOUND)-1:0]        col,
    input  [CONV_StartRowSkip_WIDTH-1:0]     start_row_skip,
    input  [CONV_EndRowSkip_WIDTH-1:0]     end_row_skip,
    input                                   rstn,
    input  [$clog2(UPPER_BOUND)-1:0]        mat_size_col,
    input  [$clog2(UPPER_BOUND)-1:0]        mat_size_row,
    output [$clog2(UPPER_BOUND)-1:0]        pseudo_mat_size_row,
    output [$clog2(UPPER_BOUND)-1:0]        pseudo_mat_size_col,

    output         o_valid_buff,                                        
    output         o_valid_data ,                                        
    output    reg real_im2col_done,
    input         i_stall_on,
    output    reg r_start_im2col,
    input   [CONV_PadRight_WIDTH-1:0]             pad_right, 
    input   [CONV_PadLeft_WIDTH-1:0]              pad_left,  
    input   [CONV_PadTop_WIDTH-1:0]               pad_top,   
    input   [CONV_PadBottom_WIDTH-1:0]            pad_bottom,
    output  pseudo_im2col_start

);

    reg [$clog2(UPPER_BOUND)-1:0]           curr_row = LOWER_BOUND;
    reg [$clog2(UPPER_BOUND)-1:0]           curr_col = LOWER_BOUND;
    reg [$clog2(UPPER_BOUND)-1:0]           r_mat_size_col;
    reg [$clog2(UPPER_BOUND)-1:0]           r_mat_size_row;
    reg                                     r_valid_buff;
    reg                                     r_valid_data;



    assign row = curr_row;
    assign col = curr_col;
    assign o_valid_data = r_valid_data;
    assign o_valid_buff = r_valid_buff;
    assign pseudo_mat_size_row = mat_size_row + pad_top + pad_bottom - start_row_skip - end_row_skip ;
    assign pseudo_mat_size_col = mat_size_col + pad_left + pad_right ;    


    //##############################################################################  
/* - Start the row and column counter (row,col) with (1,1)
   - Increment the column counter by one till 224th column is reached.
   - If column counter reaches to maximum then reset the column counter and 
     increment row counter by one
   - Repeat the above process till both row and column counters reach maximum 
   (i.e., (row,col)=(224,224))*/
//############################################################################## 

    always @(posedge clk) begin
      if(!rstn) begin
          curr_col <= 0;
          curr_row <= 0;
      end 
      else if ( ~i_stall_on) begin 
        if (r_start_im2col | i_valid_data) begin
          if (curr_row == r_mat_size_row && curr_col == r_mat_size_col) begin
            curr_row <= LOWER_BOUND;
            curr_col <= LOWER_BOUND;
          end
          else if (curr_col == r_mat_size_col) begin 
            curr_col <= LOWER_BOUND;       /*curr_col is assigned to 1 if the 
                                           curr_col exceeds the UPPER_BOUND */
            curr_row <= curr_row + 1;      /* meanwhile the curr_row is 
                                        incremented and goes to the next row*/
          end else if (curr_col >= 1 && curr_col <= r_mat_size_col) begin
            curr_col <= curr_col + 1;     /*curr_col is incremented and goes to 
                                            the next col */
            curr_row <= curr_row;
          end 
          else begin
            curr_row <= LOWER_BOUND;
            curr_col <= LOWER_BOUND;
          end     
          end else begin
            curr_row <= 0;
            curr_col <= 0;
          end
        end
    end


    reg pseudo_im2col = 0;
    reg r_pseudo_im2col_start = 0;



  assign pseudo_im2col_start = (start_row_skip == 0) ? i_start_im2col_index :
                           (start_row_skip  > 0) ? r_pseudo_im2col_start :
                           r_pseudo_im2col_start;                  // assigning the pseudo_im2col_start signal based on start_row_skip value

// generating the pseudo_im2col_start signal
always @ (posedge clk) begin

    if (start_row_skip >0) begin
      if (i_start_im2col_index)begin 
        r_pseudo_im2col_start <= 1'b0;
        pseudo_im2col <= 1'b1;
    end

      else if (pseudo_im2col) begin 

        if (curr_row == (start_row_skip-1) && curr_col == mat_size_col-2)begin 
            r_pseudo_im2col_start <= 1'b1;
        end 

        else begin
            r_pseudo_im2col_start <= 1'b0;
        end
    end 
    else begin
        r_pseudo_im2col_start <= 1'b0;
        pseudo_im2col <= 1'b0;
      end
    
  end

end




    reg r_im2col_start_flag = 0;

    always @(posedge clk) begin
      if (i_start_im2col_index) begin
        r_start_im2col <= 1'b1;
        r_im2col_start_flag = 1'b1;
     //   r_mat_size <= mat_size;
      end else if (curr_row == r_mat_size_row && curr_col == r_mat_size_col && ~i_stall_on) begin
        if (r_im2col_start_flag) begin 
          real_im2col_done <= 1'b1;
          r_im2col_start_flag <=1'b0;
        end
        r_start_im2col <= 1'b0;
      end
      else begin
        real_im2col_done <= 1'b0;
      end
    end

//##############################################################################
  always @ (*) begin
  if(!rstn) begin
        r_mat_size_col <= 0;
        r_mat_size_row <= 0;
        {r_valid_data,r_valid_buff} <= {1'd0,1'b0};
        end
    else if (r_start_im2col && valid_mat_size) begin

        r_mat_size_col <= mat_size_col + pad_left + pad_right ;
        r_mat_size_row <= mat_size_row + pad_top + pad_bottom;

        {r_valid_data,r_valid_buff} <= ((curr_row < LOWER_BOUND + pad_top) && (curr_col>=LOWER_BOUND) && (curr_col<=r_mat_size_col)) ? {1'd1,1'b0} :
                                ((curr_col < LOWER_BOUND + pad_left) && (curr_row>=LOWER_BOUND) && (curr_row<=r_mat_size_row)) ? {1'd1,1'b0} : 
                                ((curr_col > r_mat_size_col - pad_right) && (curr_row>=LOWER_BOUND) && (curr_row<=r_mat_size_row)) ? {1'd1,1'b0} :
                                ((curr_row > r_mat_size_row - pad_bottom) && (curr_col>=LOWER_BOUND) && (curr_col<=r_mat_size_col)) ? {1'd1,1'b0} : 
                                ((curr_row == 0)&&(curr_col == 0))? {1'd1,1'b0} : {i_valid_data,1'b1};
      end

      else begin
        r_mat_size_col <= 0;
        r_mat_size_row <= 0;
        {r_valid_data,r_valid_buff} <= {1'd0,1'b0};
      end
    end

    

  endmodule