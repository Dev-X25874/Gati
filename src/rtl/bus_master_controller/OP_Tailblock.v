//this module is a slave module, that when selected receives data from the master block and gives outputs for further tail block(s) operation processing

module OP_Tailblock#(parameter OP_CODE_WIDTH = 4, 
            parameter CNT = (OUTPUT_WIDTH/INPUT_WIDTH),
            parameter INPUT_WIDTH = 8,
            parameter OUTPUT_WIDTH = 256,
            parameter ADDRESS_WIDTH = 32,
            parameter ACTEN_WIDTH = 1,
            parameter ACTTYPE_WIDTH = 4,
            parameter ACTPARAM_WIDTH = 8,
            parameter QUANTEN_WIDTH = 1,
            parameter QUANTSCALE_WIDTH = 16,
            parameter QUANTSHIFT_WIDTH = 5,
            parameter POOLEN_WIDTH = 1,
            parameter POOLTYPE_WIDTH = 3,
            parameter POOLWIDTH_WIDTH = 4,
            parameter POOLHEIGHT_WIDTH = 4,
            parameter POOLSTRIDE_WIDTH = 4,
            parameter POOLPADDING_WIDTH = 4,
            parameter POOLCEIL_WIDTH = 1,
            parameter POOLMODCOUNT_WIDTH = 4,
            parameter POOLPADSIDES_WIDTH = 4,
            parameter POOLSCALE_WIDTH = 8,
            parameter POOLSHIFT_WIDTH = 4,
            parameter BIASEN_WIDTH = 1,
            parameter BNCHANNELS_WIDTH = 10,
            parameter BiasWidth_WIDTH = 8)
            (
                input [(INPUT_WIDTH)-1 : 0] din,
                input sel,
                input write,
                input done,
                input clk,
                output reg ready = 0,
                output reg valid,
                output reg [OP_CODE_WIDTH - 1 : 0] opcode = 0,
                output reg [ACTEN_WIDTH - 1 : 0] ActEn = 0,
                output reg [ACTTYPE_WIDTH - 1 : 0] acttype = 0,
                output reg [ACTPARAM_WIDTH - 1 : 0] ActParam = 0,
                output reg [QUANTEN_WIDTH - 1 : 0] QuantEn = 0,
                output reg [QUANTSCALE_WIDTH - 1 : 0] quantscale = 0,
                output reg [QUANTSHIFT_WIDTH - 1 : 0] quantshift = 0,
                output reg [POOLEN_WIDTH - 1 : 0] PoolEn = 0,
                output reg [POOLTYPE_WIDTH - 1 : 0] pooltype = 0,
                output reg [POOLWIDTH_WIDTH - 1 : 0] poolwidth = 0,
                output reg [POOLHEIGHT_WIDTH - 1 : 0] poolheight = 0,
                output reg [POOLSTRIDE_WIDTH - 1 : 0] poolstride = 0,
                output reg [POOLPADDING_WIDTH - 1 : 0] poolpadding = 0,
                output reg [POOLCEIL_WIDTH - 1 : 0] poolceil = 0,
                output reg [POOLMODCOUNT_WIDTH - 1 : 0] poolModCount = 0,
                output reg [POOLPADSIDES_WIDTH - 1 : 0] poolpadsides = 0,
                output reg [POOLSCALE_WIDTH - 1 : 0] poolscale = 0,
                output reg [POOLSHIFT_WIDTH - 1 : 0] poolshift = 0,
                output reg [BIASEN_WIDTH - 1 : 0] BiasEn = 0,
                output reg [BiasWidth_WIDTH - 1 : 0] BiasWidth = 0,
                output reg [ADDRESS_WIDTH - 1 : 0] BiasStartAddress = 0,
                output reg [ADDRESS_WIDTH - 1 : 0] BiasEndAddress = 0
        );

        `include "../common/instructions.vh"

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
        // BNchannels <= 0;
        // BNStartAddress <= 0;
        // BNEndAddress <= 0;
        // ActEn <= 0;
        // ActParam <= 0;
        // acttype <= 0;
        // QuantEn <= 0;
        // quantscale <= 0;
        // quantshift <= 0;
        // PoolEn <= 0;
        // pooltype <= 0;
        // poolwidth <= 0;
        // poolheight <= 0;
        // poolstride <= 0;
        // poolpadding <= 0;
        // BiasEn <= 0;
        // FCBiasEn <= 0;
        // BiasStartAddress <= 0;
        // BiasEndAddress <= 0;
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
            opcode <= data_instruction[`TailBlock_Opcode];
            ActEn <= data_instruction[`TailBlock_ActEn];
            ActParam <= data_instruction[`TailBlock_ActParam]; 
            acttype <= data_instruction[`TailBlock_ActType];
            QuantEn <= data_instruction[`TailBlock_QuantEn];
            quantscale <= data_instruction[`TailBlock_QuantScale];
            quantshift <= data_instruction[`TailBlock_QuantShift];
            PoolEn <= data_instruction[`TailBlock_PoolEn];
            pooltype <= data_instruction[`TailBlock_PoolType];
            poolwidth <= data_instruction[`TailBlock_PoolWidth];
            poolheight <= data_instruction[`TailBlock_PoolHeight];
            poolstride <= data_instruction[`TailBlock_PoolStride];
            poolpadding <= data_instruction[`TailBlock_PoolPadding];
            poolceil <= data_instruction[`TailBlock_PoolCeil];
            poolModCount <= data_instruction[`TailBlock_PoolModCount];
            poolpadsides <= data_instruction[`TailBlock_PoolPadSides];
            poolscale <= data_instruction[`TailBlock_PoolScale];
            poolshift <= data_instruction[`TailBlock_PoolShift];
            BiasEn <= data_instruction[`TailBlock_BiasEn];
            BiasWidth <= data_instruction[`TailBlock_BiasWidth];
            BiasStartAddress <= data_instruction[`TailBlock_BiasStartAddress];
            BiasEndAddress <= data_instruction[`TailBlock_BiasEndAddress];
            valid <= 1'b1;
            state <= IDLE;
        // end
    end
    endcase
end

endmodule
