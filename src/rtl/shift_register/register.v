module register #(parameter DATA_WIDTH = 8, 
                parameter NUM_SHIFT = 4) (
    input [DATA_WIDTH - 1 : 0] din,
    input valid_quantized_result,
    input clk,
    output reg [DATA_WIDTH -1 : 0] dout = 0,
    output reg valid_out = 0
);

reg [NUM_SHIFT-1 : 0] count = 0;

always @(posedge clk) begin
    if(valid_quantized_result) begin
        if(count == NUM_SHIFT - 1) begin
            valid_out <= 1;
            dout <= din;
            count <= 0;
        end 
        else begin
            valid_out <= 0;
            dout <= din;
            count <= count + 1;
        end  
    end
    else begin
        dout <= dout;
        valid_out <= 0;
    end
end
endmodule