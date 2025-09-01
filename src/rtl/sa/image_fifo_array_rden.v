/*
    When each fifo in the array has a data, 
    the read enable signal of image fifo array is asserted.
*/
module image_fifo_array_rden#(
    parameter ROW = 9,
    parameter W_DATA = 8,
    parameter W_ADDR = 8
)(
	input i_clk,
	input psum_full,
    input i_trigger,
    input i_rstn,
    input [ROW-1:0] i_fifo_empty,
    input [ROW-1:0] i_fifo_almost_empty,
    output o_read_enable
);

reg rden = 0;

assign o_read_enable = rden;

always @(posedge i_clk)begin
    if(~i_rstn)begin
        rden <= 0;
    end else begin
        if(i_trigger)begin
            if(|(i_fifo_almost_empty) & rden) rden <= 1'b0;
            else begin
                if((i_fifo_empty == 0) &&  (~psum_full))
                    rden <= 1'b1;
                else
                    rden <= 1'b0;
            end
        end
    end
end
endmodule
