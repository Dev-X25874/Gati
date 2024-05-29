//send 32 bits of accumulated output in 4 bytes to the uart trasnsmitter
module controller_fifo_tx#(
    parameter N_SA = 4,
    parameter W_ACC = 19,
    parameter W_DATA = 8
)(
    input i_clk,
    input i_rst,
    input [N_SA-1 : 0] i_fifo_empty,
    output [N_SA-1 : 0] o_fifo_rden,
    input [(N_SA * W_ACC)-1 : 0] i_data,
    input [N_SA-1 : 0] i_tx_done,
    output [N_SA-1 : 0] o_tx_dv,
    output [(N_SA * W_DATA)-1 : 0] o_tx_data
);

genvar i;
generate
    for(i = 0; i < N_SA; i = i +1)begin
        fifo_tx_ctrl #(
    .DATA_WIDTH(W_ACC),
    .UART_WIDTH(W_DATA)
    )tx_ctrl_gen(
        .clk(i_clk),
        .i_rst(i_rst),
        .i_fifo_data(i_data[(W_ACC * (N_SA - i))-1 -: W_ACC]),
        .i_empty_flag(i_fifo_empty[i]),
        .o_data(o_tx_data[(W_DATA * (N_SA - i))-1 -: W_DATA]),
        .rd_en(o_fifo_rden[i]),             
        .o_valid_tx2(o_tx_dv[i]),
        .i_trans_done_tx2(i_tx_done[i])
    );

    end
endgenerate
    
endmodule

module  fifo_tx_ctrl#(
    parameter DATA_WIDTH = 19,
    parameter UART_WIDTH = 8
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
                r_o_data <= i_fifo_data[7:0];
                r_o_valid_tx2 <= 1;
                p_state <= 3;
            end

            3 : begin
                if (i_trans_done_tx2) begin
                    r_o_data <= i_fifo_data[15:8]; 
                    r_o_valid_tx2 <= 1;
                    p_state <= 4;
                end else begin
                    r_o_valid_tx2 <= 0; 
                    p_state <= 3;
                end
            end

            4 : begin
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
            
            6: begin
                if(i_trans_done_tx2) begin
                    p_state <= 0;
                    r_o_data <= 0;
                    r_o_valid_tx2 <= 1'b0;
                end
                else begin
                    r_o_valid_tx2 <= 1'b0;
                    p_state <= 6;
                end
            end
            endcase 
    end
    end

endmodule