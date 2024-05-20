/*
    Data is written one byte at a time, into each fifo in an array of fifo,
    as it is received from the UART.
    Therefore, after a specific amount of bytes
    are written into each fifo in the fifo array, 
    the data will be read in order to stream.
    This controller handles read enable signal of uart fifo array.
*/
module uart_fifo_array_rden#(
    parameter W_ADDR = 9,
    parameter N_FIFO = 32
)(
    input clk,
    input rstn,
    input [15:0] i_image_rows,
    input [N_FIFO-1 : 0] i_fifo_empty,
    input [(N_FIFO * (W_ADDR + 1))-1 : 0] i_fifo_occupants,
    output [N_FIFO-1 : 0] o_fifo_read_enable
);

reg [N_FIFO-1 : 0] rden = 0;
assign o_fifo_read_enable = rden;

always @(posedge clk)begin
    if(~rstn)begin
        rden <= 0;
    end else begin
        if(i_fifo_empty == 0)begin
            if(i_fifo_occupants >= (i_image_rows >> 5))begin //image rows here should include 0's
                rden <= {N_FIFO{1'b1}};
            end
        end else begin
            rden <= {N_FIFO{1'b0}};
        end
    end
end
    
endmodule