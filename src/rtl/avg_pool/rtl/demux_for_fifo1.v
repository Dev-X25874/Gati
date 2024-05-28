module demux_for_fifo1 #(parameter DATA_WIDTH = 8) (
    input clk,
    input rst_n,
    input ENABLE,
    input datavalid_in, 
    input [(DATA_WIDTH - 1) : 0] data_in,
    input sel,
    input rx_valid,
    output reg [(DATA_WIDTH - 1) : 0] data_out_fifo1 = 0,
    output reg [(DATA_WIDTH - 1) : 0] data_out_fifo2 = 0,
    output reg datavalid_out_fifo1 = 0,
    output reg datavalid_out_fifo2 = 0
);


always @(posedge clk) begin
    if(~rst_n) begin
        data_out_fifo1 <= 0;
        data_out_fifo2 <= 0;
        datavalid_out_fifo1 <= 0;
        datavalid_out_fifo2 <= 0;
    end
    else begin
        if(ENABLE) begin
            if(datavalid_in) begin
                if(sel) begin
                    data_out_fifo2 <= data_in;
                    data_out_fifo1 <= 0;
                    datavalid_out_fifo2 <= 1;
                    datavalid_out_fifo1 <= 0;
                end
                else begin
                    data_out_fifo1 <= data_in;
                    datavalid_out_fifo1 <= 1;
                    datavalid_out_fifo2 <= 0;
                    data_out_fifo2 <= 0;
                end
            end
            else begin
                data_out_fifo1 <= 0;
                data_out_fifo2 <= 0;
                datavalid_out_fifo1 <= 0;
                datavalid_out_fifo2 <= 0;
            end
        end
        else begin
            data_out_fifo1 <= 0;
            data_out_fifo2 <= 0;
            datavalid_out_fifo1 <= 0;
            datavalid_out_fifo2 <= 0;
        end
    end
end
endmodule