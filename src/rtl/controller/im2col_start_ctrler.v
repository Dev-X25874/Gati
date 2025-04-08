module im2col_start_ctrler#(
    parameter CITER_CNT_WIDTH = 12,
    parameter KITER_CNT_WIDTH = 12
)
(
    input clk,
    input rst,
    input start,
    input image_fifo_empty,
    
    input iter_done,
    input [CITER_CNT_WIDTH-1:0] c_iter,
    input [KITER_CNT_WIDTH-1:0] k_iter,
    
    output reg start_im2col
);

reg [2:0] state, prev_state;
reg [KITER_CNT_WIDTH:0] k_ctr = 0; //k_iter
reg [CITER_CNT_WIDTH:0] c_ctr = 0; //c_iter
reg [CITER_CNT_WIDTH-1:0] r_c_iter;
reg [KITER_CNT_WIDTH-1:0] r_k_iter;

always @ (posedge clk) begin 
	r_c_iter<=c_iter-1;
	r_k_iter<=k_iter;
end 


always@(posedge clk) begin
    if(!rst) begin
        start_im2col <= 0;
        state <= 0;
        c_ctr <= 0;
        k_ctr <= 0;
        prev_state <= 0;
    end
    else begin
        prev_state <= state;
        case(state)
            0: begin
                c_ctr <= 0;
                k_ctr <= 0;
                if(start) begin
                    start_im2col <= 0;
                    state <= 1;
                end
            end
            
            1: begin
                if(prev_state == 3'd3) begin
                    start_im2col <= 1;
                    state <= 2;
                end
                else begin
                    if(!image_fifo_empty) begin
                        start_im2col <= 1;
                        state <= 2;
                    end
                    else begin
                        start_im2col <= 0;
                        state <= 1;
                    end
                end
            end

            2:begin
                /*
                if((k_ctr==k_iter)) begin
                    k_ctr <= 0;
                    c_ctr <= 0;
                    state <= 0;
                    start_im2col <= 0;
                end*/
                //else begin
                    if(iter_done==1) begin
                        start_im2col <= 0;
                        state <= 3;
                    end
                    else begin
                        start_im2col <= 0;
                        state <= 2;
                    end
                //end
            end
            
            3: begin
                //else begin
                    if(c_ctr==r_c_iter) begin
                        k_ctr <= k_ctr + 1;
                        c_ctr <= 0;
                        state <= 4;
                        start_im2col <= 0;
                    end
                    else begin
                        k_ctr <= k_ctr;
                        c_ctr <= c_ctr + 1;
                        state <= 1;
                        start_im2col <= 0;
                    end
                //end
            end
            
            4: begin
                if(k_ctr==r_k_iter) begin
                    k_ctr <= 0;
                    c_ctr <= 0;
                    state <= 0;
                    start_im2col <= 0;
                end
                else begin
                    start_im2col <= 0;
                    state <= 1;
                end
            end
            default: begin
                start_im2col <= start_im2col;
                k_ctr <= k_ctr;
                c_ctr <= c_ctr;
                state <= state;
            end
            
        endcase
    end

end
endmodule

