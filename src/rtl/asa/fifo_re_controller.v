//Handles read enable signal of fifo storing outputs coming from array of fifo
module fifo_re_controller(
    input i_clk,
    input i_fifo_empty,
    output o_fifo_read_enable
);

reg rden = 0;

assign o_fifo_read_enable = rden;
always @(posedge i_clk)begin
    if(i_fifo_empty == 0)begin
        rden <= 1'b1;
    end else begin
        rden <= 0;
    end
end

endmodule