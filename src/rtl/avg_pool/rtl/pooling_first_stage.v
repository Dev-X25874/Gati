module pooling_first_stage(
    input clk,
    input rst_n,
    input ENABLE,
    input [7:0] din,
    input datavalid_in,
    input [3:0] pool_width,
    input [2:0] pooling_type,
    output [7:0] dout,
    output datavalid_out
);

//parameter AVG_POOL = 3'b000;
//parameter MAX_POOL = 3'b001;

reg [7:0] temp = 0;
reg [7:0] r_dout = 0;
reg [4:0] counter = 0;
reg r_datavalid = 0;

always @(posedge clk) begin
    if(~rst_n) begin
        r_dout <= 0;
        r_datavalid <= 0;
    end
    else begin
        //if(datavalid_in) begin
            case(pooling_type)
            3'b000: begin
                if(datavalid_in) begin
                    if(counter == 0) begin
                        temp <= din;
                        r_datavalid <= 0;
                        counter <= 1;
                    end
                    else if(counter == (pool_width - 1)) begin
                        r_dout <= temp;
                        r_datavalid <= 1;
                        counter <= 0;
                    end
                    else begin
                        temp <= (temp + din) >> 1;
                        counter <= counter + 1;
                        r_datavalid <= 0;
                    end
                end
                else begin
                    r_dout <= 0;
                    r_datavalid <= 0;
                end
            end
            3'b001: begin
                if(datavalid_in) begin
                    if(counter == 0) begin
                        temp <= din;
                        r_datavalid <= 0;
                        counter <= 1;
                    end
                    else if(counter == (pool_width - 1)) begin
                        r_dout <= temp;
                        r_datavalid <= 1;
                        counter <= 0;
                    end
                    else begin
                        temp <= (temp > din) ? temp : din;
                        counter <= counter + 1;
                        r_datavalid <= 0;
                    end
                end
                else begin
                    r_dout <= 0;
                    r_datavalid <= 0;
                end
            end
            endcase
        //end
        //else begin
        //    r_dout <= r_dout;
        //    r_datavalid <= 0;
        //end
    end
end

assign dout = (ENABLE)? r_dout : 0;
assign datavalid_out = (ENABLE)? r_datavalid : 0;

endmodule
