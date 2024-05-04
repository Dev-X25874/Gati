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
    input i_trigger,
    input i_rstn,
    input [(((W_ADDR + 1) * ROW) -1): 0] i_occupants,
    input [ROW-1:0] i_fifo_empty,
    output [ROW-1:0] o_read_enable
);

reg [ROW-1:0] rden = 0;
reg [1:0] state = 0;

assign o_read_enable = rden;

always @(posedge i_clk)begin
    if(~i_rstn)begin
        rden <= 0;
        state <= 0;
    end else begin
        case (state)
            0: begin
                if(i_trigger)begin
                    state <= 1;
                end
            end
            1: begin
                if(i_fifo_empty == 0)begin
                    rden <= {ROW{1'b1}};
                    state <= 1;
                end else begin
                    rden <= {ROW{1'b0}};
                    state <= 0;
                end
            end 

            2: begin
                rden <= 0;
                state <= 0;
            end
            
            default: state <= 0;
        endcase
    end
end
endmodule