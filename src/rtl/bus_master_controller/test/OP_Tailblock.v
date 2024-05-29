//this module is a slave module, that when selected receives data from the master block and gives outputs for further tail block(s) operation processing

module OP_Tailblock#(parameter OP_CODE_WIDTH = 4, 
parameter CNT = (OUTPUT_WIDTH/INPUT_WIDTH),
parameter INPUT_WIDTH = 8,
parameter OUTPUT_WIDTH = 256,
parameter ADDRESS_WIDTH = 32,
parameter BNEN_WIDTH = 1,
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
parameter BIASEN_WIDTH = 1,
parameter BNCHANNELS_WIDTH = 10,
parameter FCBIASEN = 1)(
                input [(INPUT_WIDTH)-1 : 0] din,
                input sel,
                input write,
                input done,
                input clk,
                output reg ready = 0,
                output valid,
                output reg [OP_CODE_WIDTH - 1 : 0] opcode = 0,
                output reg [BNEN_WIDTH - 1 : 0] BNEn = 0,
                output reg [BNCHANNELS_WIDTH -1 : 0] BNchannels = 0,
                output reg [ADDRESS_WIDTH - 1 : 0] BNStartAddress = 0,
                output reg [ADDRESS_WIDTH - 1 : 0] BNEndAddress = 0,
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
                output reg [BIASEN_WIDTH - 1 : 0] BiasEn = 0,
                output reg [FCBIASEN - 1 : 0] FCBiasEn = 0,
                output reg [ADDRESS_WIDTH - 1 : 0] BiasStartAddress = 0,
                output reg [ADDRESS_WIDTH - 1 : 0] BiasEndAddress = 0,
                output reg [378:0] dout = 0
        );

        `include "instructions.vh"

reg [(OUTPUT_WIDTH)-1 : 0] data_instruction = 0;
reg [2:0] state = 0;
reg [17:0] count = 0;
parameter IDLE = 3'b000;
parameter REGISTER = 3'b001;
parameter CONCAT = 3'b011; 
parameter OUTPUT_CHECK = 3'b101;
assign valid = done;  //valid gets high as soon as done bit is received indicating that all the respective data has been assigned to the output signals           

always @(posedge clk) begin
    case(state)
    IDLE: begin
        data_instruction <= 0;
        ready <= 0;
        opcode <= 0;
        BNchannels <= 0;
        BNStartAddress <= 0;
        BNEndAddress <= 0;
        ActEn <= 0;
        ActParam <= 0;
        acttype <= 0;
        QuantEn <= 0;
        quantscale <= 0;
        quantshift <= 0;
        PoolEn <= 0;
        pooltype <= 0;
        poolwidth <= 0;
        poolheight <= 0;
        poolstride <= 0;
        poolpadding <= 0;
        BiasEn <= 0;
        FCBiasEn <= 0;
        BiasStartAddress <= 0;
        BiasEndAddress <= 0;
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
        if(done) begin
            opcode <= data_instruction[`TailBlock_Opcode];
            BNchannels <= data_instruction[`TailBlock_BNChannels];
            BNEn <= data_instruction[`TailBlock_BNEn];
            BNStartAddress <= data_instruction[`TailBlock_BNStartAddress];
            BNEndAddress <= data_instruction[`TailBlock_BNEndAddress];
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
            BiasEn <= data_instruction[`TailBlock_BiasEn];
            FCBiasEn <= data_instruction[`TailBlock_FCBiasEn];
            BiasStartAddress <= data_instruction[`TailBlock_BiasStartAddress];
            BiasEndAddress <= data_instruction[`TailBlock_BiasEndAddress];
            //valid <= 1'b1;
            state <= OUTPUT_CHECK;
        end
    end
    OUTPUT_CHECK: begin
        dout <= {BiasEndAddress, BiasStartAddress, FCBiasEn, BiasEn, poolpadding, poolstride, poolheight, poolwidth, pooltype, PoolEn, quantshift, quantscale, QuantEn, acttype, ActParam, ActEn, BNEndAddress, BNStartAddress, BNEn, BNchannels, opcode};  //this concates the different output signals for checking purpose
        state <= IDLE;
        //valid <= 1'b1;
    end
    endcase
end

endmodule