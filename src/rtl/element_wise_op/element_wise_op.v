//`include "operation_calc.v"
module element_wise_op#(
    parameter INPUT_WIDTH=16,
    parameter NUMBER_OP=3
  )
  (
    input clkin,
    input [INPUT_WIDTH-1:0]input_a,
    input input_a_v,
    input [INPUT_WIDTH-1:0]input_b,
    input input_b_v,
    input [$clog2(NUMBER_OP)-1:0]operation_in,
    input operation_v,
    output [(INPUT_WIDTH<<1)-1:0]value_out,
    output value_valid,
    output [$clog2(INPUT_WIDTH)+1:0]value_width,
    output [(INPUT_WIDTH>>2)-1:0]value_strobe
  );

  reg [INPUT_WIDTH-1:0]input_a_reg;
  reg [INPUT_WIDTH-1:0]input_b_reg;
  reg [$clog2(NUMBER_OP)-1:0]operation_in_reg;
  reg [3:0]state=0;
  //reg valid_sign_a;
  //reg valid_sign_b;
  //reg valid_sign_out;
  reg calculate;

  operation_calc #(.INPUT_WIDTH(INPUT_WIDTH),.NUMBER_OP(NUMBER_OP))inst1(
                   .input_a(input_a_reg),
                   .input_b(input_b_reg),
                   .calculate(calculate),
                   .op_number(operation_in_reg),
                   .value_out(value_out),
                   .value_width(value_width),
                   .value_valid(value_valid),
                   .value_strobe(value_strobe)
                 );

  always @(posedge clkin)
  begin
    if(input_a_v)
    begin
      input_a_reg<=input_a;
      //valid_sign_a<=1;
    end
    if(input_b_v)
    begin
      input_b_reg<=input_b;
      //valid_sign_b<=1;
    end

    if(operation_v)
    begin
      operation_in_reg<=operation_in;
      //valid_sign_out<=1;
    end

    if(input_a_v && input_b_v && operation_v)begin
      calculate<=1;
    end
    else begin
      calculate<=0;
    end

  end
endmodule
