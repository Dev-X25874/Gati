module controller_fifo_tx(
    input empty,
    input done,
    input clk,
    output reg dv_tx = 0,
    output reg re = 0
);

reg [1:0] state = 0;

always @ (posedge clk) begin
    case(state)
    0: begin
        dv_tx <= 0;
        if(~empty) begin
            re <= 1;
            state <= 1;
        end
        else begin
            re <= 0;
            state <= 0;
        end
    end
    1: begin
        dv_tx <= 0;
        re <= 0;
        state <= 2;
    end
    2: begin
        if(done) begin
            dv_tx <= 1;
            state <= 0;
        end
        else begin
            dv_tx <= 0;
            state <= 2;
        end
    end
    endcase
end

endmodule