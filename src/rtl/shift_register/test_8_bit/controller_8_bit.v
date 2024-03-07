module controller_8_bit #(parameter no_of_blocks = 4) (
    input clk,
    input [7:0] din,
    input valid_quantized_result,
    output reg [7:0] quantized_result = 0,
    output reg valid_out = 0,
    output reg sel = 0
);

reg [1:0] state = 0;

always @(posedge clk) begin
    case(state)
    0: begin
        //intermediate_result <= intermediate_result;
        quantized_result <= quantized_result;
        valid_out <= 0;
        sel <= 0;
        state <= 1;
    end
    1: begin
        if(valid_quantized_result) begin
            quantized_result <= din;
            valid_out <= 1;
            sel <= 1;
        end
    end
    endcase
end

endmodule