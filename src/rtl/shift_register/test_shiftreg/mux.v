//this module is for performing mux operation and assigning the appropriate input data to output as per the select line chosen

module mux(
    input [7:0] intermediate_result,
    input [7:0] quantized_result,
    input sel,
    output reg [7:0] dout = 0
);

always @(*) begin
    case(sel)
    1'b0: begin
        dout <= intermediate_result;
    end 
    1'b1: begin
        dout <= quantized_result;
    end
    endcase
end

endmodule