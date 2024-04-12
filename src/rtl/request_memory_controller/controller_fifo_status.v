module controller_fifo_status #(parameter threshold = 40) (
    input valid,
    input clk,
    output reg fifo_status = 0
);

reg [4:0] count_occupancy = 0;
reg [7:0] occupancy = 0;
reg [1:0] state = 0;

always @(posedge clk) begin
    case(state)
    0: begin
        fifo_status <= 1;
        state <= 1;
    end
    1: begin
        fifo_status <= 0;
        state <= 2;
    end
    2: begin
        if(valid) begin
            if(count_occupancy < threshold) begin
                count_occupancy <= count_occupancy + 1;
                occupancy <= occupancy + 1;
                fifo_status <= 1;
                state <= 2;
            end
            else begin
                count_occupancy <= 0;
                occupancy <= occupancy;
                fifo_status <= 0;
                state <= 1;
            end
        end
        else begin
            occupancy <= occupancy;
            state <= 2;
        end
    end
    endcase
end

endmodule