module OP_FC #(parameter OP_CODE_WIDTH = 4, 
            parameter CNT = (OUTPUT_WIDTH/INPUT_WIDTH),
            parameter INPUT_WIDTH = 8,
            parameter OUTPUT_WIDTH = 256)(
                input [(INPUT_WIDTH)-1 : 0] din,
                input sel,
                input write,
                input done,
                input clk,
                output reg valid = 0,
                output reg ready = 0,
                output reg [3:0] opcode = 0,
                output reg [15:0] weightrows = 0,
                output reg [15:0] weightcols = 0,
                output reg [15:0] inputrows = 0,
                output reg [7:0] dropoutconstant = 0,
                output reg [31:0] address = 0,
                output reg flatten = 0,
                output reg [19:0] imagedim = 0,
                output reg [31:0] imageendaddr = 0,
                output reg [31:0] FCbias = 0,
                output reg [31:0] stop_addr = 0;
                output reg [207:0] dout = 0
            );

reg [(OUTPUT_WIDTH)-1 : 0] data_instruction = 0;
reg [2:0] state = 0;
reg [17:0] count = 0;
parameter IDLE = 3'b000;
parameter REGISTER = 3'b001;
parameter CONCAT = 3'b011; 
parameter OUTPUT_CHECK = 3'b101;           

always @(posedge clk) begin
    case(state)
    IDLE: begin
        data_instruction <= 0;
        valid <= 0;
        ready <= 0;
        opcode <= 0;
        weightrows <= 0;
        weightcols <= 0;
        inputrows <= 0;
        dropoutconstant <= 0;
        address <= 0;
        flatten <= 0;
        imagedim <= 0;
        imageendaddr <= 0;
        FCbias <= 0;
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
            opcode <= data_instruction[3:0];
            weightrows <= data_instruction[19:4];
            weightcols <= data_instruction[35:20];
            inputrows <= data_instruction[51:36];
            dropoutconstant <= data_instruction[59:52];
            address <= data_instruction[91:60];
            flatten <= data_instruction[92:92];
            imagedim <= data_instruction[112:93];
            imageendaddr <= data_instruction[144:113];
            FCbias <= data_instruction[176:145];
            stop_addr <= data_instruction[208:177];
            valid <= 1'b1;
            state <= OUTPUT_CHECK;
        end
    end
    OUTPUT_CHECK: begin
        dout <= {stop_addr,FCbias,imageendaddr,imagedim,flatten,address,dropoutconstant,inputrows,weightcols,weightrows,opcode};
        valid <= 1'b1;
        state <= IDLE;
    end
    endcase
end

endmodule