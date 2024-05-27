/*
    This controller asserts read enable signal of 
    uart rx fifo. It reads in streams of N_FIFO data,
    so that all the fifo in weight fifo array contains
    atleast one data in one read from this fifo.
*/
module rx_fifo_rden_ctrl#(
    parameter N_FIFO = 32,
    parameter W_ADDR = 8
)(
    input clk,
    input rst,
    input i_fifo_empty,
    input [W_ADDR : 0] i_fifo_occupants,
    output o_fifo_read_enable
);

reg [1:0] state = 0;
reg [5:0] counter = 0;
reg rden = 0;
assign o_fifo_read_enable = rden;

always @(posedge clk) begin
    if(rst)begin
        rden <= 0;
        state <= 0;
    end else begin
        case (state)
            0:begin
                if(i_fifo_empty == 0)begin
                    if(i_fifo_occupants >= N_FIFO)begin
                        rden <= 1'b1;
                        state <= 1;
                    end
                end
            end

            1: begin
                if(counter == N_FIFO-1)begin
                    rden <= 1'b0;
                    state <= 0;
                    counter <= 0;
                end else begin
                    counter <= counter + 1;
                end
            end
            default: state <= 0;
        endcase
    end
end
    
endmodule