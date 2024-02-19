module tx_controller_adder_tree #(
    parameter           N = 8,
    parameter           DATA_WIDTH = 20,
    parameter           UART_WIDTH = 8,
    parameter           FIFO_NO = 8,
    parameter           FIFO_DEPTH = 256)
    (
    output [FIFO_NO-1:0]                rd_en, //The same enable goes as the input
    // to the previous 8 fifos instantiated and next one fifo.
    input [DATA_WIDTH*N-1:0]            data_in,
    input [FIFO_NO-1:0]                 empty_flag,
    output [DATA_WIDTH-1:0]             data_out_fifo,
    output                              wr_en,
    input                               clk


);

    reg [4:0]                           p_state = 0;
    reg [DATA_WIDTH*N-1:0]                r_data_out_fifo;
    reg [FIFO_NO-1:0]                   r_rd_wr_en;
    reg  [$clog2(FIFO_NO):0]            r_counter = 0;
    reg                                 r_wr_en;



    assign rd_en = (r_counter == 1) ?  {7'd0,r_rd_wr_en} : 
                   (r_counter == 2) ?  {6'd0,r_rd_wr_en,1'd0} : 
                   (r_counter == 3) ?  {5'd0,r_rd_wr_en,2'd0} : 
                   (r_counter == 4) ?  {4'd0,r_rd_wr_en,3'd0} :
                   (r_counter == 5) ?  {3'd0,r_rd_wr_en,4'd0} :
                   (r_counter == 6) ?  {2'd0,r_rd_wr_en,5'd0} :
                   (r_counter == 7) ?  {1'd0,r_rd_wr_en,6'd0} : 
                   (r_counter == 8) ?  {r_rd_wr_en, 7'd0} : 8'd0;


    assign data_out_fifo = (r_counter == 1) ?  r_data_out_fifo[19:0] : 
                             (r_counter == 2) ?  r_data_out_fifo[39:20] : 
                             (r_counter == 3) ?  r_data_out_fifo[59:40]: 
                             (r_counter == 4) ?  r_data_out_fifo[79:60]: 
                             (r_counter == 5) ?  r_data_out_fifo[99:80] :
                             (r_counter == 6) ?  r_data_out_fifo[119:100] :
                             (r_counter == 7) ?  r_data_out_fifo[139:120] :
                             (r_counter == 8) ?  r_data_out_fifo[159:140] : 160'd0;
                         
    assign wr_en = r_wr_en;




always @(posedge clk) begin
    case (p_state)
        0 : begin
            if (!empty_flag) begin
                p_state <= 1;
                r_rd_wr_en <= 1;
            end else begin
                p_state <= 0;
                r_rd_wr_en <= 0;
            end
        end

        1 : begin
            if (r_counter < FIFO_NO) begin
                p_state <= 1;
                r_wr_en <= 1;
                r_rd_wr_en <= 0;
                r_data_out_fifo <= data_in;
                r_counter <= r_counter + 1;
            end else begin
                r_wr_en <= 0;
                r_rd_wr_en <= 0; 
                p_state <= 0;
                r_counter <= 0;
            end
        end

    endcase
end

endmodule 