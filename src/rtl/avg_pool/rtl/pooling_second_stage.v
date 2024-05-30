module pooling_second_stage #(parameter DATA_WIDTH = 8, 
                              parameter POOLING_TYPE_WIDTH = 3)
    (
    input clk,
    input rst_n,
    input [(DATA_WIDTH - 1) : 0] din_fifo_1,
    input [(DATA_WIDTH - 1) : 0] din_fifo_2,
    input datavalid_in,
    input ENABLE,
    input [(POOLING_TYPE_WIDTH - 1) : 0] pooling_type,
    output datavalid_out,
    output [(DATA_WIDTH - 1) : 0] dout
); 

//parameter AVG_POOL = 3'b000;
//parameter MAX_POOL = 3'b001;

reg [(DATA_WIDTH - 1) : 0] r_dout = 0;
reg r_datavalid = 0;

always @(posedge clk) begin
    if(~rst_n) begin
        r_datavalid <= 0;
        r_dout <= 0;
    end
    else begin 
        //if(datavalid_in) begin
        case(pooling_type)
        3'b000: begin
            if(datavalid_in) begin
                r_dout <= ((din_fifo_1 + din_fifo_2) >> 1);
                r_datavalid <= 1;
            end
            else begin
                r_dout <= 0;
                r_datavalid <= 0;
            end
        end
        3'b001: begin
            if(datavalid_in) begin
                r_dout <= (din_fifo_1 > din_fifo_2) ? din_fifo_1 : din_fifo_2;
                r_datavalid <= 1;
            end
            else begin
                r_dout <= 0;
                r_datavalid <= 0;
            end
        end
        endcase
        //end
    end
end

assign dout = (ENABLE)? r_dout : 0;
assign datavalid_out = (ENABLE)? r_datavalid : 0;

endmodule