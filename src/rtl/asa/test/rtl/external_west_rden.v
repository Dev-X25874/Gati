//controls read enable signal of external(before the SA engine) west fifo array
module external_west_rden#(
    parameter N_SA = 2,
    parameter W_ADDR = 8    
)(
    input i_clk,
    input i_rst,
    input [N_SA-1 : 0] i_fifo_empty,
    input [(N_SA * (W_ADDR + 1))-1 : 0] i_fifo_occupants,
    output [N_SA-1 : 0] o_fifo_read_enable
);
reg [1:0] state = 0;
reg [N_SA-1 : 0] rden = 0;
assign o_fifo_read_enable = rden;

always @(posedge i_clk) begin
if(i_rst)begin
    state <= 0;
    rden <= 0;
end else begin
    case (state)
        0:begin
            if(i_fifo_empty == 0)begin
                if(i_fifo_occupants >= {N_SA{9'd180}})begin     //input image matrix is 9x20
                    rden <= {N_SA{1'b1}};
                    state <= 1;
                end
            end
        end 

        1: begin
            if(i_fifo_occupants == 0)begin
                state <= 0;
                rden <= {N_SA{1'b0}};
            end
        end
        default: state <= 0;
    endcase
end
end
endmodule