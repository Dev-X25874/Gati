module conv_output_reorder_EW#(
    parameter W_DATA = 8, 
    parameter N_BYTES = 32,
    parameter N = 4,
    parameter FIFO_NO = 8
)(
    input [N_BYTES*W_DATA-1:0] i_data, 
    output wire [N_BYTES*W_DATA-1:0] o_data 
);

generate
        wire [N_BYTES*W_DATA-1:0] reordered_data;
        
        genvar row, col;
        for (col = 0; col < FIFO_NO; col = col + 1) begin 
            for (row = 0; row < N; row = row + 1) begin 
                localparam integer in_index = (row * FIFO_NO) + col;
                localparam integer out_index = (col * N) + row;
                assign reordered_data[(out_index * W_DATA) +: W_DATA] = i_data[(in_index * W_DATA) +: W_DATA];
            end
        end

        assign o_data = reordered_data;

endgenerate

endmodule
