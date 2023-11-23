`timescale 1ns / 1ps
module controller_row #(
    parameter ROW = 9
)(
    input i_clk,
    input i_trigger,
    input [ROW-1:0] i_fifo_empty,
    input [(ROW * 9) -1 : 0] i_data,
    output [(ROW * 9) -1:0] o_data,
    output [ROW-1:0] o_read_enable
);

reg [ROW-1:0] rden = 0;
assign o_read_enable = rden;
assign o_data =  i_data ;

always @(posedge i_clk)begin
    //if((i_fifo_empty == 0) && (i_trigger))begin
    if(i_fifo_empty == 0)begin
        rden <= ~rden;
    end else begin
        rden <=0;
    end
end
endmodule