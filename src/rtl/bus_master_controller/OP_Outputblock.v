module OP_Outputblock #(parameter op_code_width = 4, 
            parameter CNT = (data_out/data_in),
            parameter data_in = 8,
            parameter data_out = 256)(
                input [(data_in)-1 : 0] din,
                input sel,
                input write,
                input done,
                input clk,
                output reg valid = 0,
                output reg ready = 0,
                output reg [3:0] opcode = 0,
                output reg [31:0] accumulantaddr = 0,
                output reg [31:0] outputaddr = 0,
                output reg [11:0] channelItr = 0,
                output reg [11:0] kernelItr = 0,
                output reg [15:0] imagedim = 0,
                output reg [107:0] dout = 0
            );

reg [(data_out)-1 : 0] data_instruction = 0;
reg [2:0] state = 0;
reg [17:0] count = 0;
parameter IDLE = 3'b000;
parameter REGISTER = 3'b001;
parameter CONCAT = 3'b011;   
parameter OUTPUT_CHECK = 3'b101;         

always @(posedge clk) begin
    case(state)
    IDLE: begin
        data_instruction <= 0;
        valid <= 0;
        ready <= 0;
        opcode <= 0;
        accumulantaddr <= 0;
        outputaddr <= 0;
        channelItr <= 0;
        kernelItr <= 0;
        imagedim <= 0;
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
            accumulantaddr <= data_instruction[35:4];
            outputaddr <= data_instruction[67:36];
            channelItr <= data_instruction[79:68];
            kernelItr <= data_instruction[91:80];
            imagedim <= data_instruction[107:92];
            valid <= 1'b1;
            state <= OUTPUT_CHECK;
        end
    end
    OUTPUT_CHECK: begin
        dout <= {imagedim,kernelItr,channelItr,outputaddr,accumulantaddr,opcode};
        state <= IDLE;
    end
    endcase
end

endmodule