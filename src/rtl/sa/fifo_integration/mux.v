/*  This mux selects the 32 bit output of a PE block
    If select line is high, it sends weight stored in the weight buffer as output
    If select line is low, it sends the computed data as an output  */
module mux (
    input i_clk,
    input i_sel,
    input [31:0] i_data1,
    input [31:0] i_data2,
    output reg [31:0] o_data = 0
);

always @(posedge i_clk) begin
    if (i_sel)
        o_data <= i_data1;
    else
        o_data <= i_data2;
end

endmodule