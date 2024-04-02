//this module adds the outputs coming from 2 consecutive engines

module adder # (parameter WIDTH=20)(
    input clk,
    input rst,
    input valid_in,
    input [WIDTH-1:0] first_k, //input from an engine
    input [WIDTH-1:0] second_k, //input from another engine
    output reg valid = 0,
    output reg [WIDTH-1:0] result = 0
);

always @(posedge clk) begin
    if(rst) begin
        if(valid_in) begin
            result <= first_k + second_k; //adder tree result
            valid <= 1'b1;
        end
        else begin
            result <= result;
            valid <= 1'b0;
        end 
    end
    else begin
        result <= 0;
        valid <= 1'b0;
    end
end
endmodule
