/*
    This module write the weights from single rx_fifo 
    to weight_fifo_array ony by one. It also enables 
    the controller which asserts write enable signal of
    fifo in weight fifo array one after the other.
*/
module weight_fifo_array_data#(
    parameter W_DATA = 8
)(
    input clk,
    input rst,
    input i_data_valid,
    input [W_DATA-1 : 0] i_data,
    output o_enable,
    output [W_DATA-1 : 0] o_data
);

reg enb = 0;
reg [W_DATA-1 : 0] data = 0;
assign o_enable = enb;
assign o_data = data;

always @(*) begin
    if(rst)begin
        enb <= 1'b0;
    end else begin
        if(i_data_valid)begin
            enb <= 1'b1;
        end else begin
            enb <= 1'b0;
        end
    end
end

always @(posedge clk) begin
    if(rst)begin
        data <= 0;    
    end else begin
        if(i_data_valid)begin
            data <= i_data;
        end else begin
            data <= data;
        end
    end
end
    
endmodule