module counter_demux #(parameter POOL_HEIGHT = 4) (
    input clk,
    input rst_n,
    input datavalid_in,
    input [(POOL_HEIGHT - 1) : 0] pool_height,
    input rx_valid, 
    output reg datavalid_out = 0,
    output reg sel = 0
);

reg [(POOL_HEIGHT - 1) : 0] counter_demux = 0;

always @(posedge rx_valid) begin
    if(~rst_n) begin
        sel <= 0;
    end  
    else begin
        if(datavalid_in) begin
            if(counter_demux == 0) begin
                sel <= 0;
                datavalid_out <= 1;
                counter_demux <= 1;
            end
            else if(counter_demux == (pool_height - 1)) begin
                sel <= 1;
                counter_demux <= 0;
                datavalid_out <= 1;
            end
            else begin
                sel <= 1;
                counter_demux <= counter_demux + 1;
                datavalid_out <= 1;
            end
        end
    end
end
endmodule