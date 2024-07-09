//this module is the master's controller
//this takes in 256 bits of data as input and divides them into chunks of 8 bits and transfers to the selected slave, as it receives ready from the respective slave
//it starts working when start signal is received from the instruction controller

module controller #(parameter OP_CODE_WIDTH = 4, 
            parameter CNT = (INPUT_WIDTH/OUTPUT_WIDTH),
            parameter INPUT_WIDTH = 256,
            parameter OUTPUT_WIDTH = 8) (
    input [(INPUT_WIDTH)-1 : 0] din,
    input start,
    input clk,
    input [(OP_CODE_WIDTH)-1 : 0] op_code,
    input ready, //[(1<<op_code_width)-1 : 0] ready,
    output reg [(OUTPUT_WIDTH)-1 : 0] dout = 0,
    output reg [(1<<OP_CODE_WIDTH)-1 : 0] sel = 0,
    output reg write = 0,
    output reg done = 0
);
reg [1:0] state = 0;
parameter IDLE = 2'b00;
parameter SPLIT = 2'b01;
reg [17:0] count = 0;

always @(posedge clk) begin
    case(state) 
    IDLE: begin
        dout <= 0;
        sel <= 0;
        write <= 0;
        done <= 0;
        count <= 0;
        if(start)  state <= SPLIT;
        else state <= IDLE;        
    end
    SPLIT: begin
        // if(start) begin
            sel[op_code] <= 1'b1;
            if(ready) begin
                if(count < (CNT-1)) begin
                    dout <= din[INPUT_WIDTH-(count*8)-1 -:8]; //258 bits divided into chucks of 8 bits, as a part of protocol
                    count <= count + 1;
                    write <= 1;
                    //sel[op_code] <= 1'b1;
                    done <= 0;
                    state <= SPLIT;
                end
                else begin
                    dout <= din[INPUT_WIDTH-(count*8)-1 -:8];
                    count <= 0;
                    write <= 1;
                    //sel[op_code] <= 1'b1;
                    done <= 1;
                    state <= IDLE;
                end
            end
        end
    // end
    endcase
end

endmodule