`include "../common/instructions.vh"
`include "../common/arch_param.vh"
module Top_element_wise#(
    parameter DATA_WIDTH            = 8,
    parameter ELTWISE_TYPE_WIDTH    = 4,
    parameter ELTWISE_SCALE_WIDTH   = 32,
    parameter ELTWISE_ZEROPOINT_WIDTH = 8,
    parameter ELTWISE_QUANT_SHIFT   = 8,
    parameter N                     = 4,
    parameter MOD                   = 4,
    parameter FIFO_NO               = 8,
    parameter W_ADDR                = 9,
    parameter DATA_WIDTH_OB         = 32,
    parameter I_OP_SIZE_WIDTH       = 16,

    parameter ELTWISE_IW_WIDTH      = 10, // Width of the input width;
    parameter ELTWISE_IH_WIDTH      = 10, // Width of the input height;
    parameter ELTWISE_IC_WIDTH      = 10 // Width of the output width;
)
(
    input clkin,
    input rst,
    input EltWise_op_en,
    input [I_OP_SIZE_WIDTH-1:0] img_dim_Op,
    input [FIFO_NO-1:0]LeftOperand_wr_en,
    input [FIFO_NO-1:0]RightOperand_wr_en,
    input [ELTWISE_IW_WIDTH-1:0]EltWise_IW,
    input [ELTWISE_IH_WIDTH-1:0]EltWise_IH,
    input [ELTWISE_IC_WIDTH-1:0]EltWise_IC,
    input [(DATA_WIDTH*FIFO_NO*N)-1:0]LeftOperand_data_in,
    input [(DATA_WIDTH*FIFO_NO*N)-1:0]RightOperand_data_in,
    input [ELTWISE_TYPE_WIDTH-1:0]EltWise_type,
    input [ELTWISE_SCALE_WIDTH-1:0]LeftOperand_Scale,
    input [ELTWISE_SCALE_WIDTH-1:0]RightOperand_Scale,
    input [ELTWISE_ZEROPOINT_WIDTH-1:0]LeftOperand_zero_point,
    input [ELTWISE_ZEROPOINT_WIDTH-1:0]RightOperand_zero_point,
    output [(DATA_WIDTH_OB*N)-1:0]EltWise_data_out,
    output [N-1:0]EltWise_data_out_valid,
    output [((W_ADDR+1)*FIFO_NO)-1:0]LeftOperand_fifo_occupants,
    output [((W_ADDR+1)*FIFO_NO)-1:0]RightOperand_fifo_occupants,
    output [ELTWISE_QUANT_SHIFT-1:0]EltWise_fp_cast_shift,
    output EW_done,
    input op_fifo_empty
);
wire [(DATA_WIDTH*FIFO_NO*N)-1:0] LeftOperand_data_in_reordered,RightOperand_data_in_reordered;
wire [(DATA_WIDTH*FIFO_NO*N)-1:0] LeftOperand_data_out,RightOperand_data_out;
wire [FIFO_NO-1:0] LeftOperand_empty_flag,RightOperand_empty_flag;
wire [FIFO_NO-1:0] LeftOperand_full,RightOperand_full;
wire [FIFO_NO-1:0] LeftOperand_valid_fifo,RightOperand_valid_fifo;
wire [(DATA_WIDTH*N)-1:0] LeftOperand_fifo_data_out,RightOperand_fifo_data_out;
wire [FIFO_NO-1:0] element_rd_en;
wire data_valid;
reg [ELTWISE_TYPE_WIDTH-1:0] r_EltWise_type;

localparam ELTWISE_FP_BIT_SHIFT = 10; //Todo: Should be replaced with parameter depending on the precision required for floating point
// assign EltWise_fp_cast_shift = ELTWISE_FP_BIT_SHIFT;
`ifdef ELTWISE_SIGMOID_TANH
reg [ELTWISE_QUANT_SHIFT-1:0] eltwise_fp_bit_shift_;

always@(EltWise_type) begin
    case (EltWise_type)
        `ELTWISE_SIG, `ELTWISE_TANH, `ELTWISE_MUL: eltwise_fp_bit_shift_ <= 16;
        `ELTWISE_ADD, `ELTWISE_SUB: eltwise_fp_bit_shift_ <= ELTWISE_FP_BIT_SHIFT;
        default: eltwise_fp_bit_shift_ <= ELTWISE_FP_BIT_SHIFT;
    endcase
end
assign EltWise_fp_cast_shift = eltwise_fp_bit_shift_;
`else 
assign EltWise_fp_cast_shift = ELTWISE_FP_BIT_SHIFT;
`endif

