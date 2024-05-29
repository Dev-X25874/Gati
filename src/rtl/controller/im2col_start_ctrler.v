module im2col_start_ctrler#(
    parameter CITER_CNT_WIDTH = 12,
    parameter KITER_CNT_WIDTH = 12
)
(
    input clk,
    input rst,
    input start,
    
    input iter_done,
    input [CITER_CNT_WIDTH-1:0] c_iter,
    input [KITER_CNT_WIDTH-1:0] k_iter,
    
    output reg start_im2col
);

reg [1:0] state;
reg [KITER_CNT_WIDTH:0] k_ctr = 0; //k_iter
reg [CITER_CNT_WIDTH:0] c_ctr = 0; //c_iter

always@(posedge clk) begin
    if(!rst) begin
        start_im2col <= 0;
        state <= 0;
        c_ctr <= 0;
        k_ctr <= 0;
    end
    else begin
        case(state)
            0: begin
                c_ctr <= 0;
                k_ctr <= 0;
                if(start) begin
                    start_im2col <= 1;
                    state <= 1;
                end
            end
            
            1:begin
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
                        state <= 2;
                    end
                    else begin
                        start_im2col <= 0;
                        state <= 1;
                    end
                //end
            end
            
            2: begin
                //else begin
                    if(c_ctr==c_iter-1) begin
                        k_ctr <= k_ctr + 1;
                        c_ctr <= 0;
                        state <= 3;
                        start_im2col <= 0;
                    end
                    else begin
                        k_ctr <= k_ctr;
                        c_ctr <= c_ctr + 1;
                        state <= 3;
                        start_im2col <= 0;
                    end
                //end
            end
            
            3: begin
                if(k_ctr==k_iter) begin
                    k_ctr <= 0;
                    c_ctr <= 0;
                    state <= 0;
                    start_im2col <= 0;
                end
                else begin
                    start_im2col <= 1;
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