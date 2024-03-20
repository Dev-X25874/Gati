module OP_CONV #(parameter op_code_width = 4, 
            parameter CNT = (data_out/data_in),
            parameter data_in = 8,
            parameter data_out = 256)(
    input [(data_in)-1 : 0] din,
    input sel,
    input write,
    input done,
    output 
    output valid,
    output ready
);
reg [255:0] data_instruction = 0;
reg [1:0] state = 0;
parameter IDLE = 2'b00;
parameter REGISTER = 2'b01;
parameter CONCAT = 2'b11;

always @(posedge clk) begin
    case(state)
    IDLE: begin
        dout_instruction <= 0;
        valid <= 0;
        ready <= 0;
        state <= REGISTER;
    end
    REGISTER: begin
        if(sel) begin
            ready <= 1'b1;
            if(write) begin
                if(count < (CNT-1)) begin
                    data_instruction[data_in-(count*8)-1 -:8] <= din;
                    count <= count + 1;
                    state <= REGISTER;
                end
                else begin
                    data_instruction[data_in-(count*8)-1 -:8] <= din;
                    count <= 0;
                    state <= CONCAT;
                end
            end
        end
    end
    CONCAT: begin
        if(done) begin
            opcode <= data_instruction[3:0];
            IW <= data_instruction[13:4];
            IH <= data_instruction[23:14];
            OW <= data_instruction[33:24];
            OH <= data_instruction[43:34];
            IC <= data_instruction[53:44];
            KN <= data_instruction[63:54];
            KW <= data_instruction[67:64];
            KH <= data_instruction[71:68];
            STRIDE <= data_instruction[75:72];
            PAD <= data_instruction[78:76];
            INPUT_ADDRESS <= data_instruction[110:79];
            channelItr <= data_instruction[122:111];
            kernelItr <= data_instruction[134:123];
            valid <= 1'b1;
        end
    end
    endcase
end

endmodule