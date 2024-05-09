module controller_rx #(parameter op_code_width = 4, 
            parameter data_in = 256) (
    input [7:0] din,
    input rx_valid,
    input clk,
    output reg [(op_code_width)-1 : 0] opcode = 0,
    output reg [(data_in)-1 : 0] dout = 0,
    output reg dout_valid = 0
);

reg [4:0] count_opcode = 0;
reg [17:0] count_instruction = 0;
reg [1:0] state = 0;

always @(posedge clk) begin
    case(state)
    0: begin
        opcode <= opcode;
        dout <= dout;
        state <= 1;
        dout_valid <= 0;
    end
    1: begin
        if(rx_valid) begin
            opcode <= 3'd0;
            state <= 2;
            dout_valid <= 0;
        end
        else begin
            opcode <= opcode;
            state <= 1;
            dout_valid <= 0;
        end
    end
    2: begin
        if(rx_valid) begin
            if(count_instruction < 32) begin
                dout[data_in-(count_instruction*8)-1 -:8] <= din;
                count_instruction <= count_instruction + 1;
                state <= 2;
            end
            else begin
               dout[data_in-(count_instruction*8)-1 -:8] <= din;
               count_instruction <= 0;
               dout_valid <= 1'b1;
               state <= 0; 
            end
        end
        else begin
            dout <= dout;
            count_instruction <= count_instruction;
            state <= 2;
            dout_valid <= 0;
        end
    end
    endcase
end

endmodule