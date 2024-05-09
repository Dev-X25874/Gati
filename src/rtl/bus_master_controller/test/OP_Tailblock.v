//this module is a slave module, that when selected receives data from the master block and gives outputs for further tail block(s) operation processing

module OP_Tailblock#(parameter OP_CODE_WIDTH = 4, 
            parameter CNT = (OUTPUT_WIDTH/INPUT_WIDTH),
            parameter INPUT_WIDTH = 8,
            parameter OUTPUT_WIDTH = 256)(
                input [(INPUT_WIDTH)-1 : 0] din,
                input sel,
                input write,
                input done,
                input clk,
                output reg ready = 0,
                output valid,
                output reg [3:0] opcode = 0,
                output reg BNEn = 0,
                output reg [9:0] BNchannels = 0,
                output reg [31:0] BNStartAddress = 0,
                output reg [31:0] BNEndAddress = 0,
                output reg ActEn = 0,
                output reg [3:0] acttype = 0,
                output reg [7:0] ActParam = 0,
                output reg QuantEn = 0,
                output reg [15:0] quantscale = 0,
                output reg [4:0] quantshift = 0,
                output reg PoolEn = 0,
                output reg [2:0] pooltype = 0,
                output reg [3:0] poolwidth = 0,
                output reg [3:0] poolheight = 0,
                output reg [3:0] poolstride = 0,
                output reg [3:0] poolpadding = 0,
                output reg BiasEn = 0,
                output reg FCBiasEn = 0,
                output reg [31:0] BiasStartAddress = 0,
                output reg [31:0] BiasEndAddress = 0,
                output reg [199:0] dout = 0
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
            opcode <= data_instruction[`Opcode];
            BNchannels <= data_instruction[`BNChannels];
            BNEn <= data_instruction[`BNEn];
            BNStartAddress <= data_instruction[`BNStartAddress];
            BNEndAddress <= data_instruction[`BNEndAddress];
            ActEn <= data_instruction[`ActEn];
            ActParam <= data_instruction[`ActParam]; 
            acttype <= data_instruction[`ActType];
            QuantEn <= data_instruction[`QuantEn];
            quantscale <= data_instruction[`QuantScale];
            quantshift <= data_instruction[`QuantShift];
            PoolEn <= data_instruction[`PoolEn];
            pooltype <= data_instruction[`PoolType];
            poolwidth <= data_instruction[`PoolWidth];
            poolheight <= data_instruction[`PoolHeight];
            poolstride <= data_instruction[`PoolStride];
            poolpadding <= data_instruction[`PoolPadding];
            BiasEn <= data_instruction[`BiasEn];
            FCBiasEn <= data_instruction[`FCBiasEn];
            BiasStartAddress <= data_instruction[`BiasStartAddress];
            BiasEndAddress <= data_instruction[`BiasEndAddress];
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