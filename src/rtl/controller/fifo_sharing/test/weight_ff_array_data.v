//send data from uart rx fifo into the weight fifo array
module weight_ff_array_data#(
    parameter W_DATA = 8
)(
    input i_clk,
    input i_rstn,
    input i_data_valid,
    input [W_DATA-1 : 0] i_data,
    output [W_DATA-1 : 0] o_data,
    output o_wren
);

reg wren = 0;
reg [W_DATA-1 : 0] data = 0;
// assign o_data = i_data_valid ? i_data : 0;
assign o_wren = wren;
assign o_data = data;

always @(*) begin
    if(~i_rstn)begin
        wren <= 0;
    end else begin
        if(i_data_valid)begin
            wren <= 1'b1;
        end else begin
            wren <= 0;
        end
    end
end

always @(posedge i_clk) begin
    if(~i_rstn)begin
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