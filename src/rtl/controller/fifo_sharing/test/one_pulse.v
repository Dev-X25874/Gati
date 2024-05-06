//Gives output of one cycle of incoming trigger signal
module one_pulse(
    input a,
    input clk,
    output reg b
);
reg temp_a,temp_b;

always @(a) begin
    temp_a<=a;
end
always @(posedge clk) begin
    temp_b <= temp_a;
    b <= (temp_a & (~temp_b));
end
endmodule