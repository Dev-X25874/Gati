module mux_final_pool(
    input clk,
    input rst_n,
    input ENABLE,
    input [7:0] din_demux_for_fifo1,
    input [7:0] din_pooling_second_stage_fifo1,
    input datavalid_out_final,
    input datavalid_out_fifo1,
    output reg dv = 0,
    output reg [7:0] dout_fifo1 = 0
);


always @(posedge clk) begin
    if(~rst_n) begin
        dv <= 0;
        dout_fifo1 <= 0;
    end
    else begin
        if(ENABLE) begin
            if(datavalid_out_final) begin
                dout_fifo1 <= din_pooling_second_stage_fifo1;
                dv <= 1;
            end
            else if(datavalid_out_fifo1) begin
                dout_fifo1 <= din_demux_for_fifo1;
                dv <= 1;
            end
            else begin
                dv <= 0;
                dout_fifo1 <= 0;
            end
        end
    end
end

endmodule