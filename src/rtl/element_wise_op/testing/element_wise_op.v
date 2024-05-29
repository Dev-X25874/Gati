//`include "operation_calc.v"
module element_wise_op#(
    parameter INPUT_WIDTH=16,
    parameter NUMBER_OP=3
  )
  (
    input clkin,
    input signed [INPUT_WIDTH-1:0]input_a,
    input input_a_v,
    input signed [INPUT_WIDTH-1:0]input_b,
    input input_b_v,
    input [$clog2(NUMBER_OP)-1:0]operation_in,
    input operation_v,
    output reg signed [(INPUT_WIDTH<<1)-1:0]value_out,
    output reg value_valid,
    output reg [STROBE_LENGTH-1:0]value_strobe //output reg [(INPUT_WIDTH>>2)-1:0]value_strobe
  );
  localparam STROBE_LENGTH =((INPUT_WIDTH<<1)>>3);

  reg [INPUT_WIDTH-1:0]input_a_reg;
  reg [INPUT_WIDTH-1:0]input_b_reg;
  reg [$clog2(NUMBER_OP)-1:0]operation_in_reg;
  reg [3:0]state=0;
  reg calculate;
  integer i;
  always @(posedge clkin)
  begin
    if(input_a_v && input_b_v && operation_v)
    begin
      case(operation_in)  //(op_number)
        0:
        begin
          value_out<=input_a+input_b;
          for (i = 0; i < (((INPUT_WIDTH+1)>>3)); i = i + 1)
          begin
            value_strobe[i] <= 1'b1;
          end
        end
        1:
        begin
          value_out<=input_a-input_b;
          for (i = 0; i < (((INPUT_WIDTH+1)>>3)); i = i + 1)
          begin
            value_strobe[i] <= 1'b1;
          end
        end
        2:
        begin
          value_out<=input_a*input_b;
          for (i = 0; i < ((INPUT_WIDTH<<1)>>3); i = i + 1)
          begin
            value_strobe[i] <= 1'b1;
          end
        end
      endcase
      value_valid<=1;

    end
    else
    begin
      //calculate<=0;
      value_out<=0;
      value_valid<=0;
      value_strobe<=0;
    end

  end
endmodule
