`include "../common/instructions.vh"
`include "../common/arch_param.vh"
module element_wise_op#(
  parameter DATA_WIDTH = 8,
  parameter ELTWISE_TYPE_WIDTH = 4,
  parameter ELTWISE_SCALE_WIDTH = 32,
  parameter ELTWISE_ZEROPOINT_WIDTH = 8,
  parameter DATA_WIDTH_OB = 32
)
(
  input clkin,
  input rst,
  input signed [DATA_WIDTH-1:0] LeftOperand,
  input signed [DATA_WIDTH-1:0] RightOperand,
  input data_valid,

  input [ELTWISE_SCALE_WIDTH-1:0] LeftOperand_Scale,
  input [ELTWISE_SCALE_WIDTH-1:0] RightOperand_Scale,
  
  input [ELTWISE_ZEROPOINT_WIDTH-1:0] LeftOperand_zero_point,
  input [ELTWISE_ZEROPOINT_WIDTH-1:0] RightOperand_zero_point,

  input [ELTWISE_TYPE_WIDTH-1:0] EltWise_type,
  output signed [DATA_WIDTH_OB-1:0] EltWise_out,  //  32-bit output
  output reg EltWise_valid
);

localparam SHIFT_BITS = 16;
`ifdef ELTWISE_MULT_HW // to minimise resource usage
  localparam OP_WIDTH = 2 * DATA_WIDTH_OB;
`else
  localparam OP_WIDTH = DATA_WIDTH_OB + 1;
