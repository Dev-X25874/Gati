module top_fifo_dram_mimic_con(
    input [7:0] addr_out,
    input clk,
    output fifo_status
);

wire valid;

controller_request_receiver controller_request_receiver(
    .addr_out(addr_out),
    .clk(clk),
    .valid(valid) 
);

controller_fifo_status controller_fifo_status(
    .valid(valid),
    .clk(clk),
    .fifo_status(fifo_status)
);

endmodule