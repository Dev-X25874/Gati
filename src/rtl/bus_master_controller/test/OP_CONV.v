//this module is the slave block, it handles the operations for convolution block
//when this module will be selected it will receive data from the master block and gives output for further convolution operation processing 

module OP_CONV #(parameter OP_CODE_WIDTH = 4, 
                parameter CNT = (OUTPUT_WIDTH/INPUT_WIDTH),
                parameter INPUT_WIDTH = 8,
                parameter OUTPUT_WIDTH = 256,
                parameter IW_WIDTH = 10,
                parameter IH_WIDTH = 10,
                parameter OW_WIDTH = 10,
                parameter OH_WIDTH = 10,
                parameter IC_WIDTH = 10,
                parameter KN_WIDTH = 10,
                parameter KW_WIDTH = 4,
                parameter KH_WIDTH = 4,
                parameter STRIDE_WIDTH = 4,
                parameter PAD_WIDTH = 3,
                parameter ADDRESS_WIDTH = 32)
                (
                input [(INPUT_WIDTH)-1 : 0] din,
                input sel,
                input write,
                input done,
                input clk,
                output reg [OP_CODE_WIDTH - 1 : 0] opcode = 0,
                output reg [IW_WIDTH - 1 : 0] IW = 0,
                output reg [IH_WIDTH - 1 : 0] IH = 0,
                output reg [OW_WIDTH - 1 : 0] OW = 0,
                output reg [OH_WIDTH - 1 : 0] OH = 0,
                output reg [IC_WIDTH - 1 : 0] IC = 0,
                output reg [KN_WIDTH - 1 : 0] KN = 0,
                output reg [KW_WIDTH - 1 : 0] KW = 0,
                output reg [KH_WIDTH - 1 : 0] KH = 0,
                output reg [STRIDE_WIDTH - 1 : 0] Stride = 0,
                output reg [PAD_WIDTH - 1 : 0] Pad = 0,
                output reg [ADDRESS_WIDTH - 1 : 0] ImageStartAddress = 0,
                output reg [ADDRESS_WIDTH - 1 : 0] ImageEndAddress = 0,
                output reg [ADDRESS_WIDTH - 1 : 0] WeightStartAddress = 0,
                output reg [ADDRESS_WIDTH - 1 : 0] WeightEndAddress = 0,
                output valid,
                output reg ready = 0
                output reg [272:0] dout = 0
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
        ImageStartAddress <= 0;
        ImageEndAddress <= 0;
        WeightStartAddress <= 0;
        WeightEndAddress <= 0;
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
            opcode <= data_instruction[`CONV_Opcode];
            IW <= data_instruction[`CONV_IW];
            IH <= data_instruction[`CONV_IH];
            OW <= data_instruction[`CONV_OW];
            OH <= data_instruction[`CONV_OH];
            IC <= data_instruction[`CONV_IC];
            KN <= data_instruction[`CONV_KN];
            KW <= data_instruction[`CONV_KW];
            KH <= data_instruction[`CONV_KH];
            Stride <= data_instruction[`CONV_Stride];
            Pad <= data_instruction[`CONV_Pad];
            ImageStartAddress <= data_instruction[`CONV_ImageStartAddress];
            ImageEndAddress <= data_instruction[`CONV_ImageEndAddress];
            WeightStartAddress <= data_instruction[`CONV_WeightStartAddress];
            WeightEndAddress <= data_instruction[`CONV_WeightEndAddress];
           //valid <= 1'b1;
            state <= OUTPUT_CHECK;
        end
    end
    OUTPUT_CHECK: begin
        dout <= {WeightEndAddress, WeightStartAddress, ImageEndAddress, ImageStartAddress, PAD, STRIDE, KH, KW, KN, IC, OH, OW, IH, IW, opcode}; //this concates the different output signals for checking purpose
        //valid <= 1'b1;
        state <= IDLE;
    end
    endcase
end

endmodule