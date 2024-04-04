//this module to control the read and write enable of the 8 fifos generated. 
//write enable of the fifos get high in the squential matter while read enable of all fifos get enabled at once.

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
            o_fifo_wren[counter] <= 1'b1; //write enable of the fifos gets high in the sequential order
            o_fifo_wren[counter-1] <= 1'b0; //simultaneously the write enable of the last fifo gets low 
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
    if(~i_fifo_empty) begin
        if(i_fifo_occupants == {N_FIFO{9'd16}}) begin //as occupancy in each fifo reaches 16, the read enable of them get high at once
            o_fifo_rden <= 4'b1111; //all fifos read enable get high together
        end
        else begin
            o_fifo_rden <= o_fifo_rden;
        end
    end
     else begin
         o_fifo_rden <= 4'b0000;
    end
end

endmodule
