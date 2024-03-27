module OP_CONV #(parameter op_code_width = 4, 
            parameter CNT = (data_out/data_in),
            parameter data_in = 8,
            parameter data_out = 256)(
                input [(data_in)-1 : 0] din,
                input sel,
                input write,
                input done,
                input clk,
                output reg [3:0] opcode = 0,
                output reg [9:0] IW = 0,
                output reg [9:0] IH = 0,
                output reg [9:0] OW = 0,
                output reg [9:0] OH = 0,
                output reg [9:0] IC = 0,
                output reg [9:0] KN = 0,
                output reg [13:0] KW = 0,
                output reg [3:0] KH = 0,
                output reg [3:0] STRIDE = 0,
                output reg [2:0] PAD = 0,
                output reg [31:0] INPUT_ADDRESS = 0,
                output reg [11:0] channelItr = 0,
                output reg [11:0] kernelItr = 0,
                output valid,
                output reg ready = 0,
                output reg [144:0] dout = 0
            );
reg [(data_out)-1 : 0] data_instruction = 0;
reg [2:0] state = 0;
reg [17:0] count = 0;
parameter IDLE = 3'b000;
parameter REGISTER = 3'b001;
parameter CONCAT = 3'b011;
parameter OUTPUT_CHECK = 3'b101;
assign valid = done;

always @(posedge clk) begin
    case(state)
    IDLE: begin
        data_instruction <= 0;
       // valid <= 0;
        ready <= 0;
        opcode = 0;
        IW <= 0;
        IH <= 0;
        OW <= 0;
        OH <= 0;
        IC <= 0;
        KN <= 0;
        KW <= 0;
        KH <= 0;
        STRIDE <= 0;
        PAD <= 0;
        INPUT_ADDRESS <= 0;
        channelItr <= 0;
        kernelItr <= 0;
        state <= REGISTER;
    end
    REGISTER: begin
        if(sel) begin
            ready <= 1'b1;
            if(write) begin
                if(count < (CNT-1)) begin
                    data_instruction[data_out-(count*8)-1 -:8] <= din;
                    count <= count + 1;
                    state <= REGISTER;
                end
                else begin
                    data_instruction[data_out-(count*8)-1 -:8] <= din;
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
            //valid <= 1'b1;
            state <= OUTPUT_CHECK;
        end
    end
    OUTPUT_CHECK: begin
        dout <= {kernelItr, channelItr, INPUT_ADDRESS, PAD, STRIDE, KH, KW, KN, IC, OH, OW, IH, IW, opcode};
        //valid <= 1'b1;
        state <= IDLE;
    end
    endcase
end

endmodule