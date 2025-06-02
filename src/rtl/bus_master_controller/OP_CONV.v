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
            parameter KC_WIDTH = 10,
            parameter CONV_TYPE_WIDTH = 2,
            parameter STRIDE_WIDTH = 4,
            //parameter PAD_WIDTH = 3,

            parameter PAD_LEFT_WIDTH = 3,
            parameter PAD_RIGHT_WIDTH = 3,
            parameter PAD_TOP_WIDTH = 3,
            parameter PAD_BOTTOM_WIDTH = 3,

            parameter PADSIDES_WIDTH = 4,
            parameter ADDRESS_WIDTH = 32,
            parameter CONV_Im2colPrefetch_WIDTH = 1,
            parameter CONV_CHANNELDUPLICATE_WIDTH = 1
            )
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
                output reg [KC_WIDTH - 1 : 0] KC = 0,
                output reg [CONV_TYPE_WIDTH - 1 : 0] conv_type = 0,
                output reg [STRIDE_WIDTH - 1 : 0] Stride = 0,
                //output reg [PAD_WIDTH - 1 : 0] Pad = 0,
                
                output reg [PAD_LEFT_WIDTH - 1 : 0] Pad_left = 0,
                output reg [PAD_RIGHT_WIDTH - 1 : 0] Pad_right = 0,
                output reg [PAD_TOP_WIDTH - 1 : 0] Pad_top = 0,
                output reg [PAD_BOTTOM_WIDTH - 1 : 0] Pad_bottom = 0,

                output reg [PADSIDES_WIDTH -1 :0]Pad_side = 0,
                output reg [CONV_Im2colPrefetch_WIDTH - 1 : 0] CONV_Im2colPrefetch = 0,
                output reg [CONV_CHANNELDUPLICATE_WIDTH - 1 : 0] CONV_ChannelDuplicate = 0,
                output reg [ADDRESS_WIDTH - 1 : 0] ImageStartAddress = 0,
                output reg [ADDRESS_WIDTH - 1 : 0] ImageEndAddress = 0,
                output reg [ADDRESS_WIDTH - 1 : 0] WeightStartAddress = 0,
                output reg [ADDRESS_WIDTH - 1 : 0] WeightEndAddress = 0,
                output reg valid,
                output reg ready = 0
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
        valid <= 0;
        ready <= 0;
        // opcode <= 0;
        // IW <= 0;
        // IH <= 0;
        // OW <= 0;
        // OH <= 0;
        // IC <= 0;
        // KN <= 0;
        // KW <= 0;
        // KH <= 0;
        // Stride <= 0;
        // Pad <= 0;
        // ImageStartAddress <= 0;
        // ImageEndAddress <= 0;
        // WeightStartAddress <= 0;
        // WeightEndAddress <= 0;
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
            opcode <= data_instruction[`CONV_Opcode];
            IW <= data_instruction[`CONV_IW];
            IH <= data_instruction[`CONV_IH];
            OW <= data_instruction[`CONV_OW];
            OH <= data_instruction[`CONV_OH];
            IC <= data_instruction[`CONV_IC];
            KN <= data_instruction[`CONV_KN];
            KW <= data_instruction[`CONV_KW];
            KH <= data_instruction[`CONV_KH];
            KC <= data_instruction[`CONV_KC];
            conv_type <= data_instruction[`CONV_ConvType];
            Stride <= data_instruction[`CONV_Stride];
            //Pad <= data_instruction[`CONV_Pad];

            Pad_left <= data_instruction[`CONV_PadLeft];
            Pad_right <= data_instruction[`CONV_PadRight];
            Pad_top <= data_instruction[`CONV_PadTop];
            Pad_bottom <= data_instruction[`CONV_PadBottom];
            

            Pad_side <= data_instruction[`CONV_PadSides];
            CONV_Im2colPrefetch <= data_instruction[`CONV_Im2colPrefetch];
            CONV_ChannelDuplicate <= data_instruction[`CONV_ChannelDuplicate];
            ImageStartAddress <= data_instruction[`CONV_ImageStartAddress];
            ImageEndAddress <= data_instruction[`CONV_ImageEndAddress];
            WeightStartAddress <= data_instruction[`CONV_WeightStartAddress];
            WeightEndAddress <= data_instruction[`CONV_WeightEndAddress];
            valid <= 1'b1;
            state <= IDLE;
        // end
    end
    endcase
end

endmodule
