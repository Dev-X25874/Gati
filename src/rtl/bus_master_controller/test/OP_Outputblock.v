module OP_Outputblock #(parameter OP_CODE_WIDTH = 4, 
            parameter CNT = (OUTPUT_WIDTH/INPUT_WIDTH),
            parameter INPUT_WIDTH = 8,
            parameter OUTPUT_WIDTH = 256)(
                input [(INPUT_WIDTH)-1 : 0] din,
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
                output reg [138:0] dout = 0,
                output reg [31:0] stop_addr = 0
            );

reg [(OUTPUT_WIDTH)-1 : 0] data_instruction = 0;
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
                    data_instruction[OUTPUT_WIDTH-(count*8)-1 -:8] <= din;
                    count <= count + 1;
                    state <= REGISTER;
                end
                else begin
                    data_instruction[OUTPUT_WIDTH-(count*8)-1 -:8] <= din;
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
            stop_addr <= data_instruction[139:108];
            valid <= 1'b1;
            state <= OUTPUT_CHECK;
        end
    end
    OUTPUT_CHECK: begin
        dout <= {stop_addr,imagedim,kernelItr,channelItr,outputaddr,accumulantaddr,opcode};
        state <= IDLE;
        valid <= 1'b1;
    end
    endcase
end

endmodule