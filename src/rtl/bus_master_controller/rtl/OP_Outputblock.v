//this module is a slave module, that when selected receives data from the master block and gives outputs for further output block operation processing

module OP_Outputblock #(parameter OP_CODE_WIDTH = 4, 
            parameter CNT = (OUTPUT_WIDTH/INPUT_WIDTH),
            parameter INPUT_WIDTH = 8,
            parameter OUTPUT_WIDTH = 256,
            parameter ADDRESS_WIDTH = 32,
            parameter CHANNELITR_WIDTH = 12,
            parameter KERNELITR_WIDTH = 12,
            parameter IMAGEDIMOUTPUT_WIDTH = 16,
            parameter IMAGEDIMACC_WIDTH = 16,
            parameter ACCEN_WIDTH = 1,
            parameter DISPATCH_ID_WIDTH = 32,
            parameter DISPATCHEN_WIDTH = 1)
            (
                input [(INPUT_WIDTH)-1 : 0] din,
                input sel,
                input write,
                input done,
                input clk,
                output reg valid,
                output reg ready = 0,
                output reg [OP_CODE_WIDTH -1 : 0] opcode = 0,
                output reg [ADDRESS_WIDTH - 1 : 0] accumulantaddr = 0,
                output reg [ADDRESS_WIDTH - 1 : 0] outputaddr = 0,
                output reg [CHANNELITR_WIDTH -1 : 0] channelItr = 0,
                output reg [KERNELITR_WIDTH - 1 : 0] kernelItr = 0,
                output reg [IMAGEDIMOUTPUT_WIDTH -1 : 0] ImageDimOutput = 0,
                output reg [IMAGEDIMACC_WIDTH -1 : 0] ImageDimAcc = 0,
                output reg [ACCEN_WIDTH -1 : 0] AccEn = 0,
                output reg [DISPATCHEN_WIDTH-1 : 0] DispatchEn = 0,
                output reg [DISPATCH_ID_WIDTH-1 :0] DispatchId = 0
            );

            `include "instructions.vh"

reg [(OUTPUT_WIDTH)-1 : 0] data_instruction = 0;
reg [2:0] state = 0;
reg [17:0] count = 0;
parameter IDLE = 3'b000;
parameter REGISTER = 3'b001;
parameter CONCAT = 3'b011; 
// assign valid = done;  //valid gets high as soon as done bit is received indicating that all the respective data has been assigned to the output signals           


always @(posedge clk) begin
    case(state)
    IDLE: begin
        data_instruction <= 0;
        ready <= 0;
        valid <= 0;
        // opcode <= 0;
        // accumulantaddr <= 0;
        // outputaddr <= 0;
        // channelItr <= 0;
        // kernelItr <= 0;
        // ImageDimOutput <= 0;
        // ImageDimAcc <= 0;
        // AccEn <= 0;
        count <= 0;
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
        // if(done) begin
            opcode <= data_instruction[`OutputBlock_Opcode];
            accumulantaddr <= data_instruction[`OutputBlock_AccumulantAddr];
            outputaddr <= data_instruction[`OutputBlock_OutputAddr];
            channelItr <= data_instruction[`OutputBlock_ChannelItr];
            kernelItr <= data_instruction[`OutputBlock_KernelItr];
            ImageDimOutput <= data_instruction[`OutputBlock_ImageDimOutput];
            ImageDimAcc <= data_instruction[`OutputBlock_ImageDimAcc];
            AccEn <= data_instruction[`OutputBlock_AccEn];
            DispatchId <= data_instruction[`OutputBlock_DispatchID];
            DispatchEn <= data_instruction[`OutputBlock_DispatchEn];
            valid <= 1'b1;
            state <= IDLE;
        // end
    end
    endcase
end

endmodule
