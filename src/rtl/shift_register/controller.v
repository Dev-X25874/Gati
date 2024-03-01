module controller #(parameter no_of_blocks = 4) (
    input clk,
    input [7:0] din,
    input valid_intermediate_result,
    output reg [31:0] intermediate_result = 0,
    output reg [7:0] quantized_result = 0,
    output reg valid_out = 0,
    output reg sel = 0
);

reg [1:0] state = 0;
reg [5:0] count = 0;

always @(posedge clk) begin
    case(state)
    0: begin
        intermediate_result <= 0;
        quantized_result <= 0;
        valid_out <= 0;
        sel <= 0;
        state <= 1;
    end
    1: begin
        if(valid_intermediate_result) begin
            if(count < 4) begin
                intermediate_result[32-(count*8)-1 -:8] <= din;
                count <= count + 1;
                valid_out <= 0;
                state <= 1;
            end
            else begin
                intermediate_result[32-(count*8)-1 -:8] <= din;
                count <= 0;
                valid_out <= 1;
                sel <= 0;
                state <= 2;
            end
        end
    end
    2: begin
        intermediate_result <= intermediate_result;
        count <= 0;
        valid_out <= 0;
        sel <= sel;
        state <= 0;
    end
    endcase
end

endmodule