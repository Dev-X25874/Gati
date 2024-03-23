//send 19 bits of partial suns in 3 bytes to the uart trasnsmitter
module controller_fifo_tx #(
    parameter DATA_WIDTH = 180,
    parameter UART_WIDTH = 8,
    parameter cnt = DATA_WIDTH/UART_WIDTH
)(  input clk,
    input i_rst,
    input [DATA_WIDTH-1:0] i_fifo_data,
    input i_empty_flag,
    output [UART_WIDTH-1:0] o_data,
    output rd_en,             
    output o_valid_tx2,
    input  i_trans_done_tx2
);
    reg [4:0] p_state = 0;
    reg r_rd_en = 0;
    reg r_o_valid_tx2 = 0;
    reg [UART_WIDTH-1:0] r_o_data; 
    reg [DATA_WIDTH-1:0] i_fifo_data_reg = 0; 
    reg [15:0] count = 0;     

    assign rd_en = r_rd_en;
    assign o_valid_tx2 = r_o_valid_tx2;  
    assign o_data = r_o_data;


    always @(posedge clk) begin
        if(i_rst)begin
            p_state <= 0;
            r_rd_en <= 0;
            r_o_valid_tx2 <= 0;
            r_o_data <= 0;
        end else begin
            case(p_state)
            0 : begin
                r_o_valid_tx2 <= 0;
                r_o_data <= 0;
                i_fifo_data_reg <= 0;
                if (!i_empty_flag) begin
                    r_rd_en <= 1;
                    p_state <= 1;
                end
            end

            1 : begin
                r_o_valid_tx2 <= 0;
                r_rd_en <= 0;
                p_state <= 2;
            end

        
            2 : begin
                i_fifo_data_reg <= i_fifo_data;
                //r_o_valid_tx2 <= 1;
                p_state <= 3;
            end

            3 : begin
                if(count < (cnt-1)) begin
                    if (i_trans_done_tx2) begin
                        i_fifo_data_reg <= {i_fifo_data_reg[7:0], i_fifo_data_reg[179:8]}; 
                        r_o_data <= i_fifo_data_reg[7:0];
                        r_o_valid_tx2 <= 1;
                        p_state <= 3;
                        count <= count + 1;
                    end else begin
                        r_o_valid_tx2 <= 0; 
                        p_state <= 3;
                        count <= count;
                    end
                end
                else begin
                    count <= 0;
                    r_o_data <= r_o_data;
                    r_o_valid_tx2 <= 0; 
                    p_state <= 4;
                end
            end

/*            4 : begin
                if (i_trans_done_tx2) begin
                    r_o_data <= i_fifo_data[23:16]; 
                    r_o_valid_tx2 <= 1;
                    p_state <= 5;
                end else begin
                    r_o_valid_tx2 <= 0; 
                    p_state <= 4;
                end
            end

            5 : begin
                if (i_trans_done_tx2) begin
                    r_o_data <= i_fifo_data[31:24]; 
                    r_o_valid_tx2 <= 1;
                    p_state <= 6;
                end else begin
                    r_o_valid_tx2 <= 0; 
                    p_state <= 5;
                end
            end

            4 : begin
                if (i_trans_done_tx2)begin
                    r_o_data <= {{5{i_fifo_data[18]}},i_fifo_data[18:16]};
                    r_o_valid_tx2 <= 1'b1;
                    p_state <= 5;
                end
                else begin
                    r_o_valid_tx2 <= 0;
                    p_state <= 4;
                end
            end
*/
            4: begin
                if(i_trans_done_tx2) begin
                    p_state <= 0;
                    r_o_data <= 0;
                    r_o_valid_tx2 <= 1'b0;
                end
                else begin
                    r_o_valid_tx2 <= 1'b0;
                    p_state <= 4;
                end
            end
            endcase 
    end
    end

endmodule