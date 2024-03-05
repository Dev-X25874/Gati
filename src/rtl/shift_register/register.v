module register(
    input [7:0] din,
    input valid,
    input clk,
    input sel,
    output reg [7:0] dout = 0,
    output reg valid_out = 0
);

reg [4:0] count = 0;

always @(posedge clk) begin
    if(valid) begin
        if(sel == 0) begin
            dout <= din;
            valid_out <= 1;
        end
        else begin
            if(count == 4) begin
                valid_out <= 1;
                dout <= dout;
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
        dout <= dout;
        valid_out <= 0;
    end
end
endmodule