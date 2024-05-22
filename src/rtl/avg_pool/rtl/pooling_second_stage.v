module pooling_second_stage (
    input clk,
    input rst_n,
    input [7:0] din_fifo_1,
    input [7:0] din_fifo_2,
    input datavalid_in,
    input ENABLE,
    input [2:0] pooling_type,
    output datavalid_out,
    output [7:0] dout
); 

//parameter AVG_POOL = 3'b000;
//parameter MAX_POOL = 3'b001;

reg [7:0] r_dout = 0;
reg r_datavalid = 0;

always @(posedge clk) begin
    if(~rst_n) begin
        r_datavalid <= 0;
        r_dout <= 0;
    end
    else begin 
        if(datavalid_in) begin
            case(pooling_type)
            3'b000: begin
                r_dout <= (din_fifo_1 + din_fifo_2) >> 1;
                r_datavalid <= 1;
            end
            3'b001: begin
                r_dout <= (din_fifo_1 > din_fifo_2) ? din_fifo_1 : din_fifo_2;
                r_datavalid <= 1;
            end
            endcase
        end
    end
end

assign dout = (ENABLE)? r_dout : 0;
assign datavalid_out = (ENABLE)? r_datavalid : 0;

endmodule