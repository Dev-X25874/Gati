module OP_Tailblock#(parameter op_code_width = 4, 
            parameter CNT = (data_out/data_in),
            parameter data_in = 8,
            parameter data_out = 256)(
                input [(data_in)-1 : 0] din,
                input sel,
                input write,
                input done,
                input clk,
                output reg ready = 0,
                output reg valid = 0,
                output reg [3:0] opcode = 0,
                output reg [9:0] BNchannels = 0,
                output reg [31:0] BNaddress = 0,
                output reg [31:0] BIASaddr = 0,
                output reg [3:0] acttype = 0,
                output reg [15:0] quantscale = 0,
                output reg [4:0] quantshift = 0,
                output reg [2:0] pooltype = 0,
                output reg [3:0] poolwidth = 0,
                output reg [3:0] poolheight = 0,
                output reg [3:0] poolstride = 0,
                output reg [3:0] poolpadding = 0,
                output reg [121:0] dout = 0
        );

reg [(data_out)-1 : 0] data_instruction = 0;
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
        BNchannels <= 0;
        BNaddress <= 0;
        BIASaddr <= 0;
        acttype <= 0;
        quantscale <= 0;
        quantshift <= 0;
        pooltype <= 0;
        poolwidth <= 0;
        poolheight <= 0;
        poolstride <= 0;
        poolpadding <= 0;
        state <= REGISTER;
    end
    REGISTER: begin
        if(sel) begin
            ready <= 1'b1;
            if(write) begin
                if(count < (CNT-1)) begin
                    data_instruction[data_out-(count*8)-1 -:8] <= din;
                    count <= count + 1;
                    state <= REGISTER;
                end
                else begin
                    data_instruction[data_out-(count*8)-1 -:8] <= din;
                    count <= 0;
                    state <= CONCAT;
                end
            end
        end
    end
    CONCAT: begin
        if(done) begin
            opcode <= data_instruction[3:0];
            BNchannels <= data_instruction[13:4];
            BNaddress <= data_instruction[45:14];
            BIASaddr <= data_instruction[77:46];
            acttype <= data_instruction[81:78];
            quantscale <= data_instruction[97:82];
            quantshift <= data_instruction[102:98];
            pooltype <= data_instruction[105:103];
            poolwidth <= data_instruction[109:106];
            poolheight <= data_instruction[113:110];
            poolstride <= data_instruction[117:114];
            poolpadding <= data_instruction[121:118];
            valid <= 1'b1;
            state <= OUTPUT_CHECK;
        end
    end
    OUTPUT_CHECK: begin
        dout <= {poolpadding,poolstride,poolheight,poolwidth,pooltype,quantshift,quantscale,acttype,BIASaddr,BNaddress,BNchannels,opcode};
        state <= IDLE;
        valid <= 1'b1;
    end
    endcase
end

endmodule