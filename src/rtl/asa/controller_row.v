//Load data from array of fifo into systolic array
module controller_row #(
    parameter ROW = 9,
    parameter W_DATA = 8
)(
    input i_clk,
    input i_trigger,
    input [ROW-1:0] i_fifo_empty,
    input [(ROW * (W_DATA + 1) -1) : 0] i_data,
    output [(ROW * (W_DATA + 1)) -1:0] o_data,
    output [ROW-1:0] o_read_enable
);

reg [ROW-1:0] rden = 0;
assign o_read_enable = rden;
assign o_data =  i_data ;

always @(posedge i_clk)begin
    if(i_fifo_empty == 0)begin
        rden <= ~rden;
    end else begin
        rden <=0;
    end
end
endmodule