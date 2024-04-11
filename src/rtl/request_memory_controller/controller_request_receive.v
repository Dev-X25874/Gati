module controller_request_receiver #(parameter burst_length_out = 10, parameter occupancy_count = 40, parameter AXI_DATA_BYTES = 32) (
    input [$clog2(AXI_DATA_BYTES) : 0] burst_length,
    input clk,
    output valid
);

reg r_burst_length = 0
assign r_burst_length = burst_length[0];

always @(posedge clk) begin
    if(r_burst_length) begin
        valid <= 1;
    end
    else begin
        valid <= 0;
    end
end

endmodule