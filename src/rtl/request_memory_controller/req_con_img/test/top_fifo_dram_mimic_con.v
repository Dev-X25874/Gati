module top_fifo_dram_mimic_con #(parameter BURST_LENGTH = 15, parameter OCCUPANCY = 40, parameter AXI_DATA_BYTES = 32) (
    input valid_in, //[$clog2(AXI_DATA_BYTES) : 0] burst_length,
    input clk,
    output fifo_status
);

wire valid;

controller_request_receiver controller_request_receiver(
    .valid_in(valid_in),
    .clk(clk),
    .valid_out(valid) 
);

controller_fifo_status controller_fifo_status(
    .valid(valid),
    .clk(clk),
    .fifo_status(fifo_status)
);

endmodule