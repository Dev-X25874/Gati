module pooling_second_stage #(parameter KERNEL_HEIGHT = 4) (
    input clk,
    input rst_n,
    input [7:0] din_fifo_1,
    input [7:0] din_fifo_2,
    input datavalid_in,
    input [2:0] pooling_type,
    input [KERNEL_HEIGHT - 1 : 0] kernel_height,
    output reg datavalid_out = 0,
    output reg [7:0] r_dout = 0
);   

always @(posedge clk) begin
    if(datavalid_in) begin
        case(pooling_type)
        AVG_POOL: begin
            r_dout <= (din_fifo_1 + din_fifo_2) >> 1;
            state <= COUNT;
        end
        MAX_POOL: begin
            r_dout <= (din_fifo_1 > din_fifo_2) ? din_fifo_1 : din_fifo_2;
            state <= COUNT;
        end
        endcase
    end
end

endmodule