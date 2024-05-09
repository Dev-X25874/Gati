module counter_kernel_size(
    input clk,
    input rst_n,
    input [3:0] kernel_size,
    output dout_1,
    output dout_2
);

reg toggle = 0;

always @(posedge clk) begin
    if(rst) begin
        dout_1 <= 0;
        dout_2 <= 0;
    end
    else begin
        case(state)
        0: begin
            if(count < kernel_size) begin
                toggle <= ~toggle;
                count <= count + 1;
                state <= 1;
            end
            else begin
                count <= 0;
                toggle <= 0; 
                state <= 0;
            end
        end
        1: begin
            if(~toggle) begin
                dout_1 <= din;
                state <= 2;
            end
        end
        endcase
    end
end

endmodule