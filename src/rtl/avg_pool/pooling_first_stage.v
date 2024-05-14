module pooling_first_stage #(parameter KERNEL_SIZE = 4) (
    input clk,
    input rst_n,
    input [7:0] din,
    input datavalid_in,
    input [2:0] pooling_type
    input [KERNEL_SIZE -1 : 0] kernel_size,
    input [2:0] pooling_type,
    output [7:0] dout,
    output datavalid_out
);

parameter AVG_POOL = 3'b000;
parameter MAX_POOL = 3'b001;

reg [7:0] temp = 0;
reg [1:0] state = 0;
reg [3:0] counter = 0;

always @(posedge clk) begin
    if(datavalid) begin
        case(pooling_type)
        AVG_POOL: begin
            if(counter == 0) begin
                temp <= din;
                state <= AVG_POOL;
            end
            else if(counter == (kernel_size - 1)) begin
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
            else if(counter == (kernel_size - 1)) begin
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



endmodule
