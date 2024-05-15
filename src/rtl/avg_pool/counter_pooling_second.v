module counter_pooling_second(
    input clk,
    input rst_n,
    input datavalid_in,
    input dout_pooling_second_stage,
    input [3:0] pool_height,
    output reg datavalid_out_final = 0,
    output reg datavalid_out_fifo1 = 0,
    output reg dout_final = 0,
    output reg dout_fifo1 = 0
);

always @(posedge clk) begin
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

endmodule