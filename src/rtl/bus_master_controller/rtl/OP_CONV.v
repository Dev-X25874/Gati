//this module is the slave block, it handles the operations for convolution block
//when this module will be selected it will receive data from the master block and gives output for further convolution operation processing 

module OP_CONV #(parameter OP_CODE_WIDTH = 4, 
            parameter CNT = (OUTPUT_WIDTH/INPUT_WIDTH),
            parameter INPUT_WIDTH = 8,
            parameter OUTPUT_WIDTH = 256)(
                input [(INPUT_WIDTH)-1 : 0] din,
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
                output reg [31:0] stop_addr = 0,
                output valid,
                output reg ready = 0
            );

            `include "instructions.vh"

reg [(OUTPUT_WIDTH)-1 : 0] data_instruction = 0;
reg [2:0] state = 0;
reg [17:0] count = 0;
parameter IDLE = 3'b000;
parameter REGISTER = 3'b001;
parameter CONCAT = 3'b011;
assign valid = done;  //valid gets high as soon as done bit is received indicating that all the respective data has been assigned to the output signals

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
            opcode <= data_instruction[Opcode];
            IW <= data_instruction[IW];
            IH <= data_instruction[IH];
            OW <= data_instruction[OW];
            OH <= data_instruction[OH];
            IC <= data_instruction[IC];
            KN <= data_instruction[KN];
            KW <= data_instruction[KW];
            KH <= data_instruction[KH];
            STRIDE <= data_instruction[STRIDE];
            PAD <= data_instruction[PAD];
            INPUT_ADDRESS <= data_instruction[INPUT_ADDRESS];
            channelItr <= data_instruction[ChannelItr];
            kernelItr <= data_instruction[KernelItr];
            stop_addr <= data_instruction[stop_addr];
           //valid <= 1'b1;
            state <= IDLE;
        end
    end
    endcase
end

endmodule