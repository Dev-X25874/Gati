module controller_request_receiver #(parameter burst_length_out = 10, parameter occupancy_count = 40, parameter AXI_DATA_BYTES = 32) (
    input [$clog2(AXI_DATA_BYTES) : 0] burst_length,
    input clk,
    output reg valid = 0
);

reg r_burst_length = 0;
reg [1:0] state = 0;

always @(posedge clk) begin
    case(state)
    0: begin
        valid <= 0;
        r_burst_length <= burst_length[0];
        state <= 1;
    end
    1: begin
        if(r_burst_length) begin
            valid <= 1;
            state <= 0;
        end
        else begin
            valid <= 0;
            state <= 1;
        end
    end
    endcase
end

endmodule