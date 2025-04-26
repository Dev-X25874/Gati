module mux_final_pool#(parameter DATA_WIDTH = 8) (
    input clk,
    input rst_n,
    input ENABLE,
    input [(DATA_WIDTH - 1) : 0] din_demux_for_fifo1,               // Input data from the demux for FIFO1
    input [(DATA_WIDTH - 1) : 0] din_pooling_second_stage_fifo1,    // Input data from the pooling second stage
    input datavalid_out_final,
    input datavalid_out_fifo1,
    output reg dv = 0,
    output reg [(DATA_WIDTH -1) : 0] dout_fifo1 = 0               //Output data for FIFO1's input
);


always @(posedge clk) begin
    if(~rst_n) begin
        dv <= 0;
        dout_fifo1 <= 0;
    end
    else begin
        if(ENABLE) begin
            if(datavalid_out_final) begin                       //Check if data from final pooling stage is valid
                dout_fifo1 <= din_pooling_second_stage_fifo1;
                dv <= 1;
            end
            else if(datavalid_out_fifo1) begin                  //If no final data, check FIFO1 stage data validity
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