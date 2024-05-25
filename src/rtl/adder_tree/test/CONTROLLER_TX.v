//send 19 bits of partial suns in 3 bytes to the uart trasnsmitter
module CONTROLLER_TX #(
    parameter DATA_WIDTH = 128,
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
        3: begin
            r_o_data <= i_fifo_data[7:0];
            r_o_valid_tx2 <= 1;
            p_state <= 4;
        end
        4 : begin
            /*if(count < (cnt-1)) begin
                if (i_trans_done_tx2) begin 
                    r_o_data <= i_fifo_data_reg[7:0];
                    r_o_valid_tx2 <= 1;
                    p_state <= 4;
                    count <= count + 1;
                end else begin
                    r_o_valid_tx2 <= 0; 
                    p_state <= 4;
                    count <= count;
                end
            end
            else begin
                count <= 0;
                r_o_data <= r_o_data;
                r_o_valid_tx2 <= 0; 
                p_state <= 5;
            end*/
            if(i_trans_done_tx2) begin
                if(count < (cnt-1)) begin
                    i_fifo_data_reg <= {i_fifo_data_reg[15:8], i_fifo_data_reg[127:16]};
                    r_o_data <= i_fifo_data_reg[7:0];
                    r_o_valid_tx2 <= 1;
                    p_state <= 4;
                    count <= count + 1;
                end
                else begin
                    count <= 0;
                    r_o_data <= 0;
                    r_o_valid_tx2 <= 0; 
                    p_state <= 5;
                end
            end
            else begin
                r_o_valid_tx2 <= 0; 
                p_state <= 4;
                r_o_data <= r_o_data;
            end
        end
        5: begin
            if(i_trans_done_tx2) begin
                p_state <= 0;
                r_o_data <= 0;
                r_o_valid_tx2 <= 1'b0;
            end
            else begin
                r_o_valid_tx2 <= 1'b0;
                p_state <= 5;
            end
        end
        endcase
    end
endmodule









//i_fifo_data_reg <= {i_fifo_data_reg[7:0], i_fifo_data_reg[127:8]};