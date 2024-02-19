module controller_tx1 #(parameter DATA_WIDTH = 8,
                        parameter UART_WIDTH = 8,
                        parameter MAX_VALID_SQ = 9)(
    input                           clk,
    input [MAX_VALID_SQ-1:0]        i_fifo_data_valid_sq,
    input                           i_empty_flag,
    output [UART_WIDTH-1:0]         o_data_valid_sq,
    output                          rd_en,             
    output                          o_valid_tx1,
    input                           i_trans_done_tx1
);
    reg [4:0]                       p_state;
    reg                             r_rd_en;
    reg                             r_o_valid_tx1;
    reg [UART_WIDTH-1:0]            r_o_data_valid_sq;


    wire [3:0]                      w_total_valid;       

    assign rd_en = r_rd_en;
    assign o_valid_tx1 = r_o_valid_tx1;  
    assign o_data_valid_sq = r_o_data_valid_sq;



    always @(posedge clk) begin
        case(p_state)
        0 : begin
            r_o_valid_tx1 <= 0;
            r_rd_en <= 0;
            if (!i_empty_flag) begin
                r_rd_en <= 1;
                p_state <= 1;
            end
        end

        1 : begin
            r_rd_en <= 0;
            r_o_valid_tx1 <= 0;
            p_state <= 2;
        end

 
        2 : begin
            r_o_data_valid_sq <= i_fifo_data_valid_sq[7:0];
                r_o_valid_tx1 <= 1;
            if (i_trans_done_tx1) begin
                r_o_valid_tx1 <= 0;
                p_state <= 3;
            end
        end 
        3 : begin
                r_o_data_valid_sq <= {7'd0,i_fifo_data_valid_sq[8]};
                r_o_valid_tx1 <= 1;
                p_state <= 4;
            end
        4 : begin
            if (i_trans_done_tx1)begin
                p_state <= 0;
                r_o_valid_tx1 <= 0;
            end
        end
        endcase 
    end



    /*assign w_total_valid = i_fifo_data_valid_sq[0] + i_fifo_data_valid_sq[1] +
    i_fifo_data_valid_sq[2] + i_fifo_data_valid_sq[3] + i_fifo_data_valid_sq[4] +
    i_fifo_data_valid_sq[5] + i_fifo_data_valid_sq[6] + i_fifo_data_valid_sq[7] +
    i_fifo_data_valid_sq[8]; */






endmodule



