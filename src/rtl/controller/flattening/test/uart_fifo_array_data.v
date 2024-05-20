/*
    This module write the image from single rx_fifo 
    to image_fifo_array ony by one. It also enables 
    the controller which asserts write enable signal of
    fifo in image fifo array one after the other.
*/
module uart_fifo_array_data#(
    parameter W_DATA = 8
)(
    input clk,
    input rstn,
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
    if(~rstn)begin
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
    if(~rstn)begin
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