//this module is to concatenate the 8 bits of data into 24 bits to thereby store them into fifos, mimicing engines

module controller(
    input clk,
    input [7:0] d_in,
    input valid,
    output reg [23:0] dout_sa1 = 0,
    output reg [23:0] dout_sa2 = 0,
    output reg [23:0] dout_sa3 = 0,
    output reg [23:0] dout_sa4 = 0,
    output reg [23:0] dout_sa5 = 0,
    output reg [23:0] dout_sa6 = 0,
    output reg [23:0] dout_sa7 = 0,
    output reg [23:0] dout_sa8 = 0,
    output reg valid_out_sa1 = 0,
    output reg valid_out_sa2  = 0,
    output reg valid_out_sa3  = 0,
    output reg valid_out_sa4  = 0,
    output reg valid_out_sa5  = 0,
    output reg valid_out_sa6  = 0,
    output reg valid_out_sa7  = 0,
    output reg valid_out_sa8  = 0
);

reg [3:0] state = 0;
reg [14:0] count = 0;
parameter IDLE = 4'd0;
parameter DATA_SA1 = 4'd1;
parameter DATA_SA2 = 4'd2;
parameter DATA_SA3 = 4'd3;
parameter DATA_SA4 = 4'd4;
parameter DATA_SA5 = 4'd5;
parameter DATA_SA6 = 4'd6;
parameter DATA_SA7 = 4'd7;
parameter DATA_SA8 = 4'd8;

always @(posedge clk) begin
    case(state) 
    IDLE: begin
        dout_sa1 <= 0;
        dout_sa2 <= 0; 
        dout_sa3 <= 0;
        dout_sa4 <= 0;
        dout_sa5 <= 0;
        dout_sa6 <= 0;
        dout_sa7 <= 0;
        dout_sa8 <= 0;
        valid_out_sa1 <= 0;
        valid_out_sa2 <= 0;
        valid_out_sa3 <= 0;
        valid_out_sa4 <= 0;
        valid_out_sa5 <= 0;
        valid_out_sa6 <= 0;
        valid_out_sa7 <= 0;
        valid_out_sa8 <= 0;
        state <= DATA_SA1;
    end
    DATA_SA1: begin
        if(valid) begin
            if(count < 2) begin
                dout_sa1[24-(count*8)-1 -:8] <= d_in;
                count <= count + 1;
                state <= DATA_SA1;
            end
            else begin
                dout_sa1[24-(count*8)-1 -:8] <= d_in;
                count <= 0;
                valid_out_sa1 <= 1'b1;
                state <= DATA_SA2;
            end
        end
    end
    DATA_SA2: begin
        if(valid) begin
            if(count < 2) begin
                dout_sa2[24-(count*8)-1 -:8] <= d_in;
                count <= count + 1;
                valid_out_sa2 <= 1'b0;
                state <= DATA_SA2;   
            end
            else begin
                dout_sa2[24-(count*8)-1 -:8] <= d_in;
                count <= 0;
                valid_out_sa2 <= 1'b1;
                state <= DATA_SA3;  
            end
        end
    end
    DATA_SA3: begin
        if(valid) begin
            if(count < 2) begin
                dout_sa3[24-(count*8)-1 -:8] <= d_in;
                count <= count + 1;
                valid_out_sa3 <= 1'b0;
                state <= DATA_SA3;   
            end
            else begin
                dout_sa3[24-(count*8)-1 -:8] <= d_in;
                count <= 0;
                valid_out_sa3 <= 1'b1;
                state <= DATA_SA4;  
            end
        end   
    end
    DATA_SA4: begin
        if(valid) begin
            if(count < 2) begin
                dout_sa4[24-(count*8)-1 -:8] <= d_in;
                count <= count + 1;
                valid_out_sa4 <= 1'b0;
                state <= DATA_SA4;   
            end
            else begin
                dout_sa4[24-(count*8)-1 -:8] <= d_in;
                count <= 0;
                valid_out_sa4 <= 1'b1;
                state <= DATA_SA5;  
            end
        end 
    end
    DATA_SA5: begin
        if(valid) begin
            if(count < 2) begin
                dout_sa5[24-(count*8)-1 -:8] <= d_in;
                count <= count + 1;
                valid_out_sa5 <= 1'b0;
                state <= DATA_SA5;   
            end
            else begin
                dout_sa5[24-(count*8)-1 -:8] <= d_in;
                count <= 0;
                valid_out_sa5 <= 1'b1;
                state <= DATA_SA6;  
            end
        end 
    end
    DATA_SA6: begin
        if(valid) begin
            if(count < 2) begin
                dout_sa6[24-(count*8)-1 -:8] <= d_in;
                count <= count + 1;
                valid_out_sa6 <= 1'b0;
                state <= DATA_SA6;   
            end
            else begin
                dout_sa6[24-(count*8)-1 -:8] <= d_in;
                count <= 0;
                valid_out_sa6 <= 1'b1;
                state <= DATA_SA7;  
            end
        end 
    end
    DATA_SA7: begin
        if(valid) begin
            if(count < 2) begin
                dout_sa7[24-(count*8)-1 -:8] <= d_in;
                count <= count + 1;
                valid_out_sa7 <= 1'b0;
                state <= DATA_SA7;   
            end
            else begin
                dout_sa7[24-(count*8)-1 -:8] <= d_in;
                count <= 0;
                valid_out_sa7 <= 1'b1;
                state <= DATA_SA8;  
            end
        end 
    end
    DATA_SA8: begin
        if(valid) begin
            if(count < 2) begin
                dout_sa8[24-(count*8)-1 -:8] <= d_in;
                count <= count + 1;
                valid_out_sa8 <= 1'b0;
                state <= DATA_SA8;   
            end
            else begin
                dout_sa8[24-(count*8)-1 -:8] <= d_in;
                count <= 0;
                valid_out_sa8 <= 1'b1;
                state <= IDLE;  
            end
        end 
    end
    endcase
end

endmodule