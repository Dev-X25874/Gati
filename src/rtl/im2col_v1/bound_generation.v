module bound_generation_v1 #(
  parameter DATA_WIDTH = 8,
  parameter UPPER_BOUND = 224, 
  parameter LOWER_BOUND = 1,
 // parameter MAX_VALID_SQ = 9,
 // parameter STRIDE = 2,
  parameter KERNEL_SIZE = 4)
 // parameter IMAGE_SIZE = 224)
  (
  input                               i_valid,
  input  [$clog2(UPPER_BOUND)-1:0]    mat_size_col,
  input  [$clog2(UPPER_BOUND)-1:0]    mat_size_row,     
  input                               clk,
  input  [$clog2(KERNEL_SIZE):0]      ksize,  // Size of the kernel requied for convolution
  input                               rstn,
  input  [$clog2(UPPER_BOUND)-1:0]    curr_row,
  input  [$clog2(UPPER_BOUND)-1:0]    curr_col,
  output [(KERNEL_SIZE*KERNEL_SIZE)-1:0]  valid_sq,           
  input  [DATA_WIDTH-1:0]             valid_sq_data_i,   //Input data from the previous block 
  output [DATA_WIDTH-1:0]             valid_sq_data_o,    //Output data
  output                              o_valid,
  input                               i_stall_on
  //input  [$clog2(STRIDE):0]           stride
);

  reg [(KERNEL_SIZE*KERNEL_SIZE)-1:0]  valid_sq_reg = 0;
  reg [DATA_WIDTH-1:0]                 r_data_i = 0;
  //reg [DATA_WIDTH-1:0]              r2_data_i = 0;
  wire [$clog2(UPPER_BOUND)-1:0] lower_bound_row      [KERNEL_SIZE-1:0];
 // reg  [$clog2(UPPER_BOUND)-1:0] upper_bound_row      [KERNEL_SIZE-1:0];
  wire [$clog2(UPPER_BOUND)-1:0] lower_bound_col      [(KERNEL_SIZE*KERNEL_SIZE)-1:0];
 // reg  [$clog2(UPPER_BOUND)-1:0] upper_bound_col      [(KERNEL_SIZE*KERNEL_SIZE)-1:0];
 reg [(DATA_WIDTH*KERNEL_SIZE)-1:0] upper_bound_row;
 reg [(DATA_WIDTH*KERNEL_SIZE*KERNEL_SIZE)-1:0] upper_bound_col;


  wire [$clog2(UPPER_BOUND)-1:0]          row ;
  wire [$clog2(UPPER_BOUND)-1:0]          col ;
 // reg  [$clog2(UPPER_BOUND)-1:0]    r_mat_size_col;
 // reg  [$clog2(UPPER_BOUND)-1:0]    r_mat_size_row;
  
  assign row = curr_row;
  assign col = curr_col; 
  
  /*always @ (posedge clk) begin
  r_mat_size_col <= mat_size_col;
  r_mat_size_row <= mat_size_row; 
  end*/
  

 // reg[$clog2(KERNEL_SIZE):0] i,j;
 // initial begin
  genvar i,j;
  generate
    for(i=0; i<KERNEL_SIZE; i=i+1) begin  //Generating bounds for eaxh valid_sq fifo
      assign  lower_bound_row[i] = i + 1;
     // assign  UPPER_BOUND_ROW[i] = mat_size_row - KERNEL_SIZE + i + 1;
        for(j=0; j<KERNEL_SIZE; j=j+1) begin
          assign  lower_bound_col[j + KERNEL_SIZE*(i)] = j + 1;
       //   assign  UPPER_BOUND_COL[j+KERNEL_SIZE*(i)] = mat_size_col - KERNEL_SIZE + j + 1;
        end
       // j=1;
    end
  endgenerate
  //  i=1;
 // end
 
 generate
 for(i=0; i<KERNEL_SIZE; i=i+1) begin
 always @ (posedge clk) begin
 upper_bound_row[(DATA_WIDTH*(KERNEL_SIZE-i))-1 -:DATA_WIDTH] = (!rstn)? 0:lower_bound_row[i] + mat_size_row - ksize;
 end
 for(j=0; j<KERNEL_SIZE; j=j+1) begin
 always @ (posedge clk) begin
 upper_bound_col[(DATA_WIDTH*((KERNEL_SIZE*KERNEL_SIZE)-(j + KERNEL_SIZE*(i))))-1 -:DATA_WIDTH] = (!rstn)? 0:lower_bound_col[j + KERNEL_SIZE*(i)] + mat_size_col - ksize;
 end
 end
 end
 endgenerate

