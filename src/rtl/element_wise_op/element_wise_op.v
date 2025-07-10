`include "../common/instructions.vh"
module element_wise_op#(
  parameter DATA_WIDTH = 8,
  parameter ELTWISE_TYPE_WIDTH = 4,
  parameter ELTWISE_SCALE_WIDTH = 32,
  parameter ELTWISE_ZEROPOINT_WIDTH = 8,
  parameter DATA_WIDTH_OB = 32
)
(
  input clkin,
  input signed [DATA_WIDTH-1:0] LeftOperand,
  input signed [DATA_WIDTH-1:0] RightOperand,
  input data_valid,

  input signed [ELTWISE_SCALE_WIDTH-1:0] LeftOperand_Scale,
  input signed [ELTWISE_SCALE_WIDTH-1:0] RightOperand_Scale,
  
  input [ELTWISE_ZEROPOINT_WIDTH-1:0] LeftOperand_zero_point,
  input [ELTWISE_ZEROPOINT_WIDTH-1:0] RightOperand_zero_point,

  input [ELTWISE_TYPE_WIDTH-1:0] EltWise_type,
  output signed [DATA_WIDTH_OB-1:0] EltWise_out,  //  32-bit output
  output reg EltWise_valid
);

localparam SHIFT_BITS = 16; //SCALE_WIDTH: Todo: Replace with ELTWISE_SCALE_WIDTH after change in the Instructions file
// Shift the operands by their respective zero points
// This is to ensure that the inputs are centered around zero before scaling
reg signed [DATA_WIDTH-1:0] LeftOperand_shifted;
reg signed [DATA_WIDTH-1:0] RightOperand_shifted;
reg data_valid_shifted;
always @(posedge clkin) begin
  if (data_valid) begin
    LeftOperand_shifted   <= (LeftOperand - LeftOperand_zero_point);
    RightOperand_shifted  <= (RightOperand - RightOperand_zero_point);
    data_valid_shifted    <= 1'b1;
  end else begin
    data_valid_shifted <= 1'b0;
  end
end

// Multiply the shifted operands with their respective scales
reg signed [(SHIFT_BITS+DATA_WIDTH)-1:0] LeftOperand_scaled;
reg signed [(SHIFT_BITS+DATA_WIDTH)-1:0] RightOperand_scaled;
reg data_valid_scaled;
always @(posedge clkin) begin
  if (data_valid_shifted) begin
    LeftOperand_scaled   <= $signed(LeftOperand_shifted) * $signed(LeftOperand_Scale[SHIFT_BITS-1:0]); // For Testing only - Should be removed after changes in Inst. fields
    RightOperand_scaled  <= $signed(RightOperand_shifted) * $signed(RightOperand_Scale[SHIFT_BITS-1:0]);
    data_valid_scaled    <= 1'b1;
  end else begin
    data_valid_scaled <= 1'b0;
  end
end

// Perform element-wise operation based on the specified type
// reg [2*ELTWISE_SCALE_WIDTH-1:0] r_EltWise_out;
reg [2*(SHIFT_BITS+DATA_WIDTH)-1:0] r_EltWise_out;
always @(posedge clkin) 
begin
  if (data_valid_scaled) 
  begin
    case (EltWise_type)
      `ELTWISE_ADD  : r_EltWise_out <= LeftOperand_scaled + RightOperand_scaled;  // Addition
      `ELTWISE_SUB  : r_EltWise_out <= LeftOperand_scaled - RightOperand_scaled;  // Subtraction
      `ifdef ELTWISE_MULT_HW
        `ELTWISE_MULT : r_EltWise_out <= LeftOperand_scaled * RightOperand_scaled;  // Multiplication (signed)
      `endif
      default: r_EltWise_out <= 0;  // Default case to handle unexpected values
    endcase
    EltWise_valid <= 1;
  end 
  else 
  begin
    EltWise_valid <= 0;
  end
end

assign EltWise_out = {r_EltWise_out[2*(SHIFT_BITS+DATA_WIDTH)-1], r_EltWise_out[DATA_WIDTH_OB-2:0]}; // Assign the lower 32 bits of the result to output

endmodule
