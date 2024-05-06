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
                output reg [3:0] Stride = 0,
                output reg [2:0] Pad = 0,
                output reg [11:0] channelItr = 0,
                output reg [11:0] kernelItr = 0,
                output reg [31:0] ImageStartAddress = 0,
                output reg [31:0] ImageEndAddress = 0,
                output reg [31:0] WeightStartAddress = 0,
                output reg [31:0] WeightEndAddress = 0,
                output valid,
                output reg ready = 0,
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
        Stride <= 0;
        Pad <= 0;
        channelItr <= 0;
        kernelItr <= 0;
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
            opcode <= data_instruction[Opcode];
            IW <= data_instruction[IW];
            IH <= data_instruction[IH];
            OW <= data_instruction[OW];
            OH <= data_instruction[OH];
            IC <= data_instruction[IC];
            KN <= data_instruction[KN];
            KW <= data_instruction[KW];
            KH <= data_instruction[KH];
            Stride <= data_instruction[Stride];
            Pad <= data_instruction[Pad];
            channelItr <= data_instruction[ChannelItr];
            kernelItr <= data_instruction[KernelItr];
            ImageStartAddress <= data_instruction[ImageStartAddress];
            ImageEndAddress <= data_instruction[ImageEndAddress];
            WeightStartAddress <= data_instruction[WeightStartAddress];
            WeightEndAddress <= data_instruction[WeightEndAddress];
           //valid <= 1'b1;
            state <= OUTPUT_CHECK;
        end
    end
    OUTPUT_CHECK: begin
        dout <= {WeightEndAddress, WeightStartAddress, ImageEndAddress, ImageStartAddress, kernelItr, channelItr, INPUT_ADDRESS, PAD, STRIDE, KH, KW, KN, IC, OH, OW, IH, IW, opcode}; //this concates the different output signals for checking purpose
        //valid <= 1'b1;
        state <= IDLE;
    end
    endcase
end

endmodule