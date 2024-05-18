//this module adds the outputs coming from 2 consecutive engines

module adder #(
    parameter WIDTH   = 20
  , parameter O_WIDTH = 20
) (
  input clk,
  input rst,
  input valid_in_1,
  input valid_in_2,
  input [WIDTH-1:0] first_k,  //FIRST INPUT
  input [WIDTH-1:0] second_k, //SECOND INPUT
  output reg valid = 0,
  output reg [O_WIDTH-1 : 0] result = 0
);
reg [1:0] state = 0;

always @(posedge clk) begin
  if (~rst) begin
    result <= 0;
    valid  <= 1'b0;
  end 
  else begin
    if (valid_in_1 & valid_in_2) begin  //WHEN BOTH INP VALIDS ARE 1
      result <= first_k + second_k;  //SIMPLE ADDITION OPERATION
      valid  <= 1'b1;
    end else begin
      result <= result;
      valid  <= 1'b0;
    end
  end
end
endmodule