module counter_demux #(parameter POOL_HEIGHT = 4) (
    input clk,
    input rst_n,
    input datavalid_in,                         // Input data valid signal
    input [(POOL_HEIGHT - 1) : 0] pool_height,  // Height of the pooling window (controls the demux behavior)
    output reg datavalid_out = 0,               // Output data valid signal
    output reg sel = 0                         // Output selection signal for demux
);
reg sel1;
reg [(POOL_HEIGHT - 1) : 0] counter_demux = 0;

always @(posedge clk) begin
    sel <= sel1; //to delay a cycle
    if(~rst_n) begin
        sel1 <= 0;
        sel <= 0;
        counter_demux <= 0;
        //datavalid_out <= 0;
    end  
    else begin
        if(datavalid_in) begin
            if(counter_demux == 0) begin
                sel1 <= 1;                    // Set selection to 1st fifo when the counter is 0
                counter_demux <= 1;
            end
            else if(counter_demux == (pool_height - 1)) begin
                sel1 <= 0;                   // Set selection to 0th fifo when the counter reaches the end of the pool
                counter_demux <= 0; 
            end
            else begin
                sel1 <= 1;                  // Set selection to 1st fifo while the counter is in progress
                counter_demux <= counter_demux + 1;
            end
        end
        else begin
            sel1 <= sel1;
            counter_demux <= counter_demux;           
        end
    end
end
endmodule