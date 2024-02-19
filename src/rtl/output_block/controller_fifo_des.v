/*                        controller_fifo_des Module 
- By assessing the empty_flag of the 32 fifos, the read for the first 8 FIFOs are
enabled, followed by subsequent FIFOs until 32nd FIFO. In conjunction to this,
mux select lines are also controlled here. 
*/

module controller_fifo_des #(
    parameter           N = 8,
    parameter           DATA_WIDTH = 20,
    parameter           FIFO_NO =32,
    parameter           MUX_SEL_WIDTH = 2

)(
    output [FIFO_NO-1:0]                    valid_rd_en,
    input [FIFO_NO-1:0]                     empty_flag,
    input                                   clk,
    output reg [MUX_SEL_WIDTH*N-1:0]        mux_sel,
    output reg [N-1:0]                      valid_fifo,
    input                                   flag_adder_ctrl_des,
    input                                   acc_done

);

    reg [FIFO_NO-1:0]                   r_valid_rd_en;
    reg [N-1:0]                         r_valid_fifo;
    reg [3:0]                           p_state = 4;
    reg [MUX_SEL_WIDTH*N-1:0]           r_mux_sel;

    assign valid_rd_en = r_valid_rd_en;
//    assign valid_fifo = r_valid_fifo;
    //assign mux_sel    = r_mux_sel;

     
always@(posedge clk) begin
    mux_sel<=r_mux_sel;             //delay it using a register because the select signal has to be sent in the next clock cycle after read enable
    valid_fifo <= r_valid_fifo;
end


always @(posedge clk) begin
    case (p_state)
        4 : begin
            if (flag_adder_ctrl_des) begin
                p_state <= 0;
            end
            else begin
                p_state <= 4;
            end
        end


        0 : begin
        if(acc_done) begin
            if (empty_flag[7:0] == 8'd0) begin      //Check for the empty flag status of the first 8 FIFOs only 
                r_valid_fifo <= 8'hFF;              
                r_valid_rd_en <= 32'h000000FF;      //Make the read enable of only those FIFOs high 
                r_mux_sel <= 16'h0000;
                p_state <= 1;
            end else begin
                r_valid_fifo <= 8'h00;
                r_valid_rd_en <= 32'h0;
                p_state <= 0;
            end
        end else begin
                r_valid_fifo <= 8'h00;
                r_valid_rd_en <= 32'h0;
                r_mux_sel <= r_mux_sel;
                p_state <= 0;            
        end
        end
        1 : begin
            if(acc_done) begin
            if (empty_flag[15:8] == 8'd0) begin     //Check for the empty flag status of the next 8 FIFOs only
                r_valid_fifo <= 8'hFF;
                r_valid_rd_en <= 32'h0000FF00;      //Make the read enable of only those FIFOs high
                r_mux_sel <= 16'h5555;
                p_state <= 2;
            end else begin
                r_valid_fifo <= 8'h00;
                r_valid_rd_en <= 32'h0;
                p_state <= 1;
            end
        end else begin
                r_valid_fifo <= 8'h00;
                r_valid_rd_en <= 32'h0;
                r_mux_sel <= r_mux_sel;
                p_state <= 1;            
        end
            end
        2 : begin
            if(acc_done) begin
            if (empty_flag[23:16] == 8'd0) begin     //Check for the empty flag status of the next 8 FIFOs only   
                r_valid_fifo <= 8'hFF;
                r_valid_rd_en <= 32'h00FF0000;       //Make the read enable of only those FIFOs high
                r_mux_sel <= 16'hAAAA;
                p_state <= 3;
            end else begin
                r_valid_fifo <= 8'h00;
                r_valid_rd_en <= 32'h0;
                p_state <= 2;
            end
        end else begin
                r_valid_fifo <= 8'h00;
                r_valid_rd_en <= 32'h0;
                r_mux_sel <= r_mux_sel;
                p_state <= 2;            
        end
        end
        3 : begin
            if(acc_done) begin
            if (empty_flag[31:24] == 8'd0) begin     //Check for the empty flag status of the next 8 FIFOs only   
                r_valid_fifo <= 8'hFF;
                r_valid_rd_en <= 32'hFF000000;       //Make the read enable of only those FIFOs high
                r_mux_sel <= 16'hFFFF;
                p_state <= 0;
            end else begin
                r_valid_fifo <= 8'h00;
                r_valid_rd_en <= 32'h0;
                p_state <= 3;
            end
        end else begin
                r_valid_fifo <= 8'h00;
                r_valid_rd_en <= 32'h0;
                r_mux_sel <= r_mux_sel;
                p_state <= 3;            
        end
        end
    endcase
end

endmodule