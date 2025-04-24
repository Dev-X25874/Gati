module EltWise_controller#(
    parameter DATA_WIDTH = 8,
    parameter N = 4,  
    parameter FIFO_NO = 8,
    parameter ELTWISE_IW_WIDTH = 10, // Width of the input width;
    parameter ELTWISE_IH_WIDTH = 10, // Width of the input height;
    parameter ELTWISE_IC_WIDTH = 10 // Width of the output width;
)(
    input clkin,
    input rst,
    input EltWise_op_en,
    input [DATA_WIDTH * FIFO_NO*N - 1:0] LeftOperand_data_out,
    input [DATA_WIDTH * FIFO_NO*N - 1:0] RightOperand_data_out,
    input [ELTWISE_IW_WIDTH-1:0]EltWise_IW,
    input [ELTWISE_IH_WIDTH-1:0]EltWise_IH,
    input [ELTWISE_IC_WIDTH-1:0]EltWise_IC,
    input [FIFO_NO - 1:0] LeftOperand_valid_fifo,
    input [FIFO_NO - 1:0] RightOperand_valid_fifo,
    input [FIFO_NO - 1:0] LeftOperand_empty_flag,
    input [FIFO_NO - 1:0] RightOperand_empty_flag,

    output reg [FIFO_NO - 1:0] element_rd_en,
    output reg [(DATA_WIDTH * N) - 1:0] LeftOperand_fifo_data_out,
    output reg [(DATA_WIDTH * N) - 1:0] RightOperand_fifo_data_out,
    output reg EW_done,
    output reg data_valid,
    input op_fifo_empty
);

reg [$clog2(FIFO_NO)-1:0] cycle_idx = 0;
reg [$clog2(FIFO_NO)-1:0] cycle_idx1 = 0;
reg [ELTWISE_IW_WIDTH+ELTWISE_IH_WIDTH-1:0] cnt1 = 0;
(* syn_use_dsp = "no" *) reg [ELTWISE_IW_WIDTH+ELTWISE_IH_WIDTH-1:0] r_img_size= 0;
reg stop = 0;
always @(posedge clkin) begin
    r_img_size <= EltWise_IW * EltWise_IH;
end
always @(posedge clkin) begin
    if (!rst) begin
        cycle_idx <= 0;
        cycle_idx1 <= 0;
        cnt1 <= 0;
        element_rd_en <= 0;
        LeftOperand_fifo_data_out <= 0;
        RightOperand_fifo_data_out <= 0;
        data_valid <= 0;
        EW_done <= 0;
        stop <= 0;
    end 
    else begin
        element_rd_en <= 0;
        if (EltWise_op_en && cnt1 == r_img_size) begin
            EW_done <= 1'b1;
        end else begin
            EW_done <= 1'b0;
        end

        if (cnt1 == r_img_size-3) begin
            stop <= 1;
        end
        else if (op_fifo_empty) begin
            stop <= 0;
        end

        if (!stop) begin
            if(!LeftOperand_empty_flag[cycle_idx] && !RightOperand_empty_flag[cycle_idx]) begin
                element_rd_en[cycle_idx] <= 1'b1;
                cycle_idx <= cycle_idx + 1;
            end 
            else begin
                element_rd_en <= 0;
            end
        end
        if (LeftOperand_valid_fifo[cycle_idx1] && RightOperand_valid_fifo[cycle_idx1]) begin
            LeftOperand_fifo_data_out <= LeftOperand_data_out[(FIFO_NO - cycle_idx1) * DATA_WIDTH*N - 1 -: DATA_WIDTH*N];
            RightOperand_fifo_data_out <= RightOperand_data_out[(FIFO_NO - cycle_idx1) * DATA_WIDTH*N - 1 -: DATA_WIDTH*N];
            data_valid <= 1'b1;
            cnt1 <= cnt1 + 1;
            cycle_idx1 <= cycle_idx1 + 1;
        end
        else begin
            if (cnt1 == r_img_size)begin
                cnt1 <= 0;
            end 
            data_valid <= 1'b0;
        end
    end
end
endmodule
