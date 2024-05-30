module counter_pooling_second#(parameter DATA_WIDTH = 8, 
                               parameter POOL_HEIGHT = 4)
    (
    input clk,
    input rst_n,
    input ENABLE,
    input datavalid_in,
    input [(DATA_WIDTH - 1) : 0] dout_pooling_second_stage,
    input [(POOL_HEIGHT - 1) : 0] pool_height,
    output reg datavalid_out_final = 0,
    output reg datavalid_out_fifo1 = 0,
    output reg [(DATA_WIDTH - 1) : 0] dout_final = 0,
    output reg [(DATA_WIDTH - 1) : 0] dout_fifo1 = 0
);

reg [(POOL_HEIGHT - 1) : 0] counter = 0;

always @(posedge clk) begin
    if(~rst_n) begin
        dout_final <= 0;
        dout_fifo1 <= 0;
        datavalid_out_final <= 0;
        datavalid_out_fifo1 <= 0;
    end
    else begin
        if(ENABLE) begin
            if(datavalid_in) begin
                if(counter == (pool_height-1)) begin
                    dout_final <= dout_pooling_second_stage;
                    datavalid_out_final <= 1;
                    counter <= 0;
                end
                else begin
                    dout_fifo1 <= dout_pooling_second_stage;
                    datavalid_out_fifo1 <= 1;
                    counter <= counter + 1;
                end
            end
        end
        else begin
            dout_final <= 0;
            dout_fifo1 <= 0;
            datavalid_out_final <= 0;
            datavalid_out_fifo1 <= 0;
        end
    end
end
endmodule