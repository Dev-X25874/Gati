module controller(
    input clk,
    input rx_valid,
    input [7:0] din,
    output reg [7:0] dout = 0,
    output datavalid,
    output reg [2:0] pooling_type = 0,
    output reg [3:0] pool_width = 0,
    output reg [3:0] pool_height = 0,
    output reg [9:0] OH = 0,
    output reg [9:0] OW = 0

);

reg [1:0] state = 0;
reg datavalid;

//assign datavalid = rx_valid;
always @(posedge clk) begin
    
    if(rx_valid) begin
        dout <= din;
        datavalid <= 1'b1;
        pooling_type <= 3'd0;
        pool_width <= 4'd3;
        pool_height <= 4'd3;
        OH <= 10'd28;
        OW <= 10'd28;
    end
    else begin
        dout <= dout;
        pooling_type <= pooling_type;
        pool_width <= pool_width;
        pool_height <= pool_height;
        OH <= OH;
        OW <= OW;
        datavalid <= 1'b0;
    end
    /*
    case(state) 
    0: begin
        dout <= dout;
        datavalid <= 0;
        pooling_type <= 0;
        pool_width <= 0;
        pool_height <= 0;
        OH <= 0;
        OW <= 0;
        state <= 1;
    end
    1: begin
        if(rx_valid) begin
            dout <= din;
            datavalid <= 1;
            state <= 2;
        end
        else begin
            dout <= dout;
            state <= 1;
            datavalid <= 0;
        end
    end
    2: begin
        //if(rx_valid) begin
            pooling_type <= 3'b0;
            pool_width <= 4'd3;
            pool_height <= 4'd3;
            OH <= 10'd28;
            OW <= 10'd28;
            state <= 0;
        //end
    end
    endcase*/
end

endmodule