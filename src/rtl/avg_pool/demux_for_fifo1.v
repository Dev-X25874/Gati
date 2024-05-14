module demux_for_fifo1(
    input clk,
    input rst_n,
    input [7:0] data_in,
    input datavalid_in, 
    output reg [7:0] data_out_fifo1 = 0,
    output reg [7:0] data_out_fifo2 = 0,
    output reg datavalid_out = 0
);

reg [1:0] state = 0;
reg [3:0] counter = 0;
reg sel = 0; 

always @(posedge clk) begin
    if(rst_n) begin
        data_out_fifo1 <= 0;
        data_out_fifo2 <= 0;
    end
    else begin
        case(state)
        0: begin
            data_out_fifo1 <= 0;
            data_out_fifo2 <= 0;
            counter <= 0;
            sel <= 0;
            if(datavalid_in) begin
                state <= 1;
            end
            else begin
                state <= 0;
            end
        end
        1: begin
            if(counter == 0) begin
                sel <= 0;
                state <= 1;
            end 
            else begin
                sel <= 1;
                counter <= counter + 1;
                state <= 2;
            end
        end
        2: begin
            if(sel) begin
                data_out_fifo2 <= data_in;
                datavalid_out <= 1;
                state <= 0;
            end
            else begin
                data_out_fifo2 <= data_in;
                datavalid_out <= 1;
                state <= 0;
            end
        end
        endcase
    end
end
endmodule