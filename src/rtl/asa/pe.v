
//logic for a single processing block element 
module pe (
    input i_clk,
    input i_sel,
    input [8:0] i_west,
    input [31:0] w_p_sum,
    output o_sel,
    output [31:0] o_data,
    output reg [8:0] data8 = 0
);
wire [31:0] mux_in_1;
wire [31:0] mux_in_2;

always @(posedge i_clk) begin 
    data8 <= i_west; 
end 

demux_wb 
dmx_wb (
    .dmx_clk(i_clk),
    .i_sel(i_sel),
    .d_north(w_p_sum),
    .d_west(i_west[7:0]),
    .o_sel(o_sel),
    .mux_d1(mux_in_1),
    .mux_d2(mux_in_2)
);

mux 
multiplexer(
    .i_clk(i_clk),
    .i_sel(i_sel),
    .i_data1(mux_in_1),
    .i_data2(mux_in_2),
    .o_data(o_data)
);

endmodule