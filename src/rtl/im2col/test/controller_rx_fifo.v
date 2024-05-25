module controller_rx_fifo #(
    parameter                       DATA_WIDTH = 8,
    parameter                       UPPER_BOUND = 226,
    parameter                       FIFO_COUNT = 224


)(
    input                               i_start_im2col_ctrl,
    input                               clk,
    input [DATA_WIDTH-1:0]              i_fifo_data,
    input                               fifo_empty_flag,
    output [$clog2(UPPER_BOUND)-1:0]    o_mat_size,
    output [DATA_WIDTH-1:0]             o_data,
    output                              rd_en,
    output                              o_valid_im2col,
    input                               i_valid_buff,
    output                              o_trigger,
    output                              o_valid_mat_size
);

    reg [4:0]                           p_state ;
    reg                                 r_rd_en = 0;
    reg                                 r_o_valid_im2col;
    reg [$clog2(UPPER_BOUND)-1:0]       r_o_mat_size;
    reg [DATA_WIDTH-1:0]                r_o_data;
    reg [20:0]                          r_counter = 1;
    reg                                 r_o_trigger;
    reg                                 r_valid_mat_size = 0;
    assign o_mat_size = r_o_mat_size;
    assign o_valid_im2col = r_o_valid_im2col;
    assign o_data = r_o_data;
    assign o_trigger = r_o_trigger;
    assign o_valid_mat_size = r_valid_mat_size;
    assign rd_en = (p_state == 4) ? i_valid_buff : r_rd_en;
    

    always @(posedge clk) begin
        case(p_state)
        0 : begin
            if (!fifo_empty_flag && i_start_im2col_ctrl) begin
                r_valid_mat_size <= 0;
                r_rd_en <= 1;
                p_state <= 1;
            end else begin
                r_o_valid_im2col <= 0;
                r_rd_en <= 0;
            end
        end
        1 : begin
            r_rd_en <= 0;
            p_state <= 2;
            r_o_valid_im2col <= 0;
            r_valid_mat_size <= 0;
        end

        
        2 : begin
            if (!fifo_empty_flag) begin
                r_o_mat_size <= i_fifo_data;
                r_valid_mat_size <= 1;
                r_o_valid_im2col <= 0;
                p_state <= 3;
                r_rd_en <= 1;
            end
        end
        
        3 : begin
            r_rd_en <= 0;
            r_o_mat_size <= r_o_mat_size;
            p_state <= 4;
            r_o_valid_im2col <= 0;
        end

        4 : begin
            if (r_counter == r_o_mat_size*r_o_mat_size) begin
                r_rd_en <= 0;
                r_o_data <= i_fifo_data;
                r_o_valid_im2col <= 1;
                r_counter <= 1;
                p_state <= 6;
            end else if (!fifo_empty_flag && i_valid_buff) begin
                r_rd_en <= 1;
                r_counter <= r_counter + 1;
                r_o_data <= i_fifo_data;
                r_o_valid_im2col <= 1;
                p_state <= 4;
            end else if (!i_valid_buff)begin
                r_rd_en <= 0;
                r_o_valid_im2col <= 0; 
            end
        end
        
        /*5 : begin
        if (!fifo_empty_flag) begin
            r_rd_en <= 1;
            r_o_valid_im2col <= 0;
            p_state <= 6;
            end else
            r_rd_en <= 0; 
            
        end
        */
        6 : begin
            p_state <= 0;
            //r_o_data <= i_fifo_data;
            //r_o_valid_im2col <= 1;
            r_rd_en <= 0;
        
        end
        
            
        
        endcase 
    end

endmodule 