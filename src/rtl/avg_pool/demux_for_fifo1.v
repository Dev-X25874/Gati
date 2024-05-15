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
        if(datavalid_in) begin
            if(sel) begin
                data_out_fifo2 <= data_in;
                datavalid_out <= 1;
                state <= 0;
            end
            else begin
                data_out_fifo1 <= data_in;
                datavalid_out <= 1;
                state <= 0;
            end
        end
        else begin
            data_out_fifo1 <= 0;
            data_out_fifo2 <= 0;
            datavalid_out <= 0;
        end
    end
end
endmodule