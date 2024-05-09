module pooling (
    input clk,
    input rst_n,
    input [7:0] din_1,
    input [7:0] din_2,
    input [2:0] pooling_type,
    output [7:0] dout
);

always @(posedge clk) begin
    if(rst) begin
        done <= 0;
    end
    else begin
        case(pooling_type)
           3'b000: begin  //avg-pool
                dout <= (din_1 + din_2) >> 1;
           end
           3'b001: begin  //max-pool
                dout <= (din_1 > din_2) ? din_1 : din_2;
           end
        endcase
    end
end
    
endmodule
