/*              rx_controller Module
- This module converts 8 bits/ a byte of data received by the rx to 20 bits.
*/

module rx_controller #(
    parameter           UART_WIDTH = 8,
    parameter           DATA_WIDTH = 20


)(
 
    input [UART_WIDTH-1:0]      rx_data_in,
    input                       rx_valid,
    output [DATA_WIDTH-1:0]     fifo_out,
    output                      we,
    input                       clk  
);


    reg [4:0]                   p_state = 0;
    reg [DATA_WIDTH-1:0]        r_fifo_data;
    reg [4:0]                   r_counter_data = 3;
    reg                         r_we;

    assign we = r_we;
    assign fifo_out = (r_counter_data == 3) ? r_fifo_data[19:0] : 20'd0;

    always @(posedge clk) begin
        case (p_state) 
        0 : begin
            r_we <= 0;
            if (rx_valid) begin
                p_state <= 1;
            end else
                p_state <= 0;
        end

        1 : begin 
            if (r_counter_data > 1) begin
                r_counter_data <= r_counter_data - 1;
                r_we <= 0;
                p_state <= 0;
                r_fifo_data[(r_counter_data*8) - 1 -: 8] <= rx_data_in;
            end else begin 
                r_fifo_data[(r_counter_data*8) - 1 -: 8] <= rx_data_in;
                r_we <= 1'b1;
                r_counter_data <= 3;
                p_state <= 0;
            end
        end
        endcase

    end



endmodule 