`endif

// Shift the operands by their respective zero points
// This is to ensure that the inputs are centered around zero before scaling
reg signed [DATA_WIDTH-1:0] LeftOperand_shifted;
reg signed [DATA_WIDTH-1:0] RightOperand_shifted;
reg data_valid_shifted;
always @(posedge clkin) begin
  if (data_valid) begin
    LeftOperand_shifted   <= (LeftOperand - LeftOperand_zero_point);
    RightOperand_shifted  <= (RightOperand - RightOperand_zero_point); 
    data_valid_shifted <= 1'b1;
  end else begin
    data_valid_shifted <= 1'b0;
  end
end

// Multiply the shifted operands with their respective scales
reg signed [(DATA_WIDTH + ELTWISE_SCALE_WIDTH)-1:0] LeftOperand_scaled;
reg signed [(DATA_WIDTH + ELTWISE_SCALE_WIDTH)-1:0] RightOperand_scaled;
reg data_valid_scaled;
always @(posedge clkin) begin
  if (data_valid_shifted) begin
    LeftOperand_scaled   <= $signed(LeftOperand_shifted) * $signed(LeftOperand_Scale);
    RightOperand_scaled  <= $signed(RightOperand_shifted) * $signed(RightOperand_Scale);
    data_valid_scaled    <= 1'b1;
  end else begin
    data_valid_scaled <= 1'b0;
  end
end

wire w_tanh_valid;
`ifdef ELTWISE_SIGMOID_TANH
reg tanh_sigmoid;
always@(posedge clkin) tanh_sigmoid <= (EltWise_type == `ELTWISE_SIG) ? 1 : 0;
wire signed [DATA_WIDTH_OB-1:0] w_tanh_output;
top_Tanh_Sigmoid_Engine#(
  .DATA_WIDTH(DATA_WIDTH),
  .FP_BITS(SHIFT_BITS),
  .SCALE_WIDTH(DATA_WIDTH+ELTWISE_SCALE_WIDTH),
  .LUT_SIZE(),
  .OUT_DATA_WIDTH(DATA_WIDTH_OB)
) tanh_sigmoid_inst (
  .i_clk(clkin),
  .i_rst(rst),
  .i_data_valid(data_valid_scaled),
  .scaled_data_in(LeftOperand_scaled),
  .i_tanh_sigmoid(tanh_sigmoid),
  .o_data_valid(w_tanh_valid),
  .o_data_out(w_tanh_output)
);
`endif

assign data_valid_eltwise = ((EltWise_type == `ELTWISE_SIG) || (EltWise_type == `ELTWISE_TANH)) ? w_tanh_valid : data_valid_scaled;

reg signed [OP_WIDTH - 1:0] r_EltWise_out;
always @(posedge clkin) 
begin
  if (data_valid_eltwise) 
  begin
    case (EltWise_type)
      `ELTWISE_ADD  : r_EltWise_out <= LeftOperand_scaled + RightOperand_scaled;    // Addition
      `ifdef ELTWISE_SIGMOID_TANH
        `ELTWISE_SIG, `ELTWISE_TANH : r_EltWise_out <= w_tanh_output;               // Sigmoid (or) Tanh
      `endif
      `ifdef ELTWISE_SUB_HW
        `ELTWISE_SUB  : r_EltWise_out <= LeftOperand_scaled - RightOperand_scaled;  // Subtraction
      `endif
      `ifdef ELTWISE_MULT_HW
        `ELTWISE_MULT : r_EltWise_out <= LeftOperand_scaled * RightOperand_scaled;  // Multiplication (signed)
      `endif
      default: r_EltWise_out <= 0;  // Default case to handle unexpected values
    endcase
    EltWise_valid <= 1;
  end
  else begin
    EltWise_valid <= 0;
  end
end

assign EltWise_out = $signed(r_EltWise_out[DATA_WIDTH_OB-1:0]);

endmodule

module element_wise_op_lut#(
  parameter DATA_WIDTH = 8,
  parameter ELTWISE_TYPE_WIDTH = 4,
  parameter ELTWISE_SCALE_WIDTH = 32,
  parameter ELTWISE_ZEROPOINT_WIDTH = 8,
  parameter DATA_WIDTH_OB = 32
)
(
  input clkin,
  input rst,
  input signed [DATA_WIDTH-1:0] LeftOperand,
  input signed [DATA_WIDTH-1:0] RightOperand,
  input data_valid,

  input [ELTWISE_SCALE_WIDTH-1:0] LeftOperand_Scale,
  input [ELTWISE_SCALE_WIDTH-1:0] RightOperand_Scale,

  input [ELTWISE_ZEROPOINT_WIDTH-1:0] LeftOperand_zero_point,
  input [ELTWISE_ZEROPOINT_WIDTH-1:0] RightOperand_zero_point,

  input [ELTWISE_TYPE_WIDTH-1:0] EltWise_type,
  output signed [DATA_WIDTH_OB-1:0] EltWise_out,  //  32-bit output
  output reg EltWise_valid
);

localparam SHIFT_BITS = 16;
`ifdef ELTWISE_MULT_HW // to minimise resource usage
  localparam OP_WIDTH = 2 * DATA_WIDTH_OB;
`else
  localparam OP_WIDTH = DATA_WIDTH_OB + 1;
`endif

// Shift the operands by their respective zero points
// This is to ensure that the inputs are centered around zero before scaling
reg signed [DATA_WIDTH-1:0] LeftOperand_shifted;
reg signed [DATA_WIDTH-1:0] RightOperand_shifted;
reg data_valid_shifted;
always @(posedge clkin) begin
  if (data_valid) begin
    LeftOperand_shifted   <= (LeftOperand - LeftOperand_zero_point);
    RightOperand_shifted  <= (RightOperand - RightOperand_zero_point); 
    data_valid_shifted <= 1'b1;
  end else begin
    data_valid_shifted <= 1'b0;
  end
end

// Multiply the shifted operands with their respective scales
reg signed [(DATA_WIDTH_OB)-1:0] LeftOperand_scaled;
reg signed [(DATA_WIDTH_OB)-1:0] RightOperand_scaled;
reg data_valid_scaled;
always @(posedge clkin) begin
  if (data_valid_shifted) begin
    LeftOperand_scaled   <= $signed(LeftOperand_shifted) * $signed(LeftOperand_Scale);
    RightOperand_scaled  <= $signed(RightOperand_shifted) * $signed(RightOperand_Scale);
    data_valid_scaled    <= 1'b1;
  end else begin
    data_valid_scaled <= 1'b0;
  end
end

wire w_tanh_valid;
`ifdef ELTWISE_SIGMOID_TANH
reg tanh_sigmoid;
always@(posedge clkin) tanh_sigmoid <= (EltWise_type == `ELTWISE_SIG) ? 1 : 0;
wire signed [DATA_WIDTH_OB-1:0] w_tanh_output;
top_Tanh_Sigmoid_Engine_lut#(
  .DATA_WIDTH(DATA_WIDTH),
  .FP_BITS(SHIFT_BITS),
  .LUT_SIZE(),
  .OUT_DATA_WIDTH(DATA_WIDTH_OB)
) tanh_sigmoid_inst_lut (
  .i_clk(clkin),
  .i_rst(rst),
  .i_data_valid(data_valid_scaled),
  .scaled_data_in(LeftOperand_scaled),
  .i_tanh_sigmoid(tanh_sigmoid),
  .o_data_valid(w_tanh_valid),
  .o_data_out(w_tanh_output)
);
`endif

assign data_valid_eltwise = ((EltWise_type == `ELTWISE_SIG) || (EltWise_type == `ELTWISE_TANH)) ? w_tanh_valid : data_valid_scaled;

reg signed [OP_WIDTH - 1:0] r_EltWise_out;
always @(posedge clkin) 
begin
  if (data_valid_eltwise) 
  begin
    case (EltWise_type)
      `ELTWISE_ADD  : r_EltWise_out <= LeftOperand_scaled + RightOperand_scaled;    // Addition
      `ifdef ELTWISE_SIGMOID_TANH
        `ELTWISE_SIG, `ELTWISE_TANH : r_EltWise_out <= w_tanh_output;               // Sigmoid (or) Tanh
      `endif
      `ifdef ELTWISE_SUB_HW
        `ELTWISE_SUB  : r_EltWise_out <= LeftOperand_scaled - RightOperand_scaled;  // Subtraction
      `endif
      `ifdef ELTWISE_MULT_HW
        `ELTWISE_MULT : r_EltWise_out <= LeftOperand_scaled * RightOperand_scaled;  // Multiplication (signed)
      `endif
      default: r_EltWise_out <= 0;  // Default case to handle unexpected values
    endcase
    EltWise_valid <= 1;
  end
  else begin
    EltWise_valid <= 0;
  end
end

assign EltWise_out = $signed(r_EltWise_out[DATA_WIDTH_OB-1:0]);

endmodule