conv_output_reorder_EW #(
    .W_DATA(DATA_WIDTH),
    .N_BYTES(N*FIFO_NO),
    .N(N),
    .FIFO_NO(FIFO_NO)
) reorder_LeftOperand (
    .i_data(LeftOperand_data_in),
    .o_data(LeftOperand_data_in_reordered)
);
conv_output_reorder_EW #(
    .W_DATA(DATA_WIDTH),
    .N_BYTES(N*FIFO_NO),
    .N(N),
    .FIFO_NO(FIFO_NO)
) reorder_RightOperand (
    .i_data(RightOperand_data_in),
    .o_data(RightOperand_data_in_reordered)
);
dram_fifo #(
    .DIMENSION(FIFO_NO),
    .W_DATA(DATA_WIDTH*N),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(1 << W_ADDR),
    .OUTPUT_REG(0)

) fifo_LeftOperand (
    .i_clk(clkin),
    .i_rst(rst),
    .i_data(LeftOperand_data_in_reordered),
    .i_read_enable(element_rd_en),
    .i_write_enable(LeftOperand_wr_en),
    .o_data(LeftOperand_data_out),
    .o_fifo_empty(LeftOperand_empty_flag),
    .o_fifo_full(LeftOperand_full),
    .o_fifo_dv(LeftOperand_valid_fifo),
    .o_occupants(LeftOperand_fifo_occupants)
);
dram_fifo #(.DIMENSION(FIFO_NO),
    .W_DATA(DATA_WIDTH*N),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(1 << W_ADDR),
    .OUTPUT_REG(0)

) fifo_RightOperand (
    .i_clk(clkin),
    .i_rst(rst),
    .i_data(RightOperand_data_in_reordered),
    .i_read_enable(element_rd_en),
    .i_write_enable(RightOperand_wr_en),
    .o_data(RightOperand_data_out),
    .o_fifo_empty(RightOperand_empty_flag),
    .o_fifo_full(RightOperand_full),
    .o_fifo_dv(RightOperand_valid_fifo),
    .o_occupants(RightOperand_fifo_occupants)
);
EltWise_controller #(
    .DATA_WIDTH(DATA_WIDTH),  
    .N(N),           
    .MOD(MOD),
    .FIFO_NO(FIFO_NO),
    .I_OP_SIZE_WIDTH(I_OP_SIZE_WIDTH),
    .ELTWISE_IW_WIDTH(ELTWISE_IW_WIDTH),
    .ELTWISE_IH_WIDTH(ELTWISE_IH_WIDTH),
    .ELTWISE_IC_WIDTH(ELTWISE_IC_WIDTH),
    .ELTWISE_TYPE_WIDTH(ELTWISE_TYPE_WIDTH)
)EltWise_controller(
    .clkin(clkin),
    .rst(rst),
    .EltWise_op_en(EltWise_op_en),
    .img_dim_Op(img_dim_Op),
    .LeftOperand_data_out(LeftOperand_data_out),
    .RightOperand_data_out(RightOperand_data_out),
    .LeftOperand_valid_fifo(LeftOperand_valid_fifo),
    .RightOperand_valid_fifo(RightOperand_valid_fifo),
    .element_rd_en(element_rd_en),
    .EltWise_IW(EltWise_IW),
    .EltWise_IH(EltWise_IH),
    .EltWise_IC(EltWise_IC),
    .LeftOperand_empty_flag(LeftOperand_empty_flag),
    .EltWise_type(EltWise_type),
    .RightOperand_empty_flag(RightOperand_empty_flag),
    .LeftOperand_fifo_data_out(LeftOperand_fifo_data_out),
    .RightOperand_fifo_data_out(RightOperand_fifo_data_out),
    .EW_done(EW_done),
    .data_valid(data_valid),
    .op_fifo_empty(op_fifo_empty)
);

genvar i;
generate
    for(i=0;i<N;i=i+1)begin
      if(i < 8) begin
        element_wise_op#(
            .DATA_WIDTH(DATA_WIDTH),
            .ELTWISE_TYPE_WIDTH(ELTWISE_TYPE_WIDTH),
            .ELTWISE_SCALE_WIDTH(ELTWISE_SCALE_WIDTH),
            .ELTWISE_ZEROPOINT_WIDTH(ELTWISE_ZEROPOINT_WIDTH),
            .DATA_WIDTH_OB(DATA_WIDTH_OB)
        ) ew_op (
            .clkin(clkin),
            .rst(rst), 
            .LeftOperand(LeftOperand_fifo_data_out[((N-i)*DATA_WIDTH)-1 -:DATA_WIDTH]),
            .RightOperand(RightOperand_fifo_data_out[((N-i)*DATA_WIDTH)-1 -:DATA_WIDTH]),
            .data_valid(data_valid),
            .LeftOperand_Scale(LeftOperand_Scale),
            .RightOperand_Scale(RightOperand_Scale),
            .LeftOperand_zero_point(LeftOperand_zero_point),
            .RightOperand_zero_point(RightOperand_zero_point),
            .EltWise_type(EltWise_type),
            .EltWise_out(EltWise_data_out[((N-i)*DATA_WIDTH_OB)-1 -: DATA_WIDTH_OB]),
            .EltWise_valid(EltWise_data_out_valid[i]) 
        );
      /* Duplicate modules from element_wise_op to interpolator_engine have
      been created for lut-based instantiation. */
      end else begin
        element_wise_op_lut #(
            .DATA_WIDTH(DATA_WIDTH),
            .ELTWISE_TYPE_WIDTH(ELTWISE_TYPE_WIDTH),
            .ELTWISE_SCALE_WIDTH(ELTWISE_SCALE_WIDTH),
            .ELTWISE_ZEROPOINT_WIDTH(ELTWISE_ZEROPOINT_WIDTH),
            .DATA_WIDTH_OB(DATA_WIDTH_OB)
        ) ew_op_lut (
            .clkin(clkin),
            .rst(rst),
            .LeftOperand(LeftOperand_fifo_data_out[((N-i)*DATA_WIDTH)-1 -:DATA_WIDTH]),
            .RightOperand(RightOperand_fifo_data_out[((N-i)*DATA_WIDTH)-1 -:DATA_WIDTH]),
            .data_valid(data_valid),
            .LeftOperand_Scale(LeftOperand_Scale),
            .RightOperand_Scale(RightOperand_Scale),
            .LeftOperand_zero_point(LeftOperand_zero_point),
            .RightOperand_zero_point(RightOperand_zero_point),
            .EltWise_type(EltWise_type),
            .EltWise_out(EltWise_data_out[((N-i)*DATA_WIDTH_OB)-1 -: DATA_WIDTH_OB]),
            .EltWise_valid(EltWise_data_out_valid[i]) 
        );
      end
    end
endgenerate
endmodule
