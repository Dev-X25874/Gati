//Gives output of one cycle of incoming trigger signal
module one_cycle(
    input a,
    input rst,
    input clk,
    output reg b
);
reg temp_a,temp_b;

always @(a) begin
    if(rst)
        temp_a <= 0;
    else
        temp_a<=a;
end
always @(posedge clk) begin
    if(rst)begin
        temp_b <= 0;
        b <= 0;
    end else begin
        temp_b <= temp_a;
        b <= (temp_a & (~temp_b));
    end
end
endmodule