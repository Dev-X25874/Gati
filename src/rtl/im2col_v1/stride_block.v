module stride_block #(
    parameter DATA_WIDTH = 8,
    parameter KERNEL_SIZE = 4,
    parameter UPPER_BOUND = 224,
    parameter STRIDE = 3)
    (
        input clk,
        input rst,
        input  [$clog2(UPPER_BOUND)-1:0] curr_row,
        input  [$clog2(UPPER_BOUND)-1:0] curr_col,
        input  [$clog2(STRIDE):0]        stride, 
        input  [$clog2(KERNEL_SIZE):0]   ksize,
        output [KERNEL_SIZE*KERNEL_SIZE-1:0] valid_stride
    );

    wire [$clog2(UPPER_BOUND)-1:0] lower_bound_row [KERNEL_SIZE-1:0];
    wire [$clog2(UPPER_BOUND)-1:0] lower_bound_col [KERNEL_SIZE*KERNEL_SIZE-1:0];
    wire [$clog2(UPPER_BOUND)-1:0] row;
    wire [$clog2(UPPER_BOUND)-1:0] col;
    reg  [(DATA_WIDTH*KERNEL_SIZE*KERNEL_SIZE)-1:0] r_lower_bound_row = 0;
    reg  [(DATA_WIDTH*KERNEL_SIZE*KERNEL_SIZE)-1:0] r_lower_bound_col = 0;
    
    assign row = curr_row;
    assign col = curr_col;

    genvar i,j,m;
    integer k,l;
    
    generate
      for(i=0; i<KERNEL_SIZE; i=i+1) begin
        assign  lower_bound_row[i] = i + 1;
        for(j=0; j<KERNEL_SIZE; j=j+1) begin
            assign  lower_bound_col[j+KERNEL_SIZE*(i)] = j + 1;
        end
    end
    endgenerate
    
    always @ (posedge clk) begin
    if(!rst) begin
    r_lower_bound_col <= 0;
    r_lower_bound_row <= 0;
    end
    
    else begin
    for(k=0; k<KERNEL_SIZE; k=k+1) begin
    for(l=0; l<KERNEL_SIZE; l=l+1) begin
    if(k<ksize) begin
    if(l<ksize) begin
    r_lower_bound_col[(DATA_WIDTH*((KERNEL_SIZE*KERNEL_SIZE)-(l + ksize*(k))))-1 -:DATA_WIDTH] <= lower_bound_col[l + KERNEL_SIZE*(k)];
    r_lower_bound_row[(DATA_WIDTH*((KERNEL_SIZE*KERNEL_SIZE)-(l + ksize*(k))))-1 -:DATA_WIDTH] <= lower_bound_row[k];
    end
    
    else begin
    r_lower_bound_col[(DATA_WIDTH*((KERNEL_SIZE*KERNEL_SIZE)-(k + ksize*(l))))-1 -:DATA_WIDTH] <= lower_bound_col[ksize - 1];
    r_lower_bound_row[(DATA_WIDTH*((KERNEL_SIZE*KERNEL_SIZE)-(k + ksize*(l))))-1 -:DATA_WIDTH] <= lower_bound_row[ksize - 1];
    end
    end
    
    else begin
    r_lower_bound_col[(DATA_WIDTH*((KERNEL_SIZE*KERNEL_SIZE)-(l + KERNEL_SIZE*(k))))-1 -:DATA_WIDTH] <= lower_bound_col[ksize - 1];
    r_lower_bound_row[(DATA_WIDTH*((KERNEL_SIZE*KERNEL_SIZE)-(l + KERNEL_SIZE*(k))))-1 -:DATA_WIDTH] <= lower_bound_row[ksize - 1];
    end
    end
    end
    end
    end

    // Stride block for each valid_sq row
    generate 
        for(m=0; m<KERNEL_SIZE*KERNEL_SIZE; m=m+1) begin
                    stride_mod #(.DATA_WIDTH(DATA_WIDTH), .UPPER_BOUND(UPPER_BOUND), .STRIDE(STRIDE)) finaldut(
                    .clk(clk),
                    .rst(rst),
                    .row(row),
                    .col(col),
                    .stride(stride),
                    .o_mod(valid_stride[m]),
                    .lower_bound_col(r_lower_bound_col[(DATA_WIDTH*((KERNEL_SIZE*KERNEL_SIZE)-m))-1 -:DATA_WIDTH]),
                    .lower_bound_row(r_lower_bound_row[(DATA_WIDTH*((KERNEL_SIZE*KERNEL_SIZE)-m))-1 -:DATA_WIDTH])
                );
        end
    endgenerate

endmodule