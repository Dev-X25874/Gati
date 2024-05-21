module controller(
    input clk,
    input rx_valid,
    input [7:0] din,
    output reg [7:0] dout = 0,
    output reg datavalid = 0,
    output reg [2:0] pooling_type = 0,
    output reg [3:0] pool_width = 0,
    output reg [3:0] pool_height = 0,
    output reg [9:0] OH = 0,
    output reg [9:0] OW = 0

);

reg [4:0] counter = 0;
reg [1:0] state = 0;

always @(posedge clk) begin
    case(state) 
    0: begin
        dout <= 0;
        datavalid <= 0;
        pooling_type <= 0;
        pool_width <= 0;
        pool_height <= 0;
        OH <= 0;
        OW <= 0;
        state <= 1;
    end
    1: begin
        if(rx_valid) begin
            pooling_type <= 3'b0;
            pool_width <= 4'd3;
            pool_height <= 4'd3;
            OH <= 10'd28;
            OW <= 10'd28;
            state <= 2;
        end
    end
    2: begin
        if(rx_valid) begin
            if(counter < 8) begin
                dout <= din;
                counter <= counter + 1;
                datavalid <= 1;
                state <= 2;
            end
            else begin
                dout <= 0;
                state <= 0;
                datavalid <= 0;
            end
        end
        else begin
            dout <= dout;
            state <= 2;
            datavalid <= 0;
        end
    end
    endcase
end

endmodule