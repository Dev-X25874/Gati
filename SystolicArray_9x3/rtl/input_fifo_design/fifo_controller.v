/*
    Handles reading occupants of fifo having weights and data,
    and enables the mux that handles writting data and weights
    into arrays of fifo.
*/
module fifo_controller(
    input i_clk,
    input i_fifo_empty,
    input fifo_array_full,
    output fifo_read_enable,
    output sr_enable
);
reg sren = 0;
reg rden = 0;

assign fifo_read_enable = rden;
assign sr_enable = sren;

always @(posedge i_clk) begin
    if(~i_fifo_empty && ~fifo_array_full)begin
        rden <= 1;
        sren <= 1;
    end else begin
        rden <= 0;
        sren <=0;
    end
end
endmodule