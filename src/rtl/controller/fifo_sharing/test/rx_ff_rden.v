//controls read enable signal of fifo connected with uart receiver
module rx_ff_rden#(
    parameter N_SA = 2,
    parameter W_ADDR = 8
)(
    input i_clk,
    input i_rstn,
    input [N_SA-1 : 0] i_fifo_empty,
    input [(N_SA * (W_ADDR + 1))-1 : 0] i_fifo_occupants,
    output [N_SA-1 : 0] o_fifo_read_enable
);

reg [N_SA-1 : 0] rden = 0;
reg [1:0] state = 0;
assign o_fifo_read_enable = rden;

always @(posedge i_clk) begin
if(~i_rstn)begin
    rden <= 0;
    state <= 0;
end else begin
    if(i_fifo_empty == 0)begin
        if(i_fifo_occupants >= {N_SA{11'd1024}})begin
            rden <= {N_SA{1'b1}};
        end
    end else begin
        rden <= {N_SA{1'b0}};
    end
end
end
endmodule