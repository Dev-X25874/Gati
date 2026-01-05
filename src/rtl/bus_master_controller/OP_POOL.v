//this module is a slave module, that when selected receives data from the master block and gives outputs for further tail block(s) operation processing
`include "../common/arch_param.vh"

`ifdef MEGA_MAX
module OP_POOL#(parameter OP_CODE_WIDTH = 4, 
    parameter CNT = (OUTPUT_WIDTH/INPUT_WIDTH),
    parameter INPUT_WIDTH = 8,
    parameter OUTPUT_WIDTH = 256,
    parameter ADDRESS_WIDTH = 32,
    
    parameter POOL_IW_WIDTH = 10,
    parameter POOL_IH_WIDTH = 10,
    parameter POOL_IC_WIDTH = 10,
    parameter POOL_IMG_STA_ADD_WIDTH = 10,
    parameter POOL_IMG_END_ADD_WIDTH = 10,
    parameter POOLTYPE_WIDTH = 3,
    parameter POOLSCALE_WIDTH = 8,
    parameter POOLSHIFT_WIDTH = 4,
    parameter POOLWIDTH_WIDTH = 4,
    parameter POOLHEIGHT_WIDTH = 4,
    parameter POOLSTRIDE_W_WIDTH = 4,
    parameter POOLSTRIDE_H_WIDTH = 4,
    parameter POOLCEIL_WIDTH = 1,
    parameter POOLPAD_L_WIDTH = 4,
    parameter POOLPAD_R_WIDTH = 4,
    parameter POOLPAD_T_WIDTH = 4,
    parameter POOLPAD_B_WIDTH = 4,
    parameter POOL_PREFETCH_WIDTH = 1
    )(
    input [(INPUT_WIDTH)-1 : 0] din,
    input sel,
    input write,
    input done,
    input clk,
    output reg ready = 0,
    output reg valid,
    output reg [OP_CODE_WIDTH - 1 : 0] opcode = 0,
    output reg [POOL_IW_WIDTH - 1 : 0] pool_iw,
    output reg [POOL_IH_WIDTH - 1 : 0] pool_ih,
    output reg [POOL_IC_WIDTH - 1 : 0] pool_ic,
    output reg [POOL_IMG_STA_ADD_WIDTH - 1 : 0] pool_img_sta_add,
    output reg [POOL_IMG_END_ADD_WIDTH - 1 : 0] pool_img_end_add,
    output reg [POOLTYPE_WIDTH - 1 : 0] pooltype,
    output reg [POOLSCALE_WIDTH - 1 : 0] poolscale,
    output reg [POOLSHIFT_WIDTH - 1 : 0] poolshift,
    output reg [POOLWIDTH_WIDTH - 1 : 0] poolwidth,
    output reg [POOLHEIGHT_WIDTH - 1 : 0] poolheight,
    output reg [POOLSTRIDE_W_WIDTH - 1 : 0] poolstride_w,
    output reg [POOLSTRIDE_H_WIDTH - 1 : 0] poolstride_h,
    output reg [POOLCEIL_WIDTH - 1 : 0] poolceil,
    output reg [POOLPAD_L_WIDTH - 1 : 0] pool_pad_l,
    output reg [POOLPAD_R_WIDTH - 1 : 0] pool_pad_r,
    output reg [POOLPAD_T_WIDTH - 1 : 0] pool_pad_t,
    output reg [POOLPAD_B_WIDTH - 1 : 0] pool_pad_b,
    output reg [POOL_PREFETCH_WIDTH - 1 : 0] pool_prefetch
);

    `include "../common/instructions.vh"

reg [(OUTPUT_WIDTH)-1 : 0] data_instruction = 0;
reg [2:0] state = 0;
reg [17:0] count = 0;
parameter IDLE = 3'b000;
parameter REGISTER = 3'b001;
parameter CONCAT = 3'b011; 
// assign valid = done;  //valid gets high as soon as done bit is received indicating that all the respective data has been assigned to the output signals           

always @(posedge clk) begin
    case(state)
    IDLE: begin
        data_instruction <= 0;
        ready <= 0;
        valid <= 0;
        count <= 0;
        state <= REGISTER;
    end
    REGISTER: begin
        if(sel) begin
            ready <= 1'b1;
            if(write) begin
                if(count < (CNT-1)) begin
                    data_instruction[OUTPUT_WIDTH-(count*8)-1 -:8] <= din;
                    count <= count + 1;
                    state <= REGISTER;
                end
                else begin
                    data_instruction[OUTPUT_WIDTH-(count*8)-1 -:8] <= din;
                    count <= 0;
                    state <= CONCAT;
                end
            end
        end
    end
    CONCAT: begin
        // if(done) begin
            opcode <= data_instruction[`POOL_Opcode];
            pool_iw <= data_instruction[`POOL_IW];
            pool_ih <= data_instruction[`POOL_IH];
            pool_ic <= data_instruction[`POOL_IC];
            pool_img_sta_add <= data_instruction[`POOL_ImageStartAddress];
            pool_img_end_add <= data_instruction[`POOL_ImageEndAddress];
            pooltype <= data_instruction[`POOL_PoolType];
            poolscale <= data_instruction[`POOL_PoolScale];
            poolshift <= data_instruction[`POOL_PoolShift];
            poolwidth <= data_instruction[`POOL_PoolWidth];
            poolheight <= data_instruction[`POOL_PoolHeight];
            poolstride_w <= data_instruction[`POOL_PoolStrideWidth];
            poolstride_h <= data_instruction[`POOL_PoolStrideHeight];
            poolceil <= data_instruction[`POOL_PoolCeil];
            pool_pad_l <= data_instruction[`POOL_PadLeft];
            pool_pad_r <= data_instruction[`POOL_PadRight];
            pool_pad_t <= data_instruction[`POOL_PadTop];
            pool_pad_b <= data_instruction[`POOL_PadBottom];
            pool_prefetch <= data_instruction[`POOL_Im2colPrefetch];
            valid <= 1'b1;
            state <= IDLE;
        // end
    end
    endcase
end

endmodule
`endif
