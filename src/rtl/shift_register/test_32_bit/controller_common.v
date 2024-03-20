module controller_common(
    input clk,
    input [7:0] din,
    input rx_valid,
    output reg sel = 0,
    output reg [31:0] intermediate_result = 0,
    output reg [7:0] quantized_result = 0,
    output reg valid_out = 0
);
reg [2:0] state = 0;
reg [4:0] count = 0;
parameter IDLE = 3'b000;
parameter SEL = 3'b001;
parameter DATA = 3'b011;
parameter WAIT = 3'b111;

always @(posedge clk) begin
    case(state)
    IDLE: begin
        valid_out <= 0;
        quantized_result <= quantized_result;
        intermediate_result <= 0;
        sel <= sel;
        if(rx_valid) begin
            state <= SEL;
        end
        else begin
            state <= IDLE;
        end
    end
    SEL: begin
            sel <= din[0];
            valid_out <= 0;
            state <= DATA;
            quantized_result <= quantized_result;
            intermediate_result <= intermediate_result;
    end
    WAIT: begin
        quantized_result <= quantized_result;
        valid_out <= 0;
        sel <= sel;
        state <= DATA;
    end
    DATA: begin
        if(sel) begin
            if(rx_valid) begin
                quantized_result <= din;
                valid_out <= 1'b1;
                state <= WAIT;
            end
            else begin
                quantized_result <= quantized_result;
                valid_out <= 1'b0;
                state <= DATA;
            end
        end
        else begin
            if(rx_valid) begin
                if(count < 4) begin
                    intermediate_result[32-(count*8)-1 -:8] <= din;
                    count <= count + 1;
                    valid_out <= 0;
                    state <= DATA; 
                end
                else begin
                    intermediate_result[32-(count*8)-1 -:8] <= din;
                    count <= 0;
                    valid_out <= 1;
                    state <= SEL;
                end
            end
            else begin
                intermediate_result <= intermediate_result;
                state <= DATA;
                valid_out <= 0;
                count <= count;
                end
            end
    end
    /*WAIT: begin
        valid_out <= 0;
        state <= IDLE;
    end*/
    endcase
end

endmodule













 /* if(count < 4) begin
                if(rx_valid) begin
                    intermediate_result[32-(count*8)-1 -:8] <= din;
                    count <= count + 1;
                    valid_out <= 0;
                    state <= DATA;
                end
                else begin
                    intermediate_result <= intermediate_result;
                    state <= DATA;
                    valid_out <= 0;
                    count <= count;
                end
            end
            else begin
                if(rx_valid) begin
                    intermediate_result[32-(count*8)-1 -:8] <= din;
                    count <= 0;
                    valid_out <= 1;
                    state <= IDLE;
                end
                else begin
                    intermediate_result <= intermediate_result;
                    count <= count;
                    valid_out <= 0;
                    state <= DATA;
                end
            end
        end*/
