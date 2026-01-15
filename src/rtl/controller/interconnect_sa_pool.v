`include "../common/arch_param.vh"

module interconnect_sa_pool #(
    OPCODE_WIDTH = 4,
    CONV_KW_WIDTH = 10,
    CONV_KH_WIDTH = 10,
    CONV_PadLeft_WIDTH = 10,
    CONV_PadRight_WIDTH = 10,
    CONV_PadTop_WIDTH = 10,
    CONV_PadBottom_WIDTH = 10,
    CONV_IW_WIDTH = 10,
    CONV_IH_WIDTH = 10,
    CONV_STRIDE_WIDTH = 10,
    POOLWIDTH_WIDTH = 10,
    POOLHEIGHT_WIDTH = 10,
    POOLPAD_L_WIDTH = 10,
    POOLPAD_R_WIDTH = 10,
    POOLPAD_T_WIDTH = 10,
    POOLPAD_B_WIDTH = 10,
    POOL_IW_WIDTH = 10,
    POOL_IH_WIDTH = 10,
    POOLSTRIDE_W_WIDTH = 10,
    POOLSTRIDE_H_WIDTH = 10
)(
    input clk,
    input rst,

    input [OPCODE_WIDTH-1:0] opcode,
    
    // CONV
    input [CONV_KW_WIDTH-1:0] kernel_width,
    input [CONV_KH_WIDTH-1:0] kernel_height,
    input [CONV_PadLeft_WIDTH-1:0] conv_pad_left,
    input [CONV_PadRight_WIDTH-1:0] conv_pad_right,
    input [CONV_PadTop_WIDTH-1:0] conv_pad_top,
    input [CONV_PadBottom_WIDTH-1:0] conv_pad_bottom,
    input [CONV_IW_WIDTH-1:0] image_width,
    input [CONV_IH_WIDTH-1:0] image_height,
    input [CONV_STRIDE_WIDTH-1:0] stride_col,
    input [CONV_STRIDE_WIDTH-1:0] stride_row,
    
    `ifdef MEGA_POOL
    // POOL
    input [POOLWIDTH_WIDTH - 1 : 0] PoolWidth,
    input [POOLHEIGHT_WIDTH - 1 : 0] PoolHeight,
    input [POOLPAD_L_WIDTH - 1 : 0] PoolPadL,
    input [POOLPAD_R_WIDTH - 1 : 0] PoolPadR,
    input [POOLPAD_T_WIDTH - 1 : 0] PoolPadT,
    input [POOLPAD_B_WIDTH - 1 : 0] PoolPadB,
    input [POOL_IW_WIDTH - 1 : 0] PoolIW,
    input [POOL_IH_WIDTH - 1 : 0] PoolIH,
    input [POOLSTRIDE_W_WIDTH - 1 : 0] PoolStrideW,
    input [POOLSTRIDE_H_WIDTH - 1 : 0] PoolStrideH,
    `endif
    
    output reg [CONV_KW_WIDTH-1:0] KernelWidth,
    output reg [CONV_KH_WIDTH-1:0] KernelHeight,
    output reg [CONV_PadLeft_WIDTH-1:0] PadLeft,
    output reg [CONV_PadRight_WIDTH-1:0] PadRight,
    output reg [CONV_PadTop_WIDTH-1:0] PadTop,
    output reg [CONV_PadBottom_WIDTH-1:0] PadBottom,
    output reg [CONV_IW_WIDTH-1:0] ImageWidth,
    output reg [CONV_IH_WIDTH-1:0] ImageHeight,
    output reg [CONV_STRIDE_WIDTH-1:0] StrideWidth,
    output reg [CONV_STRIDE_WIDTH-1:0] StrideHeight
);

    always @(posedge clk) begin
        if(!rst) begin
            KernelWidth <= 0;
            KernelHeight <= 0;
            PadLeft <= 0;
            PadRight <= 0;
            PadTop <= 0;
            PadBottom <= 0;
            ImageWidth <= 0;
            ImageHeight <= 0;
            StrideWidth <= 0;
            StrideHeight <= 0;
        end 
        else begin
        case(opcode)
            `OP_CONV: begin
                KernelWidth <= kernel_width;
                KernelHeight <= kernel_height;
                PadLeft <= conv_pad_left;
                PadRight <= conv_pad_right;
                PadTop <= conv_pad_top;
                PadBottom <= conv_pad_bottom;
                ImageWidth <= image_width;
                ImageHeight <= image_height;
                StrideWidth <= stride_col;
                StrideHeight <= stride_row;
            end

            `ifdef MEGA_POOL
            `OP_POOL: begin
                KernelWidth <= PoolWidth;
                KernelHeight <= PoolHeight;
                PadLeft <= PoolPadL;
                PadRight <= PoolPadR;
                PadTop <= PoolPadT;
                PadBottom <= PoolPadB;
                ImageWidth <= PoolIW;
                ImageHeight <= PoolIH;
                StrideWidth <= PoolStrideW;
                StrideHeight <= PoolStrideH;
            end
            `endif

            default: begin
                KernelWidth <= 0;
                KernelHeight <= 0;
                PadLeft <= 0;
                PadRight <= 0;
                PadTop <= 0;
                PadBottom <= 0;
                ImageWidth <= 0;
                ImageHeight <= 0;
                StrideWidth <= 0;
                StrideHeight <= 0;
            end
        endcase
    end
    end
endmodule