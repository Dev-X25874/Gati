module controller_request_receiver(
    input [7:0] addr_out,
    input clk,
    output valid
);

reg r_addr_out = 0
assign r_addr_out = addr_out[0];

always @(posedge clk) begin
    if(r_addr_out) begin
        valid <= 1;
    end
    else begin
        valid <= 0;
    end
end

endmodule