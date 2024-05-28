module operation_calc#(
    parameter INPUT_WIDTH=16,
    parameter NUMBER_OP=3
  )(
    input signed [INPUT_WIDTH-1:0]input_a,
    input signed [INPUT_WIDTH-1:0]input_b,
    input calculate,
    input [$clog2(NUMBER_OP)-1:0]op_number,
    output reg signed [(INPUT_WIDTH<<1)-1:0]value_out,
    output [$clog2(INPUT_WIDTH)+1:0]value_width,
    output reg value_valid,
    output reg [STROBE_LENGTH-1:0]value_strobe
  );
  localparam STROBE_LENGTH =((INPUT_WIDTH<<1)>>3);
  integer i;
  reg [$clog2(INPUT_WIDTH)+1:0]value_width_inter;
  always @(*)
  begin
    if(calculate)
    begin
      case(op_number)
        0:
        begin
          value_out=input_a+input_b;
          value_width_inter=INPUT_WIDTH+1;
        end
        1:
        begin
          value_out=input_a-input_b;
          value_width_inter=INPUT_WIDTH+1;
        end
        2:
        begin
          value_out=input_a*input_b;
          value_width_inter=INPUT_WIDTH<<1;
        end
      endcase
      value_valid=1;
      value_strobe=0;
      for (i = 0; i < ((value_width_inter>>3)); i = i + 1)
      begin
        value_strobe[i] = 1'b1;
      end
    end
    
    else
    begin
      value_out=0;
      value_width_inter=0;
      value_valid=0;
      value_strobe=0;
    end
  end
  assign value_width=value_width_inter;
endmodule
