module EltWise_controller#(
    parameter DATA_WIDTH = 8,
    parameter N = 4,  
    parameter FIFO_NO = 8,
    parameter I_OP_SIZE_WIDTH = 16,
    parameter ELTWISE_IW_WIDTH = 10, // Width of the input width;
    parameter ELTWISE_IH_WIDTH = 10, // Width of the input height;
    parameter ELTWISE_IC_WIDTH = 10 // Width of the output width;
)(
    input clkin,
    input rst,
    input EltWise_op_en,
    input [I_OP_SIZE_WIDTH-1:0] img_dim_Op,
    input [DATA_WIDTH * FIFO_NO*N - 1:0] LeftOperand_data_out,
    input [DATA_WIDTH * FIFO_NO*N - 1:0] RightOperand_data_out,
    input [ELTWISE_IW_WIDTH-1:0]EltWise_IW,
    input [ELTWISE_IH_WIDTH-1:0]EltWise_IH,
    input [ELTWISE_IC_WIDTH-1:0]EltWise_IC,
    input [FIFO_NO - 1:0] LeftOperand_valid_fifo,
    input [FIFO_NO - 1:0] RightOperand_valid_fifo,
    input [FIFO_NO - 1:0] LeftOperand_empty_flag,
    input [FIFO_NO - 1:0] RightOperand_empty_flag,

    output [FIFO_NO - 1:0] element_rd_en,
    output reg [(DATA_WIDTH * N) - 1:0] LeftOperand_fifo_data_out,
    output reg [(DATA_WIDTH * N) - 1:0] RightOperand_fifo_data_out,
    output reg EW_done,
    output reg data_valid,
    input op_fifo_empty
);

reg [$clog2(FIFO_NO)-1:0] cycle_idx = 0;
reg [$clog2(FIFO_NO)-1:0] cycle_idx1 = 0;
reg [$clog2(FIFO_NO)-1:0] delay_idx = 0;

reg [ELTWISE_IW_WIDTH+ELTWISE_IH_WIDTH-1:0] cnt1 = 0;
(* syn_use_dsp = "no" *) reg [ELTWISE_IW_WIDTH+ELTWISE_IH_WIDTH-1:0] r_img_size= 0;
reg stop = 0;

always @(posedge clkin) begin
    r_img_size <= EltWise_IW * EltWise_IH;
end

// Status monitoring to read the zeropadded data after the image size is reached
wire [FIFO_NO-1:0] diff;
reg [FIFO_NO-1:0] count_diff = 0;

assign diff = (img_dim_Op - r_img_size);

wire valid_diff;
assign valid_diff = (EltWise_op_en && (|(diff)));

reg [1:0] state = 0;
reg sig_en = 0;

reg fifo_rden = 0;
reg [ELTWISE_IW_WIDTH+ELTWISE_IH_WIDTH-1:0] rd_counter = 0; // Added for debugging purpose only: Later can be removed(Important)
// Read enable logic for element-wise operation
always @(posedge clkin) begin
    if (!rst) begin
        cycle_idx <= 0;
        // cycle_idx1 <= 0;
        rd_counter <= 0;
        // cnt1 <= 0;
        fifo_rden <= 0;
        // LeftOperand_fifo_data_out <= 0;
        // RightOperand_fifo_data_out <= 0;
        // data_valid <= 0;
        EW_done <= 0;
        state <= 0;
        count_diff <= 0;
        sig_en <= 0;
    end 
    else begin
        delay_idx <= cycle_idx;
        case(state)
        0: begin
            sig_en <= 0;
            count_diff <= 0;
            if((rd_counter == r_img_size) && (rd_counter!=0)) begin
                fifo_rden <= 0;
                cycle_idx <= cycle_idx;
                rd_counter <= rd_counter;
                state <= 1;
            end
            else begin
                if(!LeftOperand_empty_flag[cycle_idx] && !RightOperand_empty_flag[cycle_idx]) begin
                    fifo_rden <= 1'b1;
                    rd_counter <= rd_counter + 1;
                    cycle_idx <= cycle_idx + 1;
                    state <= 0;
                end
                else begin
                    fifo_rden <= 0;
                    cycle_idx <= cycle_idx;
                    rd_counter <= rd_counter;
                    state <= 0;
                end
            end
        end
        
        1: begin
            count_diff <= 0;
            sig_en <= 0;
            cycle_idx <= cycle_idx;
            fifo_rden <= 0;
            if(EltWise_op_en && (cnt1 == r_img_size)) begin
                EW_done <= 1'b1;
                rd_counter <= 0;
                state <= 2;
            end
            else begin
                EW_done <= 1'b0;
                rd_counter <= rd_counter;
                state <= 1;
            end
        end
        
        2: begin
            EW_done <= 1'b0;
            if(count_diff < diff) begin
                count_diff <= count_diff + 1;
                sig_en <= 1; // Enable the read signals for the extra cycles
                fifo_rden <= 1'b1;
                cycle_idx <= cycle_idx + 1;
                state <= 2;
            end
            else begin
                count_diff <= 0;
                state <= 3;
                sig_en <= sig_en;
                fifo_rden <= 0;
                cycle_idx <= 0; 
            end
        end

        3: begin
            fifo_rden <= 0;
            if(op_fifo_empty) begin 
                state <= 0;
                sig_en <= 0;
            end
            else state <= 3;
        end
        endcase
    end
end

always @ (posedge clkin) begin
    if(!rst) begin
        cnt1 <= 0;
        cycle_idx1 <= 0;
        data_valid <= 0;
        LeftOperand_fifo_data_out <= 0;
        RightOperand_fifo_data_out <= 0;
    end
    else begin
         if (|(LeftOperand_valid_fifo) && |(RightOperand_valid_fifo) && ~sig_en) begin
            LeftOperand_fifo_data_out <= LeftOperand_data_out[(FIFO_NO - cycle_idx1) * DATA_WIDTH*N - 1 -: DATA_WIDTH*N];
            RightOperand_fifo_data_out <= RightOperand_data_out[(FIFO_NO - cycle_idx1) * DATA_WIDTH*N - 1 -: DATA_WIDTH*N];
            data_valid <= 1'b1;
            cnt1 <= cnt1 + 1;
            cycle_idx1 <= cycle_idx1 + 1;
        end
        else begin
            if (cnt1 == r_img_size)begin
                cnt1 <= 0;
                cycle_idx1 <= 0;
            end 
            data_valid <= 1'b0;
        end
    end
end

always@(posedge clkin) begin
    if (cnt1 == r_img_size-3) stop <= 1;
    else if (op_fifo_empty) stop <= 0;
    else stop <= stop;
end

// Read signal for FIFOs
demux_param1 #(
    .N_PORT(FIFO_NO),
    .DATA_WIDTH(1)
) 
demux_element_rd_en (
    .i_din(fifo_rden),
    .i_sel(delay_idx),
    .o_dout(element_rd_en)
);

endmodule
