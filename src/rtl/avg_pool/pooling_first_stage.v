module pooling_first_stage #(parameter KERNEL_SIZE = 4) (
    input clk,
    input rst_n,
    input ENABLE,
    input [7:0] din,
    input datavalid_in,
    input [3:0] pool_width,
    input [2:0] pooling_type,
    output reg [7:0] dout = 0,
    output reg datavalid_out = 0
);

parameter AVG_POOL = 3'b000;
parameter MAX_POOL = 3'b001;

reg [7:0] temp = 0;
reg [1:0] state = 0;
reg [3:0] counter = 0;

always @(posedge clk) begin
    if(rst_n) begin
        dout <= 0;
        datavalid_out <= 0;
    end
    else begin
        if(ENABLE) begin
            if(datavalid) begin
                case(pooling_type)
                AVG_POOL: begin
                    if(counter == 0) begin
                        temp <= din;
                        state <= AVG_POOL;
                    end
                    else if(counter == (pool_width - 1)) begin
                        dout <= temp;
                        datavalid_out <= 1;
                    end
                    else begin
                        temp <= (temp + din) >> 1;
                        counter <= counter + 1;
                        state <= AVG_POOL;
                    end
                end
                MAX_POOL: begin
                    if(counter == 0) begin
                        temp <= din;
                        state <= MAX_POOL;
                    end
                    else if(counter == (pool_width - 1)) begin
                        dout <= temp;
                        datavalid_out <= 1;
                    end
                    else begin
                        temp <= (temp > din) ? temp : din;
                        counter <= counter + 1;
                        state <= MAX_POOL;
                    end
                end
                endcase
            end
        end
        else begin
            dout <= 0;
            datavalid_out <= 0;
        end
    end
end
endmodule
