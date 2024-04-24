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
                output reg [7:0] relu_clip = 0;
                output reg [7:0] maxpool_threshold = 0;
                output reg [31:0] stop_addr = 0;
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
                output reg [166:0] dout = 0
        );

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
            relu_clip <= data_instruction[129:122];
            maxpool_threshold <= data_instruction[137:130];
            stop_addr <= data_instruction[169:138];
            //valid <= 1'b1;
            state <= OUTPUT_CHECK;
        end
    end
    OUTPUT_CHECK: begin
        dout <= {stop_addr,maxpool_threshold,relu_clip,poolpadding,poolstride,poolheight,poolwidth,pooltype,quantshift,quantscale,acttype,BIASaddr,BNaddress,BNchannels,opcode};  //this concates the different output signals for checking purpose
        state <= IDLE;
        //valid <= 1'b1;
    end
    endcase
end

endmodule