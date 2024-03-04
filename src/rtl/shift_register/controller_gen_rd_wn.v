module controller_gen_rd_wn#(
    parameter N_FIFO = 4, parameter DATA_WIDTH = 32, parameter ADDR_WIDTH = 9
)(
    input i_clk,
    input i_rx_valid,
    input [N_FIFO-1:0] i_fifo_empty,
    input [((ADDR_WIDTH*N_FIFO)-1):0] i_fifo_occupants,
    output reg [N_FIFO-1:0] o_fifo_wren = 0,
    output reg [N_FIFO-1:0] o_fifo_rden = 0
);
reg [14:0] counter = 0;

always @(posedge i_clk) begin
    if(counter < N_FIFO) begin
        if(i_rx_valid) begin
            //o_fifo_wren <= 1'b1;
            o_fifo_wren[counter] <= 1'b1;
            o_fifo_wren[counter-1] <= 1'b0;
            counter <= counter + 1;
        end else begin
            //o_fifo_wren <= 1'b0;
            o_fifo_wren[counter] <= 1'b0;
            o_fifo_wren[counter-1] <= 1'b0;
            //o_fifo_wren <= 0;
            counter <= counter;
        end 
    end
    else begin
        o_fifo_wren <= 0;
        counter <= 0;
    end       
end

always @(posedge i_clk) begin
    //if(~i_fifo_empty) begin
        if(i_fifo_occupants >= {N_FIFO{9'd1}}) begin
            o_fifo_rden <= 4'b1111;
        end
        else begin
            o_fifo_rden <= 4'b0000;
        end
    //end
    // else begin
    //     o_fifo_rden <= 8'b0000_0000;
    // end
end

endmodule
