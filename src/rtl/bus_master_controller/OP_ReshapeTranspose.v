//this module is the slave block, it handles the operations for convolution block
//when this module will be selected it will receive data from the master block and gives output for further convolution operation processing 

module OP_ReshapeTranspose #(parameter OP_CODE_WIDTH = 4, 
            parameter CNT = (OUTPUT_WIDTH/INPUT_WIDTH),
            parameter INPUT_WIDTH = 8,
            parameter OUTPUT_WIDTH = 256,
            parameter ADDRESS_WIDTH = 32,
            parameter IW_WIDTH = 10,
            parameter IH_WIDTH = 10,
            parameter IC_WIDTH = 10
            )
            (
                input [(INPUT_WIDTH)-1 : 0] din,
                input sel,
                input write,
                input done,
                input clk,
                output reg [OP_CODE_WIDTH - 1 : 0] opcode = 0,
                output reg [IW_WIDTH - 1 : 0] ReshapeTranspose_IW,
                output reg [IH_WIDTH - 1 : 0] ReshapeTranspose_IH,
                output reg [IC_WIDTH - 1 : 0] ReshapeTranspose_IC,   
                output reg [ADDRESS_WIDTH - 1 : 0] ReshapeTranspose_StartAddress,
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
            opcode <= data_instruction[`TRANSPOSE_Opcode];
            ReshapeTranspose_IW <= data_instruction[`TRANSPOSE_IW];
            ReshapeTranspose_IH <= data_instruction[`TRANSPOSE_IH];
            ReshapeTranspose_IC <= data_instruction[`TRANSPOSE_IC];
            ReshapeTranspose_StartAddress <= data_instruction[`TRANSPOSE_ImageStartAddress];
            valid <= 1'b1;
            state <= IDLE;
        // end
    end
    endcase
end

endmodule
