module tx_controller_fifo #(parameter DATA_WIDTH = 20,
                            parameter UART_WIDTH = 8)(
    input                           clk,
    input [DATA_WIDTH-1:0]          i_fifo_data,
    input                           i_empty_flag,
    output [UART_WIDTH-1:0]         o_data,
    output                          rd_en,             
    output                          o_valid_tx,
    input                           i_trans_done_tx


);

    reg [4:0]                       p_state = 0; 
    reg                             r_rd_en;
    reg                             r_o_valid_tx;
    reg [UART_WIDTH-1:0]            r_o_data;
 //   reg [$clog2(DATA_WIDTH):0]      r_counter = 1;


    assign rd_en = r_rd_en;
    assign o_data = r_o_data;
    assign o_valid_tx = r_o_valid_tx;

    always @(posedge clk) begin
        case (p_state)
        0 : begin
            r_o_valid_tx <= 0;
            if (!i_empty_flag) begin
                r_rd_en <= 1;
                p_state <= 1;
            end
        end

        1 : begin
            r_o_valid_tx <= 0;
            r_rd_en <= 0;
            p_state <= 2;
        end

       
        2 : begin
            r_o_data <= {4'd0,i_fifo_data[19:16]};
            r_o_valid_tx <= 1;
            p_state <= 3;
        end

        3 : begin
            if (i_trans_done_tx) begin
                r_o_data <= i_fifo_data[15:8];
                r_o_valid_tx <= 1;
                p_state <= 4;
            end else
            r_o_valid_tx <= 0; 
        end

        4 : begin
            if (i_trans_done_tx) begin
                r_o_data <= i_fifo_data[7:0];
                r_o_valid_tx <= 1;
                p_state <= 5;
            end else
            r_o_valid_tx <= 0; 
        end


        5 : begin
            if (i_trans_done_tx)begin
                p_state <= 0;
            end
                r_o_valid_tx <= 0;
        end
        endcase
    end

    /*
    r_counter_data = 3'd3;
    
    always @(posedge clk) begin
        case (p_state) 
        0 : begin
            r_o_valid_tx <= 0;
            if (!i_empty_flag) begin
                r_rd_en <= 1;
                p_state <= 1;
            end else
                p_state <= 0;
        end
        1 : begin
        if (r_counter_data > 1) begin
            r_o_data <= i_fifo_data[(r_counter_data * 8) - 1 -: 8];
            r_o_valid_tx <= 1'd1;
            p_state <= 2;
        end else begin
            r_o_data <= i_fifo_data[(r_counter_data * 8) - 1 -: 8];
            r_o_valid_tx <= 1'b1;
            p_state <= 0;
        end
        end
        
        2 : begin
        if (i_trans_done_tx) begin
            p_state <= 1;
            r_o_valid_tx <= 1'b0;
        end else begin
            p_state <= 2;
        end
        end

        endcase

    end
   
    
    
    */

    
    
    

endmodule 