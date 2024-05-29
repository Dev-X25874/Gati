module Accumulator_sel_ctrler#(
    parameter NO_PORT = 8
)
(
    input clk,
    input rst,
    input valid,

    output reg [$clog2(NO_PORT)-1:0] sel,
    output reg valid_out
);
    reg [$clog2(NO_PORT):0] count;
    reg cnt_en;
    wire [$clog2(NO_PORT)-1:0] count_max;
    assign count_max = NO_PORT[$clog2(NO_PORT):0];

    always@(posedge clk) begin
        if(!rst) begin
            cnt_en <= 0;
        end
        else begin
            if(valid==1) cnt_en <= 1;
            else if(count==count_max-1) cnt_en <= 0;
        end
    end

    always@(posedge clk) begin
        if(!rst) begin
            count <= 0;
            sel <= 0;
            valid_out <= 0;
        end
        else begin
            if(cnt_en) begin
                count <= count+1;
                sel <= sel + 1;
                valid_out <= 1;
            end
            else begin
                count <= count;
                sel <= sel;
                valid_out <= 0;
            end
        end
    end
endmodule