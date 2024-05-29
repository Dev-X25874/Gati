module controller_fifo_tx(
    input empty,
    input done,
    input clk,
    input [8:0] occupants,
    output reg dv_tx = 0,
    output reg re = 0
);

reg [1:0] state = 0;

always @ (posedge clk) begin
    case(state)
    0: begin
        dv_tx <= 1'b0;
        if(~empty) begin
            //if(occupants == 9'd16) begin
                state <= 1;
                re <= 1'b1;
            //end
            // else begin
            //     state <= 0;
            //     re <= 1'b0;
            // end
        end
        else begin
            state <= 0;
            re <= 1'b0;
        end
    end
    1: begin
        dv_tx <= 1'b1;
        re <= 1'b0;
        state <= 2;
    end
    2: begin
        if(done) begin
            dv_tx <= 1'b1;
            state <= 1;
        end
        else begin
            dv_tx <= 1'b0;
            state <= 2;
        end
    end
    endcase
end

endmodule