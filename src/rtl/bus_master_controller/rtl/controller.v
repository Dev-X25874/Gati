module controller #(parameter op_code_width = 4, 
            parameter CNT = (data_in/data_out),
            parameter data_in = 256,
            parameter data_out = 8) (
    input [(data_in)-1 : 0] din,
    input start,
    input clk,
    input [(op_code_width)-1 : 0] op_code,
    input ready, //[(1<<op_code_width)-1 : 0] ready,
    output reg [(data_out)-1 : 0] dout = 0,
    output reg [(1<<op_code_width)-1 : 0] sel = 0,
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
        state <= SPLIT;
        count <= 0;
    end
    SPLIT: begin
        if(start) begin
            sel[op_code] <= 1'b1;
            if(ready) begin
                if(count < (CNT-1)) begin
                    dout <= din[data_in-(count*8)-1 -:8];
                    count <= count + 1;
                    write <= 1;
                    //sel[op_code] <= 1'b1;
                    done <= 0;
                    state <= SPLIT;
                end
                else begin
                    dout <= din[data_in-(count*8)-1 -:8];
                    count <= 0;
                    write <= 1;
                    //sel[op_code] <= 1'b1;
                    done <= 1;
                    state <= IDLE;
                end
            end
        end
    end
    endcase
end

endmodule