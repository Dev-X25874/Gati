
module element_wise_op#(
  parameter DATA_WIDTH=8,
  parameter ELTWISE_TYPE_WIDTH=4,
  parameter ELTWISE_ADD = 0,
  parameter ELTWISE_SUB = 1,
  parameter ELTWISE_MULT = 2,
  parameter DATA_WIDTH_OB = 32
)
(
  input clkin,
  input signed [DATA_WIDTH-1:0] LeftOperand,
  input signed [DATA_WIDTH-1:0] RightOperand,
  input data_out_valid,
  input [ELTWISE_TYPE_WIDTH-1:0] EltWise_type,
  output reg signed [DATA_WIDTH_OB-1:0] EltWise_out,  //  32-bit output
  output reg EltWise_valid
);

always @(posedge clkin) 
begin
  if (data_out_valid) 
  begin
    case (EltWise_type)
      ELTWISE_ADD  : EltWise_out <= LeftOperand + RightOperand;  // Addition
      ELTWISE_SUB  : EltWise_out <= LeftOperand - RightOperand;  // Subtraction
      ELTWISE_MULT : EltWise_out <= LeftOperand * RightOperand;  // Multiplication (signed)
      default: EltWise_out <= 0;  // Default case to handle unexpected values
    endcase
    EltWise_valid <= 1;
  end 
  else 
  begin
    EltWise_valid <= 0;
  end
end

endmodule
