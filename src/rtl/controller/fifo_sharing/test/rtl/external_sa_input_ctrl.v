//controls the write enable signal of internal(inside the engine) north and west fifo array
module external_sa_input_ctrl#(
    parameter W_DATA = 8,
    parameter COL = 32
)(
    input i_clk,
    input i_rst,
    input i_data_valid,
    input [W_DATA-1 : 0] i_data,
    output [W_DATA-1 : 0] o_data,
    output [COL-1 : 0] o_wren
);

reg [COL-1 : 0] wren = 0;
// reg [W_DATA-1 : 0] data = 0;
assign o_data = i_data_valid ? i_data : 0;
assign o_wren = wren;

always @(*) begin
    if(i_rst)begin
        wren <= 0;
    end else begin
        if(i_data_valid)begin
            wren <= {COL{1'b1}};
        end else begin
            wren <= 0;
        end
    end
end
/*
always @(posedge i_clk) begin
    if(i_rst)begin
        data <= 0;
    end else begin
        if(i_data_valid)begin
            data <= i_data;
        end else begin
            data <= data;
        end
    end
end*/
endmodule