module bound_generation_v1 #(
  parameter DATA_WIDTH = 8,
  parameter UPPER_BOUND = 224, 
  parameter LOWER_BOUND = 1,
  parameter CONV_KW_WIDTH = 4,
  parameter CONV_KH_WIDTH = 4,
  parameter ROW = 9)
  (
  input                               i_valid,
  input  [$clog2(UPPER_BOUND)-1:0]    mat_size_col,
  input  [$clog2(UPPER_BOUND)-1:0]    mat_size_row,     
  input                               clk,
  input  [CONV_KH_WIDTH-1:0]          kh,  // Size of the kernel requied for convolution
  input  [CONV_KW_WIDTH-1:0]          kw,
  input                               rstn,
  input  [$clog2(UPPER_BOUND)-1:0]    curr_row,
  input  [$clog2(UPPER_BOUND)-1:0]    curr_col,
  output [ROW-1:0]                    valid_sq,           
  input  [DATA_WIDTH-1:0]             valid_sq_data_i,   //Input data from the previous block 
  output [DATA_WIDTH-1:0]             valid_sq_data_o,    //Output data
  output                              o_valid,
  input                               i_stall_on,
  input                               r_start_im2col,
  input                               im2col_start,
  input                               start_SA,
  input                               im2col_done
);

  reg [ROW-1:0]                        valid_sq_reg = 0;
  reg [DATA_WIDTH-1:0]                 r_data_i = 0;
  reg [(DATA_WIDTH*ROW)-1:0]           lower_bound_row = 0;
  reg [(DATA_WIDTH*ROW)-1:0]           lower_bound_col = 0;
  reg [(DATA_WIDTH*ROW)-1:0]           upper_bound_row = 0;
  reg [(DATA_WIDTH*ROW)-1:0]           upper_bound_col = 0;
  reg                                  bound_gen_done_row = 0; 
  reg                                  bound_gen_done_col = 0;


  wire [$clog2(UPPER_BOUND)-1:0]          row ;
  wire [$clog2(UPPER_BOUND)-1:0]          col ;
  
  assign row = curr_row;
  assign col = curr_col; 
  
  // Generation of lower_bound_row
  reg [$clog2(ROW) : 0] i,j,k;
  always@(posedge clk) begin
    if(!rstn) begin
      i <= 0;
      j <= 0;
      k <= 0;
      bound_gen_done_row <= 0;
      lower_bound_row <= 0;
    end
    else begin
      if(start_SA) begin 
        bound_gen_done_row <= 0;
        i <= 0;
        j <= 0;
        k <= 0;
        lower_bound_row <= 0;
      end
      else if (!bound_gen_done_row) begin
        if(i<kw*kh) begin
          lower_bound_row[(DATA_WIDTH*(ROW-i))-1 -:DATA_WIDTH] <= k+1;
          i <= i+1;
          if(j<kw-1) begin
            j <= j+1;
            k <= k;
          end
          else begin
            j <= 0;
            k <= k+1;
          end
        end
        else begin
          bound_gen_done_row <= 1;
        end
      end
    end
  end
 
 // Generation of lower_bound_col
  reg [$clog2(ROW) : 0] l,m;
  always@(posedge clk) begin
    if(!rstn) begin
        l <= 0;
        m <= 0;
        bound_gen_done_col <= 0;
        lower_bound_col <= 0;
    end
    else begin
        if(start_SA) begin 
            bound_gen_done_col <= 0;
            l <= 0;
            m <= 0;
            lower_bound_col <= 0;
        end
        else if (!bound_gen_done_col) begin
            if(l<kw*kh) begin
                lower_bound_col[(DATA_WIDTH*(ROW-l))-1 -:DATA_WIDTH] <= m+1;
                l <= l+1;
                if(m<kw-1) m <= m+1;
                else m <= 0;
            end
            else begin
                bound_gen_done_col <= 1;
            end
        end
    end
  end
 
 
 //Generation of upper_bound_row and upper_bound_col
 integer t;
 always@(*) begin
    for(t=0;t<ROW;t=t+1) begin
        upper_bound_row[(DATA_WIDTH*(ROW-t))-1 -:DATA_WIDTH] = (!rstn)? 0 : lower_bound_row[(DATA_WIDTH*(ROW-t))-1 -:DATA_WIDTH] + mat_size_row - kh;
        upper_bound_col[(DATA_WIDTH*(ROW-t))-1 -:DATA_WIDTH] = (!rstn)? 0 : lower_bound_col[(DATA_WIDTH*(ROW-t))-1 -:DATA_WIDTH] + mat_size_col - kw;
    end
 end

integer sq;

always @(posedge clk) begin
  if(!rstn) begin
    valid_sq_reg <= 0;
    r_data_i <= 0;
  end
  else if ( rstn && ~i_stall_on) begin // checking for each of the bounds
    for(sq=0; sq<ROW; sq=sq+1) begin
      if(sq<(kw*kh)) begin
          if (((row >= lower_bound_row[(DATA_WIDTH*(ROW-sq))-1 -:DATA_WIDTH]) && (col >= lower_bound_col[(DATA_WIDTH*(ROW-sq))-1 -:DATA_WIDTH])) && (((row) <= (upper_bound_row[(DATA_WIDTH*(ROW-sq))-1 -:DATA_WIDTH]) && ((col) <= (upper_bound_col[(DATA_WIDTH*(ROW-sq))-1 -:DATA_WIDTH]))))) begin
              valid_sq_reg[sq] <= 1;   // valid_sq is assigned 1 according to the bounds the coordinate falls in
          end
          else begin 
              valid_sq_reg[sq] <= 0;
          end
      end
      else begin
        if (((row >= lower_bound_row[(DATA_WIDTH*(ROW-((kh*kw)-1)))-1 -:DATA_WIDTH]) && (col >= lower_bound_col[(DATA_WIDTH*(ROW-((kh*kw)-1)))-1 -:DATA_WIDTH])) && (((row) <= (upper_bound_row[(DATA_WIDTH*(ROW-((kh*kw)-1)))-1 -:DATA_WIDTH]) && ((col) <= (upper_bound_col[(DATA_WIDTH*(ROW-((kh*kw)-1)))-1 -:DATA_WIDTH]))))) begin
          valid_sq_reg[sq] <= 1;   // valid_sq is assigned 1 according to the bounds the coordinate falls in
      end
      else begin 
          valid_sq_reg[sq] <= 0;
      end
      end
    end
  end

  // make's valid square zero if the stall is one 
  else if (i_stall_on) begin 
    valid_sq_reg <= 0; 
  end 
end


//Generation of im2col_start_flag
reg r_im2col_start_flag = 0;
always@(posedge clk) begin
  if(!rstn) begin
    r_im2col_start_flag <= 0;
  end
  else begin
    if(im2col_start) r_im2col_start_flag <= 1;
    else if(im2col_done) r_im2col_start_flag <= 0;
  end
end

assign o_valid = i_valid;

assign valid_sq = (r_im2col_start_flag) ? valid_sq_reg : 0 ; 


assign valid_sq_data_o = r_data_i;

endmodule