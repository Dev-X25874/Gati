module register #(parameter DATA_WIDTH = 8) (
    input [DATA_WIDTH - 1 : 0] din,
    input valid_intermediate_result,
    input valid_quantized_result,
    input clk,
    input sel,
    output reg [DATA_WIDTH -1 : 0] dout = 0,
    output reg valid_out = 0
);

reg [4:0] count = 0;

always @(posedge clk) begin
    if(valid_intermediate_result | valid_quantized_result) begin
        if(sel == 0) begin
            dout <= din;
            valid_out <= 1;
        end
        else begin
            if(count == 3) begin
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
    end
    else begin
        dout <= 0;
        valid_out <= 0;
    end
end
endmodule