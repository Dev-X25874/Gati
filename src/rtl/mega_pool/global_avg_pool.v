`include "../common/instructions.vh"
module global_avg_pool #(
            parameter DATA_WIDTH = 8, 
            parameter POOLING_TYPE_WIDTH = 3,
            parameter POOL_SCALE_WIDTH = 8,
            parameter POOL_SHIFT_WIDTH = 4,
            parameter OH_WIDTH = 10,
            parameter OW_WIDTH = 10
            )
    (
    input clk,
    input rst_n,
    input ENABLE, 
    input [(DATA_WIDTH - 1) : 0] din, 
    input datavalid_in, 
    input [(POOLING_TYPE_WIDTH - 1) : 0] PoolType, 
    input [(POOL_SCALE_WIDTH - 1) : 0] PoolScale,  
    input [(POOL_SHIFT_WIDTH - 1) : 0] PoolShift,  
    input [(OH_WIDTH + OW_WIDTH - 1) : 0] PoolimageSize, 
    output [(DATA_WIDTH - 1) : 0] dout, 
    output datavalid_out 
    );


reg signed [2*DATA_WIDTH-1 : 0] global_pool_sum;
reg signed [2*DATA_WIDTH-1 : 0] r_global_pool_sum;
reg [2*OH_WIDTH-1 : 0] global_pool_count;
reg global_pool_sum_valid;
reg [2*OH_WIDTH-1 : 0] r_PoolimageSize;

always @(posedge clk) r_PoolimageSize <= PoolimageSize;

always @(posedge clk) begin
    if(!rst_n) begin
        global_pool_sum <= 0;
        r_global_pool_sum <= 0;
        global_pool_count <= 0;
        global_pool_sum_valid <= 0;
    end
    else begin
        if(ENABLE && PoolType == `POOL_GLOBAL_AVG) begin 
            if(global_pool_count == r_PoolimageSize) begin
                global_pool_count <= 0;
                global_pool_sum <= 0;
                r_global_pool_sum <= global_pool_sum;
                global_pool_sum_valid <= 1;
            end
            else begin
                if(datavalid_in) begin
                    global_pool_sum <= global_pool_sum + din;
                    global_pool_count <= global_pool_count + 1;
                    global_pool_sum_valid <= 0;
                end
                else begin
                    global_pool_sum <= global_pool_sum;
                    global_pool_count <= global_pool_count;
                    global_pool_sum_valid <= 0;
                end
            end
        end
        else begin
            global_pool_sum <= 0;
            global_pool_count <= 0;
            global_pool_sum_valid <= 0;
            r_global_pool_sum <= 0;
        end
    end
end

// Multiply the global pool sum value with the pool scale and shift it by pool shift value
reg signed [2*POOL_SCALE_WIDTH-1 : 0] scaled_global_pool_sum;
reg scaled_global_pool_sum_valid;
always @(posedge clk) begin
    if(global_pool_sum_valid) begin
        scaled_global_pool_sum <= r_global_pool_sum * PoolScale;
        scaled_global_pool_sum_valid <= 1;
    end
    else begin
        scaled_global_pool_sum <= 0;
        scaled_global_pool_sum_valid <= 0;
    end
end

reg signed [2*POOL_SCALE_WIDTH-1 : 0] shifted_global_pool_sum;
reg shifted_global_pool_sum_valid;
always @(posedge clk) begin
    if(scaled_global_pool_sum_valid) begin
        shifted_global_pool_sum <= (scaled_global_pool_sum + (1 << (PoolShift - 1))) >>> PoolShift; // Right shift with rounding
        shifted_global_pool_sum_valid <= 1;
    end
    else begin
        shifted_global_pool_sum <= 0;
        shifted_global_pool_sum_valid <= 0;
    end
end

assign datavalid_out = (ENABLE==1)? shifted_global_pool_sum_valid : datavalid_in;
assign dout =(ENABLE==1)? {shifted_global_pool_sum[2*DATA_WIDTH-1], shifted_global_pool_sum[DATA_WIDTH-2 : 0]} : din ;


endmodule