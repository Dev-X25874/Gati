 //Gives out one pulse when trigger is applied
module pulse_gen(
    input a,
    input i_rstn,
    input clk,
    output reg b
);
reg temp_a,temp_b;

always @(a) begin
        temp_a <= 0;
        temp_a<=a;
end
always @(posedge clk) begin
    if(~i_rstn)begin
        temp_b <= 0;
        b <= 0;
    end else begin
        temp_b <= temp_a;
        b <= (temp_a & (~temp_b));
    end
end
endmodule