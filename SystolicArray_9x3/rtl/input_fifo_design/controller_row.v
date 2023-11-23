/*
    Controlls read enable signal of array of fifo that loads
    data into columns of systolc array.
*/
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
    
reg [71:0] data = 0;
reg [ROW-1:0] rden = 0;
reg [1:0] state = 0;
    
assign o_read_enable = rden;
assign o_data =  i_data ;
    
always @(posedge i_clk)begin
    if(~i_fifo_empty[0] && ~i_fifo_empty[1] && ~i_fifo_empty[2] && ~i_fifo_empty[3]
        && ~i_fifo_empty[4] && ~i_fifo_empty[5] && ~i_fifo_empty[6] && ~i_fifo_empty[7] 
        && ~i_fifo_empty[8] && i_trigger) begin
            rden <= 9'd511;
    end else begin
            rden <= 9'd0;
    end
end
endmodule