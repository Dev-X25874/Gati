/*
    When each fifo in the array has a data, 
    the read enable signal of image fifo array is asserted.
*/
module image_fifo_array_rden#(
    parameter ROW = 9,
    parameter W_DATA = 8,
    parameter W_ADDR = 8
)(
   input stall_on,
	input i_clk,
    input i_trigger,
    input i_rstn,
    input [ROW-1:0] i_fifo_empty,
    output [ROW-1:0] o_read_enable
);

reg [ROW-1:0] rden = 0;

assign o_read_enable = rden;

always @(posedge i_clk)begin
    if(~i_rstn)begin
        rden <= 0;
    end else begin
        if(i_trigger)begin
            if(i_fifo_empty == 0 && (~stall_on))
                rden <= {ROW{1'b1}};
            else
                rden <= {ROW{1'b0}};
        end
    end
end
endmodule
