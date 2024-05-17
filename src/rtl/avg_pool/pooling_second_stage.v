module pooling_second_stage (
    input clk,
    input rst_n,
    input [7:0] din_fifo_1,
    input [7:0] din_fifo_2,
    input datavalid_in,
    input ENABLE,
    input [2:0] pooling_type,
    output reg datavalid_out = 0,
    output reg [7:0] dout = 0
); 

reg [1:0] state = 0;
parameter AVG_POOL = 3'b000;
parameter MAX_POOL = 3'b001;

always @(posedge clk) begin
    if(rst_n) begin
        datavalid_out <= 0;
        dout <= 0;
    end
    else begin
        if(ENABLE) begin   
            if(datavalid_in) begin
                case(pooling_type)
                AVG_POOL: begin
                    dout <= (din_fifo_1 + din_fifo_2) >> 1;
                end
                MAX_POOL: begin
                    dout <= (din_fifo_1 > din_fifo_2) ? din_fifo_1 : din_fifo_2;
                end
                endcase
            end
        end
        else begin
            datavalid_out <= 0;
            dout <= 0;
        end
    end
end

endmodule