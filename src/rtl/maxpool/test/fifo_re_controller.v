//Handles read enable signal of fifo storing outputs coming from array of fifo
module fifo_re_controller(
    input i_clk,
    input i_fifo_empty,
    input i_tx_done,
    output o_fifo_read_enable,
    output o_tx_data_valid
);

reg rden = 0;
reg tx_dv = 0;
reg [1:0] state = 0; 

assign o_fifo_read_enable = rden;
assign o_tx_data_valid = tx_dv;

always@(posedge i_clk)begin
    case (state)
        0:begin
            if(i_fifo_empty == 0)begin
                rden <= 1'b1;
                state <= 1;
            end
            else begin
                rden <= 1'b0;
                state <= 0;
            end
        end 

        1: begin
            rden <= 1'b0;
            tx_dv <= 1'b1;
            state <= 2;
        end

        2: begin
            tx_dv <= 1'b0;
            if(i_tx_done == 1)begin
                state <= 0;
            end
            else begin
                state <= 2;
            end
        end

        default: state <= 0;
    endcase
end

endmodule