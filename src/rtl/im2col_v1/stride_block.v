module stride_block_v1 #(
    parameter DATA_WIDTH = 8,
    parameter ROW = 9,
    parameter CONV_KH_WIDTH = 4,
    parameter CONV_KW_WIDTH = 4,
    parameter UPPER_BOUND = 224,
    parameter STRIDE = 3)
    (
        input clk,
        input rst,
        input  [(UPPER_BOUND)-1:0] curr_row,
        input  [(UPPER_BOUND)-1:0] curr_col,
        input  [(DATA_WIDTH*ROW)-1:0] lower_bound_row,
        input  [(DATA_WIDTH*ROW)-1:0] lower_bound_col,
        input  [STRIDE-1:0]        stride, 
        input  [CONV_KH_WIDTH-1:0]   kh,
        input  [CONV_KW_WIDTH-1:0]   kw,
        input start_SA,
        output [ROW-1:0] valid_stride
    );

    wire [(UPPER_BOUND)-1:0] row;
    wire [(UPPER_BOUND)-1:0] col;
    // reg [(DATA_WIDTH*ROW)-1:0]           lower_bound_row = 0;
    // reg [(DATA_WIDTH*ROW)-1:0]           lower_bound_col = 0;
    reg                                  bound_gen_done_row = 0; 
    reg                                  bound_gen_done_col = 0;
    
    assign row = curr_row;
    assign col = curr_col;

    /*
    // Generation of lower_bound_row
    reg [$clog2(ROW) : 0] i,j,k;
    always@(posedge clk) begin
      if(!rst) begin
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
                if(i == ROW) begin
                    bound_gen_done_row <= 1;
                end
                else begin
                    lower_bound_row[(DATA_WIDTH*(ROW-i))-1 -:DATA_WIDTH] <= lower_bound_row[(DATA_WIDTH*(ROW-((kw*kh)-1)))-1 -:DATA_WIDTH];
                    i <= i+1;
                end
              end
          end
      end
    end
  
    // Generation of lower_bound_col
    reg [$clog2(ROW) : 0] l,m;
    always@(posedge clk) begin
      if(!rst) begin
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
                if(l == ROW) begin
                    bound_gen_done_col <= 1;
                end
                else begin
                    lower_bound_col[(DATA_WIDTH*(ROW-l))-1 -:DATA_WIDTH] <= lower_bound_col[(DATA_WIDTH*(ROW-((kw*kh)-1)))-1 -:DATA_WIDTH];
                    l <= l+1;
                end
              end
          end
      end
    end
    */

    // Stride block for each valid_sq row
    genvar sq;
    generate 
        for(sq=0; sq<ROW; sq=sq+1) begin
            stride_mod_v1 #(.DATA_WIDTH(DATA_WIDTH), .UPPER_BOUND(UPPER_BOUND), .STRIDE(STRIDE)) finaldut(
                .clk(clk),
                .rst(rst),
                .row(row),
                .col(col),
                .stride(stride),
                .o_mod(valid_stride[sq]),
                .lower_bound_col(lower_bound_col[(DATA_WIDTH*(ROW-sq))-1 -:DATA_WIDTH]),
                .lower_bound_row(lower_bound_row[(DATA_WIDTH*(ROW-sq))-1 -:DATA_WIDTH])
            );
        end
    endgenerate

endmodule