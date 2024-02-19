/*               rx_controller_adder_tree Module  
- This module accumulates the 20 bits of data it receives N times, 8 here because
we have 8 SA engines hence 8 adders running parallelly.   

*/
module rx_controller_adder_tree #(
    parameter           N = 8,
    parameter           DATA_WIDTH = 20,
    parameter           UART_WIDTH = 8,
    parameter           FIFO_NO = 8,
    parameter           ADDR_WIDTH = 12,
    parameter           FIFO_DEPTH = 256)
(
    input                           fifo_empty_flag,
    input [ADDR_WIDTH-1:0]          occupants,
    input [DATA_WIDTH-1:0]          i_fifo_data,
    output                          rd_en,
    input                           clk,
    input                           i_trig_adder,
    output reg[N-1:0]                  wr_en,
    output reg[DATA_WIDTH*N-1:0]       o_adder_tree_data,
    input                           flag_ctrl_adder,
    output                          done                                        
);


    reg  done = 0;
    reg [4:0]                       p_state  = 0;
    reg                             r_rd_en;
    reg [N-1:0]                     r_wr_en;
    reg [$clog2(N):0]                r_counter_acc = N;
    reg [DATA_WIDTH*N-1:0]            r_o_data;
    reg                               flag = 1;

    reg [N-1:0]                     r2_wr_en;
    reg [DATA_WIDTH*N-1:0]            r_o_adder_tree_data;

    assign rd_en = r_rd_en;
/*    assign wr_en = (r_counter_fifo==1) ? {7'd0,r_wr_en} : 
                   (r_counter_fifo==2) ? {6'd0,r_wr_en,1'd0}:
                   (r_counter_fifo==3) ? {5'd0,r_wr_en,2'd0}:
                   (r_counter_fifo==4) ? {4'd0,r_wr_en,3'd0}:
                   (r_counter_fifo==5) ? {3'd0,r_wr_en,4'd0}:
                   (r_counter_fifo==6) ? {2'd0,r_wr_en,5'd0}:
                   (r_counter_fifo==7) ? {1'd0,r_wr_en,6'd0}:
                   (r_counter_fifo==8) ? {r_wr_en,7'd0}: 8'd0; */

    always @(posedge clk) begin
    r_o_adder_tree_data <= r_o_data;
    o_adder_tree_data <= r_o_adder_tree_data;
    r2_wr_en <= r_wr_en;
    wr_en <= r2_wr_en;
    end

always @(posedge clk) begin
    case(p_state)
        0 : begin

                done<=0;
            if (flag_ctrl_adder) begin
                p_state <= 1;
            end else begin
                p_state <= 0;
            end
        end
        1 : begin
                r_wr_en <= 0;
                done<=0;

            if (!fifo_empty_flag) begin
                if (occupants >= N) begin
                r_rd_en <= 1;
            if(flag) begin
                p_state <= 2;
                flag<=0;
            end else
             p_state<=3;

            end
            end
        end

        2:
            p_state<=3;
    
        3 : begin
                if (r_counter_acc > 1) begin
                r_counter_acc <= r_counter_acc - 1;
                r_o_data [(r_counter_acc*DATA_WIDTH)-1 -: DATA_WIDTH] <= i_fifo_data;
                // p_state <= 1;
            end else begin
                r_o_data [(r_counter_acc*DATA_WIDTH)-1 -: DATA_WIDTH] <= i_fifo_data;
                done<=1;
                r_counter_acc <= N;
                r_wr_en <= 8'hFF;
                p_state <= 1;
                r_rd_en <= 0;
            end
           
        end
    endcase
end 

endmodule 