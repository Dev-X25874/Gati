module index_coordinate_v1 #(
    parameter UPPER_BOUND = 28,
    parameter DATA_WIDTH = 8,
    parameter LOWER_BOUND = 1) 
(
    input                                   valid_mat_size,
//    output                                o_start_im2col_ctrl,
    input                                   i_start_im2col_index,
    input                                   i_valid_data,
    input                                   clk,
    output [$clog2(UPPER_BOUND)-1:0]        row,
    output [$clog2(UPPER_BOUND)-1:0]        col,
    input  [DATA_WIDTH-1:0]                 i_data,
    input                                   rstn,
    output [DATA_WIDTH-1:0]                 o_data,
    input  [$clog2(UPPER_BOUND)-1:0]        mat_size,
    output [$clog2(UPPER_BOUND)-1:0]        o_mat_size_col,
    output [$clog2(UPPER_BOUND)-1:0]        o_mat_size_row,
    input  [3:0]                            zero_pad, //Each bit represents one side of the image,i.e., [3]=top
    input  [1:0]                            zero_padded,//No. of 0's to be padded                                              [2]=right
    output         o_valid_buff,                                         //    [1]=bottom
    output                     o_valid_data ,                                         //    [0]=left
    output    reg o_im2col_done,
    input         i_stall_on


);

    reg [$clog2(UPPER_BOUND)-1:0]           curr_row = LOWER_BOUND;
    reg [$clog2(UPPER_BOUND)-1:0]           curr_col = LOWER_BOUND;
    reg [DATA_WIDTH-1:0]                    r_data;
    reg [$clog2(UPPER_BOUND)-1:0]           r_mat_size_col;
    reg [$clog2(UPPER_BOUND)-1:0]           r_mat_size_row;
    reg                                     r_valid_buff;
    reg                                     r_valid_data;
   // reg [$clog2(UPPER_BOUND)-1:0]           r_mat_size;
    reg                                     r_start_im2col = 0;
   /* reg [2:0]                               p_state = 0;
    wire                                    w_valid_data;
    wire                                    w_start_im2col;*/

    assign row = curr_row;
    assign col = curr_col;
    assign o_data = r_data;
    assign o_valid_data = r_valid_data;
    assign o_valid_buff = r_valid_buff;
    assign o_mat_size_col = r_mat_size_col;
    assign o_mat_size_row = r_mat_size_row;
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
            curr_row <= curr_row;
            curr_col <= curr_col;
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
          o_im2col_done <= 1'b1;
          r_im2col_start_flag <=1'b0;
        end
        r_start_im2col <= 1'b0;
      end
      else begin
        o_im2col_done <= 1'b0;
      end
    end
    
    /*assign o_valid_buff = zero_pad ? ((((curr_row == 1)&&(curr_col == 1)) 
            | ((curr_row == o_mat_size)&&(curr_col == o_mat_size)) 
            | (curr_row == o_mat_size)|(curr_row == 1) 
            | (curr_col == o_mat_size - 1) 
            | (curr_col == o_mat_size)) ? 0 : 1) : 1;
    
    

    assign  {o_valid_data,o_data} = r_start_im2col? (zero_pad ? (((curr_row == LOWER_BOUND) 
            && (curr_col>=LOWER_BOUND) && (curr_col<=o_mat_size)) ?{1'd1,8'd0} :
            ((curr_row == o_mat_size) && (curr_col>=LOWER_BOUND) && (curr_col<=o_mat_size)) ? {1'd1,8'd0} :
            ((curr_col == LOWER_BOUND) && (curr_row>=LOWER_BOUND) && (curr_row<=o_mat_size)) ? {1'd1,8'd0} :
            ((curr_col == o_mat_size) && (curr_row>=LOWER_BOUND) && (curr_row<=o_mat_size)) ? {1'd1,8'd0} : 
            {i_valid_data,i_data}) : {i_valid_data,i_data}) : {1'd0, 8'd0};              

    assign o_mat_size = r_start_im2col? (valid_mat_size ?(zero_pad ? mat_size + 2 : mat_size) : 0) : 0; */

  always @ (*) begin
  if(!rstn) begin
        r_mat_size_col <= 0;
        r_mat_size_row <= 0;
        {r_valid_data,r_data,r_valid_buff} <= {1'd0,8'd0,1'b0};
        end
    else if (r_start_im2col && valid_mat_size) begin
   /*if((curr_col == 0) && (curr_row == 0)) begin
    {r_valid_data,r_data,r_valid_buff} <= {1'd0,8'd0,1'b0};
    end
    else begin*/
      case(zero_pad)  // Different cases of where to padd 0's
      0: begin
        r_mat_size_row <= mat_size;
        r_mat_size_col <= mat_size;
        {r_valid_data,r_data,r_valid_buff} <= {i_valid_data,i_data,1'b1};
      end

      1: begin
        r_mat_size_col <= mat_size + zero_padded;
        r_mat_size_row <= mat_size;
        {r_valid_data,r_data,r_valid_buff} <= ((curr_col < LOWER_BOUND + zero_padded) && (curr_row>=LOWER_BOUND) && (curr_row<=r_mat_size_row)) ? {1'd1,8'd0,1'b0} : 
                                              ((curr_row == 0)&&(curr_col == 0))? {1'd1,8'd0,1'b0} : {i_valid_data,i_data,1'b1};
      end

      2: begin
        r_mat_size_col <= mat_size; 
        r_mat_size_row <= mat_size + zero_padded;
        {r_valid_data,r_data,r_valid_buff} <= ((curr_row > r_mat_size_row - zero_padded) && (curr_col>=LOWER_BOUND) && (curr_col<=r_mat_size_col)) ? {1'd1,8'd0,1'b0} : 
                                              ((curr_row == 0)&&(curr_col == 0))? {1'd1,8'd0,1'b0} : {i_valid_data,i_data,1'b1};
      end

      3: begin
        r_mat_size_col <= mat_size + zero_padded;
        r_mat_size_row <= mat_size + zero_padded;
        {r_valid_data,r_data,r_valid_buff} <= ((curr_col < LOWER_BOUND + zero_padded) && (curr_row>=LOWER_BOUND) && (curr_row<=r_mat_size_row)) ? {1'd1,8'd0,1'b0} : 
                                ((curr_row > r_mat_size_row - zero_padded) && (curr_col>=LOWER_BOUND) && (curr_col<=r_mat_size_col)) ? {1'd1,8'd0,1'b0} : 
                                ((curr_row == 0)&&(curr_col == 0))? {1'd1,8'd0,1'b0} : {i_valid_data,i_data,1'b1};
      end

      4: begin
        r_mat_size_col <= mat_size + zero_padded;
        r_mat_size_row <= mat_size;
        {r_valid_data,r_data,r_valid_buff} <= ((curr_col > r_mat_size_col - zero_padded) && (curr_row>=LOWER_BOUND) && (curr_row<=r_mat_size_row)) ? {1'd1,8'd0,1'b0} : 
                                              ((curr_row == 0)&&(curr_col == 0))? {1'd1,8'd0,1'b0} : {i_valid_data,i_data,1'b1};
      end

      5: begin
        r_mat_size_col <= mat_size + (2*zero_padded);
        r_mat_size_row <= mat_size;
        {r_valid_data,r_data,r_valid_buff} <= ((curr_col < LOWER_BOUND + zero_padded) && (curr_row>=LOWER_BOUND) && (curr_row<=r_mat_size_row)) ? {1'd1,8'd0,1'b0} : 
                                ((curr_col > r_mat_size_col - zero_padded) && (curr_row>=LOWER_BOUND) && (curr_row<=r_mat_size_row)) ? {1'd1,8'd0,1'b0} : 
                                ((curr_row == 0)&&(curr_col == 0))? {1'd1,8'd0,1'b0} : {i_valid_data,i_data,1'b1};
      end

      6: begin
        r_mat_size_col <= mat_size + zero_padded;
        r_mat_size_row <= mat_size + zero_padded;
        {r_valid_data,r_data,r_valid_buff} <= ((curr_row > r_mat_size_row - zero_padded) && (curr_col>=LOWER_BOUND) && (curr_col<=r_mat_size_col)) ? {1'd1,8'd0,1'b0} :
                                ((curr_col > r_mat_size_col - zero_padded) && (curr_row>=LOWER_BOUND) && (curr_row<=r_mat_size_row)) ? {1'd1,8'd0,1'b0} : 
                                ((curr_row == 0)&&(curr_col == 0))? {1'd1,8'd0,1'b0} : {i_valid_data,i_data,1'b1};
      end

      7: begin
        r_mat_size_col <= mat_size + (2*zero_padded);
        r_mat_size_row <= mat_size + zero_padded;
        {r_valid_data,r_data,r_valid_buff} <= ((curr_col < LOWER_BOUND + zero_padded) && (curr_row>=LOWER_BOUND) && (curr_row<=r_mat_size_row)) ? {1'd1,8'd0,1'b0} : 
                                ((curr_col > r_mat_size_col - zero_padded) && (curr_row>=LOWER_BOUND) && (curr_row<=r_mat_size_row)) ? {1'd1,8'd0,1'b0} :
                                ((curr_row > r_mat_size_row - zero_padded) && (curr_col>=LOWER_BOUND) && (curr_col<=r_mat_size_col)) ? {1'd1,8'd0,1'b0} : 
                                ((curr_row == 0)&&(curr_col == 0))? {1'd1,8'd0,1'b0} : {i_valid_data,i_data,1'b1};
      end

      8: begin
        r_mat_size_col <= mat_size;
        r_mat_size_row <= mat_size + zero_padded;
        {r_valid_data,r_data,r_valid_buff} <= ((curr_row < LOWER_BOUND + zero_padded) && (curr_col>=LOWER_BOUND) && (curr_col<=r_mat_size_col)) ? {1'd1,8'd0,1'b0} : 
                                              ((curr_row == 0)&&(curr_col == 0))? {1'd1,8'd0,1'b0} : {i_valid_data,i_data,1'b1};
      end

      9: begin
        r_mat_size_col <= mat_size + zero_padded;
        r_mat_size_row <= mat_size + zero_padded;
        {r_valid_data,r_data,r_valid_buff} <= ((curr_row < LOWER_BOUND + zero_padded) && (curr_col>=LOWER_BOUND) && (curr_col<=r_mat_size_col)) ? {1'd1,8'd0,1'b0} :
                                ((curr_col < LOWER_BOUND + zero_padded) && (curr_row>=LOWER_BOUND) && (curr_row<=r_mat_size_row)) ? {1'd1,8'd0,1'b0} : 
                                ((curr_row == 0)&&(curr_col == 0))? {1'd1,8'd0,1'b0} : {i_valid_data,i_data,1'b1};
      end

      10: begin
        r_mat_size_col <= mat_size;
        r_mat_size_row <= mat_size + (2*zero_padded);
        {r_valid_data,r_data,r_valid_buff} <= ((curr_row < LOWER_BOUND + zero_padded) && (curr_col>=LOWER_BOUND) && (curr_col<=r_mat_size_col)) ? {1'd1,8'd0,1'b0} :
                                ((curr_row > r_mat_size_row - zero_padded) && (curr_col>=LOWER_BOUND) && (curr_col<=r_mat_size_col)) ? {1'd1,8'd0,1'b0} : 
                                ((curr_row == 0)&&(curr_col == 0))? {1'd1,8'd0,1'b0} : {i_valid_data,i_data,1'b1};
      end

      11: begin
        r_mat_size_col <= mat_size + zero_padded;
        r_mat_size_row <= mat_size + (2*zero_padded);
        {r_valid_data,r_data,r_valid_buff} <= ((curr_row < LOWER_BOUND + zero_padded) && (curr_col>=LOWER_BOUND) && (curr_col<=r_mat_size_col)) ? {1'd1,8'd0,1'b0} :
                                ((curr_col < LOWER_BOUND + zero_padded) && (curr_row>=LOWER_BOUND) && (curr_row<=r_mat_size_row)) ? {1'd1,8'd0,1'b0} : 
                                ((curr_row > r_mat_size_row - zero_padded) && (curr_col>=LOWER_BOUND) && (curr_col<=r_mat_size_col)) ? {1'd1,8'd0,1'b0} : 
                                ((curr_row == 0)&&(curr_col == 0))? {1'd1,8'd0,1'b0} : {i_valid_data,i_data,1'b1};
      end

      12: begin
        r_mat_size_col <= mat_size + zero_padded;
        r_mat_size_row <= mat_size + zero_padded;
        {r_valid_data,r_data,r_valid_buff} <= ((curr_row < LOWER_BOUND + zero_padded) && (curr_col>=LOWER_BOUND) && (curr_col<=r_mat_size_col)) ? {1'd1,8'd0,1'b0} :
                                ((curr_col > r_mat_size_col - zero_padded) && (curr_row>=LOWER_BOUND) && (curr_row<=r_mat_size_row)) ? {1'd1,8'd0,1'b0} : 
                                ((curr_row == 0)&&(curr_col == 0))? {1'd1,8'd0,1'b0} : {i_valid_data,i_data,1'b1};
      end

      13: begin
        r_mat_size_col <= mat_size + (2*zero_padded);
        r_mat_size_row <= mat_size + zero_padded;
        {r_valid_data,r_data,r_valid_buff} <= ((curr_row < LOWER_BOUND + zero_padded) && (curr_col>=LOWER_BOUND) && (curr_col<=r_mat_size_col)) ? {1'd1,8'd0,1'b0} :
                                ((curr_col < LOWER_BOUND + zero_padded) && (curr_row>=LOWER_BOUND) && (curr_row<=r_mat_size_row)) ? {1'd1,8'd0,1'b0} : 
                                ((curr_col > r_mat_size_col - zero_padded) && (curr_row>=LOWER_BOUND) && (curr_row<=r_mat_size_row)) ? {1'd1,8'd0,1'b0} : 
                                ((curr_row == 0)&&(curr_col == 0))? {1'd1,8'd0,1'b0} : {i_valid_data,i_data,1'b1};
      end

      14: begin
        r_mat_size_col <= mat_size + zero_padded;
        r_mat_size_row <= mat_size + (2*zero_padded);
        {r_valid_data,r_data,r_valid_buff} <= ((curr_row < LOWER_BOUND + zero_padded) && (curr_col>=LOWER_BOUND) && (curr_col<=r_mat_size_col)) ? {1'd1,8'd0,1'b0} :
                                ((curr_row > r_mat_size_row - zero_padded) && (curr_col>=LOWER_BOUND) && (curr_col<=r_mat_size_col)) ? {1'd1,8'd0,1'b0} :
                                ((curr_col > r_mat_size_col - zero_padded) && (curr_row>=LOWER_BOUND) && (curr_row<=r_mat_size_row)) ? {1'd1,8'd0,1'b0} : 
                                ((curr_row == 0)&&(curr_col == 0))? {1'd1,8'd0,1'b0} : {i_valid_data,i_data,1'b1};
      end

      15: begin
        r_mat_size_col <= mat_size + (2*zero_padded);
        r_mat_size_row <= mat_size + (2*zero_padded);
        {r_valid_data,r_data,r_valid_buff} <= ((curr_row < LOWER_BOUND + zero_padded) && (curr_col>=LOWER_BOUND) && (curr_col<=r_mat_size_col)) ? {1'd1,8'd0,1'b0} :
                                ((curr_col < LOWER_BOUND + zero_padded) && (curr_row>=LOWER_BOUND) && (curr_row<=r_mat_size_row)) ? {1'd1,8'd0,1'b0} : 
                                ((curr_col > r_mat_size_col - zero_padded) && (curr_row>=LOWER_BOUND) && (curr_row<=r_mat_size_row)) ? {1'd1,8'd0,1'b0} :
                                ((curr_row > r_mat_size_row - zero_padded) && (curr_col>=LOWER_BOUND) && (curr_col<=r_mat_size_col)) ? {1'd1,8'd0,1'b0} : 
                                ((curr_row == 0)&&(curr_col == 0))? {1'd1,8'd0,1'b0} : {i_valid_data,i_data,1'b1};
      end

      default: begin 
        r_mat_size_col <= mat_size;
        r_mat_size_row <= mat_size;
        {r_valid_data,r_data,r_valid_buff} <= {i_valid_data,i_data,1'b0};
      end

      endcase
      //end
    end

      else begin
        r_mat_size_col <= 0;
        r_mat_size_row <= 0;
        {r_valid_data,r_data,r_valid_buff} <= {1'd0,8'd0,1'b0};
       // o_valid_buff <= 0;
      end

    end

  endmodule