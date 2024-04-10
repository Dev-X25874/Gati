module controller_fifo_status #(parameter threshold = 40) (
    input valid,
    input clk,
    output fifo_status
);

reg [4:0] count_occupancy = 0;
reg [7:0] occupancy = 0;

always @(posedge clk) begin
    if(valid) begin
        if(count_occupancy < threshold) begin
            count_occupancy <= count_occupancy + 1;
            occupancy <= occupancy + 1;
            fifo_status <= 1;
        end
        else begin
            count_occupancy <= 0;
            occupancy <= occupancy;
            fifo_status <= 0;
        end
    end
    else begin
        occupancy <= occupancy;
    end
end

endmodule