module counter_demux(
    input clk,
    input rst_n,
    input datavalid_in,
    input pool_height,
    output reg datavalid_out = 0,
    output reg sel = 0
);

reg [3:0] counter_demux = 0;

always @(posedge clk) begin
    if(rst_n) begin
        sel <= 0;
    end  
    else begin
        if(datavalid_in) begin
            if(counter_demux == 0) begin
                sel <= 0;
                datavalid_out <= 1;
            end
            else if(counter_demux < pool_height) begin
                sel <= 1;
                counter_demux <= counter_demux + 1;
                datavalid_out <= 1;
            end
            else begin
                sel <= 0;
                counter_demux <= 0;
                datavalid_out <= 0;
            end
        end
    end
end
endmodule