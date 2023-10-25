module wren_register(
    input i_clk,
    input i_data,
    output o_data,
    output o_wren
);

reg data = 0;
reg wren = 0;

assign o_data = data;
assign o_wren = wren;

always @(posedge i_clk)begin
    data <= i_data;
    wren <= i_data;
end

endmodule