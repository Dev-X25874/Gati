module top_fifo_dram_mimic_con #(parameter burst_length_out = 10, parameter occupancy_count = 40, parameter AXI_DATA_BYTES = 32) (
    input [$clog2(AXI_DATA_BYTES) : 0] burst_length,
    input clk,
    output fifo_status
);

wire valid;

controller_request_receiver controller_request_receiver(
    .burst_length(burst_length),
    .clk(clk),
    .valid(valid) 
);

controller_fifo_status controller_fifo_status(
    .valid(valid),
    .clk(clk),
    .fifo_status(fifo_status)
);

endmodule