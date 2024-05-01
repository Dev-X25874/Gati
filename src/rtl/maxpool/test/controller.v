module controller(
    input clk,
    input [7:0] d_in,
    input rx_valid,
    output reg rst = 0,
    output reg [7:0] dynamic_threshold = 0,
    output reg [7:0] d_out = 0,
    output reg datavalid = 0
);
reg [1:0] state = 0;
reg [13:0] count1 = 0;
reg [7:0] dgb_cnt = 0;

parameter IDLE = 2'b00;
parameter DATA = 2'b01;
parameter DYT = 2'b10;
parameter WAIT = 2'b11;

always @(posedge clk) begin
    case(state)
    IDLE: begin
        datavalid <= 1'b0;
        d_out <= 8'd0;
        rst <= 1'b0;
        dynamic_threshold <= dynamic_threshold; //// 
       if(rx_valid) begin
            state <= DYT;
        end
        else begin
            state <= IDLE;
        end
        /*if(dgb_cnt == 8'd1) begin
            state <= DYT;
        end
        else if(dgb_cnt > 8'd1) begin
            state <= DATA;
        end
        else begin
            state <= IDLE;
        end*/
    end
    DYT: begin
        //if(rx_valid) begin
            dynamic_threshold <= d_in;
            datavalid <= 1'b0;  ///////
            state <= DATA;   
        //end
    end
    DATA: begin
        if(count1 <= 28) begin
            if(rx_valid) begin
                d_out <= d_in;
                datavalid <= 1'b1;
                count1 <= count1 + 1;
                state <= DATA;
            end
            else begin
                d_out <= d_out;
                state <= DATA; 
                datavalid <= 1'b0;
                count1 <= count1; 
            end
        end
        else begin
            d_out <= d_in;
            count1 <= 0;
            datavalid <= 1'b0;
            state <= WAIT;
        end
    end
    WAIT: begin
        datavalid <= 1'b0;
        state <= IDLE;
    end
    endcase
end

endmodule
