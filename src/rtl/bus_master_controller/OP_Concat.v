// CONCAT Mega block 


`include "../common/instructions.vh"

module OP_Concat #(
    parameter OP_CODE_WIDTH = 4,
    parameter OUTPUT_WIDTH = 256,
    parameter CNT = (OUTPUT_WIDTH/INPUT_WIDTH),
    parameter INPUT_WIDTH = 8,
    parameter CONCAT_Image1StartAddress_WIDTH = 32,
    parameter CONCAT_Image2StartAddress_WIDTH = 32,
    parameter CONCAT_Image3StartAddress_WIDTH = 32,
    parameter CONCAT_Image4StartAddress_WIDTH = 32,
    parameter CONCAT_IH1_WIDTH = 10,
    parameter CONCAT_IH2_WIDTH = 10,
    parameter CONCAT_IH3_WIDTH = 10,
    parameter CONCAT_IH4_WIDTH = 10,
    parameter CONCAT_KN1_WIDTH = 10,
    parameter CONCAT_KN2_WIDTH = 10,
    parameter CONCAT_KN3_WIDTH = 10,
    parameter CONCAT_KN4_WIDTH = 10,
    parameter CONCAT_InNum_WIDTH = 3

    )(
    input [(INPUT_WIDTH)-1 : 0] din,
    input sel,
    input write,
    input done,
    input clk,
    output reg [OP_CODE_WIDTH - 1 : 0] opcode = 0,
    output reg [CONCAT_InNum_WIDTH -1 : 0] CONCAT_InNum =0,

    output reg [CONCAT_Image1StartAddress_WIDTH -1 : 0] CONCAT_StartAdd_1 = 0,
    output reg [CONCAT_Image2StartAddress_WIDTH -1 : 0] CONCAT_StartAdd_2 = 0,
    output reg [CONCAT_Image3StartAddress_WIDTH -1 : 0] CONCAT_StartAdd_3 = 0,
    output reg [CONCAT_Image4StartAddress_WIDTH -1 : 0] CONCAT_StartAdd_4 = 0,
    output reg [CONCAT_IH1_WIDTH -1 : 0] CONCAT_IH_1 = 0,
    output reg [CONCAT_IH2_WIDTH -1 : 0] CONCAT_IH_2 = 0,
    output reg [CONCAT_IH3_WIDTH -1 : 0] CONCAT_IH_3 = 0,
    output reg [CONCAT_IH4_WIDTH -1 : 0] CONCAT_IH_4 = 0,
    output reg [CONCAT_KN1_WIDTH -1 : 0] CONCAT_KN_1 = 0,
    output reg [CONCAT_KN2_WIDTH -1 : 0] CONCAT_KN_2 = 0,
    output reg [CONCAT_KN3_WIDTH -1 : 0] CONCAT_KN_3 = 0,
    output reg [CONCAT_KN4_WIDTH -1 : 0] CONCAT_KN_4 = 0,
    output reg valid,
    output reg ready = 0
    );

            
    reg [(OUTPUT_WIDTH)-1 : 0] data_instruction = 0;
    reg [2:0] state = 0;
    reg [17:0] count = 0;
    parameter IDLE = 3'b000;
    parameter REGISTER = 3'b001;
    parameter CONCAT = 3'b011;


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
            opcode            <= data_instruction[`CONCAT_Opcode];
            CONCAT_StartAdd_1 <= data_instruction[`CONCAT_Image1StartAddress];
            CONCAT_StartAdd_2 <= data_instruction[`CONCAT_Image2StartAddress];
            CONCAT_StartAdd_3 <= data_instruction[`CONCAT_Image3StartAddress];
            CONCAT_StartAdd_4 <= data_instruction[`CONCAT_Image4StartAddress];
            CONCAT_IH_1       <= data_instruction[`CONCAT_IH1]; 
            CONCAT_IH_2       <= data_instruction[`CONCAT_IH2];
            CONCAT_IH_3       <= data_instruction[`CONCAT_IH3];
            CONCAT_IH_4       <= data_instruction[`CONCAT_IH4];
            CONCAT_KN_1       <= data_instruction[`CONCAT_KN1];
            CONCAT_KN_2       <= data_instruction[`CONCAT_KN2];
            CONCAT_KN_3       <= data_instruction[`CONCAT_KN3];
            CONCAT_KN_4       <= data_instruction[`CONCAT_KN4];
            CONCAT_InNum      <= data_instruction[`CONCAT_InNum];
            valid             <= 1'b1;
            state             <= IDLE;
        end
        endcase
    end

endmodule