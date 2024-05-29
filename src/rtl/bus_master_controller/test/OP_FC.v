//this module is a slave module, that when selected receives data from the master block and gives outputs for further fully-connected operation processing

module OP_FC#(parameter OP_CODE_WIDTH = 4, 
parameter CNT = (OUTPUT_WIDTH/INPUT_WIDTH),
parameter INPUT_WIDTH = 8,
parameter OUTPUT_WIDTH = 256,
parameter ADDRESS_WIDTH = 32,
parameter WEIGHTROWS_WIDTH = 16,
parameter WEIGHTCOLS_WIDTH = 16,
parameter INPUTROWS_WIDTH = 16,
parameter DROPOUTCONSTANT_WIDTH = 8,
parameter FLATTEN_WIDTH = 1,
parameter IMAGEDIN_WIDTH = 20,
parameter Vec2MatCols_WIDTH = 16)(
                input [(INPUT_WIDTH)-1 : 0] din,
                input sel,
                input write,
                input done,
                input clk,
                output valid,
                output reg ready = 0,
                output reg [OP_CODE_WIDTH - 1 : 0] opcode = 0,
                output reg [WEIGHTROWS_WIDTH - 1 : 0] weightrows = 0,
                output reg [WEIGHTCOLS_WIDTH - 1 : 0] weightcols = 0,
                output reg [INPUTROWS_WIDTH - 1 : 0] inputrows = 0,
                output reg [DROPOUTCONSTANT_WIDTH -1 : 0] dropoutconstant = 0,
                output reg [FLATTEN_WIDTH -1 : 0] flatten = 0,
                output reg [IMAGEDIN_WIDTH -1 : 0] imagedim = 0,
                output reg [ADDRESS_WIDTH - 1 : 0] ImageStartAddress = 0,
                output reg [ADDRESS_WIDTH - 1 : 0] ImageEndAddr = 0,
                output reg [ADDRESS_WIDTH - 1 : 0] WeightStartAddress = 0,
                output reg [ADDRESS_WIDTH - 1 : 0] WeightEndAddress = 0,
                output reg [Vec2MatCols_WIDTH -1 : 0] Vec2MatCols = 0,
                output reg [151:0] dout = 0
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
        weightrows <= 0;
        weightcols <= 0;
        inputrows <= 0;
        dropoutconstant <= 0;
        flatten <= 0;
        imagedim <= 0;
        ImageStartAddress <= 0;
        ImageEndAddr <= 0;
        WeightStartAddress <= 0;
        WeightEndAddress <= 0;
        Vec2MatCols <= 0;
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
            opcode <= data_instruction[`FC_Opcode];
            weightrows <= data_instruction[`FC_WeightRows];
            weightcols <= data_instruction[`FC_WeightCols];
            inputrows <= data_instruction[`FC_InputRows];
            dropoutconstant <= data_instruction[`FC_DropoutConstant];
            flatten <= data_instruction[`FC_Flatten];
            imagedim <= data_instruction[`FC_ImageDim];
            ImageStartAddress <= data_instruction[`FC_ImageStartAddress];   
            ImageEndAddr <= data_instruction[`FC_ImageEndAddr];
            WeightStartAddress <= data_instruction[`FC_WeightStartAddress];
            WeightEndAddress <= data_instruction[`FC_WeightEndAddress];
            Vec2MatCols <= data_instruction[`FC_Vec2MatCols];
            state <= OUTPUT_CHECK;
        end
    end
    OUTPUT_CHECK: begin
        dout <= {Vec2MatCols, WeightStartAddress, WeightEndAddress, ImageEndAddr,ImageStartAddress, imagedim, flatten, dropoutconstant, inputrows, weightcols, weightrows, opcode}; //this concates the different output signals for checking purpose
        //valid <= 1'b1;
        state <= IDLE;
    end
    endcase
end

endmodule