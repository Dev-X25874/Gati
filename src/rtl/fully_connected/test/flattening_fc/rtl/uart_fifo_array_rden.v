/*
    Reads 28 data from each fifo in uart image fifo array at once.
    Reason to stream 28 data:
        Image dim: 7x7x16 = 784, 7 0's for each channel, 7x16 = 112
        And, 784+112 = 896, 896/32 = 28
*/
module uart_fifo_array_rden#(
    parameter W_ADDR = 9,
    parameter N_FIFO = 32
)(
    input clk,
    input rst,
    input [15:0] i_image_rows,
    input [N_FIFO-1 : 0] i_fifo_empty,
    input [(N_FIFO * (W_ADDR + 1))-1 : 0] i_fifo_occupants,
    output [N_FIFO-1 : 0] o_fifo_read_enable
);

reg [N_FIFO-1 : 0] rden = 0;
assign o_fifo_read_enable = rden;

always @(posedge clk)begin
    if(rst)begin
        rden <= 0;
    end else begin
        if(i_fifo_empty == 0)begin
            // if(i_fifo_occupants >= {N_FIFO{10'd150}})begin
            if(i_fifo_occupants >= (i_image_rows >> 5))begin //image rows here should include 0's
                rden <= {N_FIFO{1'b1}};
            end
        end else begin
            rden <= {N_FIFO{1'b0}};
        end
    end
end
    
endmodule