module controller_fifo_status #(parameter OCCUPANCY = 20) (
    input start,
    input clk,
    input rx_valid,
    output reg fifo_status = 0
);

reg [4:0] count = 0;
reg [1:0] state = 0;

always @(posedge clk) begin
    if(rx_valid) begin
    case(state)
    0: begin
        fifo_status <= 1;
        state <= 1;
    end
    1: begin
        //fifo_status <= 0;
        if(start) begin
            state <= 2;
        end
        else begin
            state <= 1;
        end
    end
    2: begin
        /*if(count == OCCUPANCY/2) begin
            fifo_status <= 1;
            count <= count + 1;
            state <= 2;
        end
        else if (count == OCCUPANCY) begin
            fifo_status <= 0;
            count <= 0;
            state <= 1;
        end
        else begin
            count <= count + 1;
            state <= 2;
            fifo_status <= fifo_status;
        end*/
        if(count < OCCUPANCY/2) begin
            fifo_status <= 1;
            count <= count + 1;
            state <= 2;
        end
        else if(count == OCCUPANCY) begin
            fifo_status <= 0;
            count <= 0;
            state <= 1; 
        end
        else begin
            count <= count + 1;
            fifo_status <= 0;
            state <= 2; 
        end
    end
    endcase
    end
    else begin
        fifo_status <= fifo_status;
        count <= count;
    end
end

endmodule





/*if(valid) begin
            if(count_occupancy < OCCUPANCY) begin
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
        end*/