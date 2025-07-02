`include "../common/instructions.vh"

module mega_block_start_ctrl #(
    parameter NUM_INSTRUCTIONS = 4
) (
    input [NUM_INSTRUCTIONS-1:0] start_command,
    input i_clk,
    input i_rst,
    input start_out,
    input [NUM_INSTRUCTIONS-1:0] ack_opcode,
    output reg [NUM_INSTRUCTIONS-1:0] valid_opcode,
    output reg [NUM_INSTRUCTIONS-1:0] start_block
);


    integer i;
    
    always @(posedge i_clk)begin 
        if (!i_rst)begin
            valid_opcode <= 0;
        end else begin
            for (i = 0; i < NUM_INSTRUCTIONS; i = i + 1) begin
                if (ack_opcode[i]) valid_opcode[i] <= 0;
                else if (start_command[i]) valid_opcode[i] <= 1; 
                else valid_opcode[i] <= valid_opcode[i];
            end
        end
    end 

    /* delayed version of start_command to snch the start signal*/ 
    
    always @(posedge i_clk)begin
        if (!i_rst) begin
            start_block <= 0;
        end
        else begin
            start_block <= start_command;
        end
    end 

endmodule