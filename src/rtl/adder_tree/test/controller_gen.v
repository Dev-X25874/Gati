module controller_gen#(
    parameter N_FIFO = 8, parameter DATA_WIDTH = 8, parameter ADDR_WIDTH = 8
)(
    input i_clk,
    input i_rx_valid,
    input [(DATA_WIDTH-1):0] i_fifo_empty,
    input [((ADDR_WIDTH+1)*N_FIFO)-1:0] i_fifo_occupants,
    output reg o_fifo_wren = 0,
    output reg [N_FIFO-1:0] o_fifo_rden = 0
);

always @(posedge i_clk) begin
    if(i_rx_valid)begin
        o_fifo_wren <= 1'b1;
    end else begin
        o_fifo_wren <= 1'b0;
    end

    if(i_fifo_empty == 0)begin
        if(i_fifo_occupants == {N_FIFO{9'd3}})begin
            o_fifo_rden <= {N_FIFO{1'b1}};
        end else begin
            o_fifo_rden <= {N_FIFO{1'b0}};
        end
    end
end

endmodule