integer k,l;

always @(posedge clk) begin
  if(!rstn) begin
    valid_sq_reg <= 0;
    r_data_i <= 0;
  end
  else if ( rstn && ~i_stall_on) begin // checking for each of the bounds
      for(k=0; k<KERNEL_SIZE; k=k+1) begin
     // upper_bound_row[(DATA_WIDTH*(KERNEL_SIZE-k))-1 -:DATA_WIDTH] = lower_bound_row[k] + r_mat_size_row - ksize;
        for(l=0; l<KERNEL_SIZE; l=l+1) begin
       // upper_bound_col[(DATA_WIDTH*((KERNEL_SIZE*KERNEL_SIZE)-(l + KERNEL_SIZE*(k))))-1 -:DATA_WIDTH] = lower_bound_col[l + KERNEL_SIZE*(k)] + r_mat_size_col - ksize;
            if(k < ksize) begin
                if(l < ksize) begin
                    if (((row >= lower_bound_row[k]) && (col >= lower_bound_col[l + KERNEL_SIZE*(k)])) && (((row) <= (upper_bound_row[(DATA_WIDTH*(KERNEL_SIZE-k))-1 -:DATA_WIDTH]) && ((col) <= (upper_bound_col[(DATA_WIDTH*((KERNEL_SIZE*KERNEL_SIZE)-(l + KERNEL_SIZE*(k))))-1 -:DATA_WIDTH]))))) begin
                        valid_sq_reg[l + ksize*(k)] <= 1;   // valid_sq is assigned 1 according to the bounds the coordinate falls in
                    end
                    else begin 
                        valid_sq_reg[l + ksize*(k)] <= 0;
                    end
                end
                else begin  //For ksize less than KERNEL_SIZE
                    if (((row >= lower_bound_row[ksize - 1]) && (col >= lower_bound_col[ksize - 1])) && (((row) <= (upper_bound_row[(DATA_WIDTH*(KERNEL_SIZE-(ksize - 1)))-1 -:DATA_WIDTH])) && ((col) <= (upper_bound_col[(DATA_WIDTH*((KERNEL_SIZE*KERNEL_SIZE)-(ksize - 1)))-1 -:DATA_WIDTH])))) begin
                        valid_sq_reg[k + ksize*(l)] <= 1;   // valid_sq is assigned 1 according to the bounds the coordinate falls in  
                    end
                    else begin 
                        valid_sq_reg[k + ksize*(l)] <= 0;
                    end
                end
            end
            else begin      //For ksize less than KERNEL_SIZE
                if (((row >= lower_bound_row[ksize - 1]) && (col >= lower_bound_col[ksize - 1])) && (((row) <= (upper_bound_row[(DATA_WIDTH*(KERNEL_SIZE-(ksize - 1)))-1 -:DATA_WIDTH])) && ((col) <= (upper_bound_col[(DATA_WIDTH*((KERNEL_SIZE*KERNEL_SIZE)-(ksize - 1)))-1 -:DATA_WIDTH])))) begin
                    valid_sq_reg[l + KERNEL_SIZE*(k)] <= 1;  // valid_sq is assigned 1 according to the bounds the coordinate falls in 
                end
                else begin 
                    valid_sq_reg[l + KERNEL_SIZE*(k)] <= 0;
                end
            end
            r_data_i <= valid_sq_data_i;
        end
       //i// l=0;
      end
    //  k=0;
  end

  // make's valid square zero if the stall is one 
  else if (i_stall_on) begin 
    valid_sq_reg <= 0; 
  end 
end

assign o_valid = i_valid;
assign valid_sq = valid_sq_reg; 
assign valid_sq_data_o = r_data_i;

endmodule