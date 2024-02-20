module adder # (parameter WIDTH=20)(
    input clk,
    input rst,
    input valid_in,
    input [WIDTH-1:0] first_k,
    input [WIDTH-1:0] second_k,
    output reg valid = 0,
    output reg [WIDTH-1:0] result = 0
);
reg [1:0] state = 0;

always @(posedge clk) begin
    if(rst) begin
        if(valid_in) begin
            result <= first_k + second_k;
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


/**/

        /*case(state)
        0: begin
         valid <= 0;
         result <= 0;
         state <= 1;
        end 
        1: begin
         if(valid_in) begin
             result <= first_k + second_k;
             valid <= 1'b1;
             state <= 0;
         end
         else begin
             result <= result;
             valid <= 1'b0;
             state <= 1;
         end
        end
        endcase*/