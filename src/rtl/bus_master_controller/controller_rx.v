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
        opcode <= 0;
        dout <= 0;
        state <= 1;
    end
    1: begin
        if(rx_valid) begin
            if(count_opcode < 3) begin
                opcode <= din[8-(count_opcode*8)-1 -:8];
                count_opcode <= count_opcode + 1;
                state <= 1;
            end
            else begin
                opcode <= din[8-(count_opcode*8)-1 -:8];
                count_opcode <= 0;
                state <= 2;
            end
        end
    end
    2: begin
        if(rx_valid) begin
            if(count_instruction < 255) begin
                dout <= din[8-(count_instruction*8)-1 -:8];
                count_instruction <= count_instruction + 1;
                state <= 2;
            end
            else begin
               dout <= din[8-(count_instruction*8)-1 -:8];
               count_instruction <= 0;
               dout_valid <= 1'b1;
               state <= 0; 
            end
        end
    end
    endcase
end

endmodule