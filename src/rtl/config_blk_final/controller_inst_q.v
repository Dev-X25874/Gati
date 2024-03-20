module controller_inst_q(
    input clkin,
    input valid,
    input sel,
    input [255:0]i_instruction_data,
    output reg [255:0]o_instruction,
    output reg o_instruction_valid
  );
  reg [255:0]internal_reg=0;
  always@(posedge clkin)
  begin
    if(sel)
    begin
      if(valid)
      begin
//        internal_reg<=i_instruction_data;
        o_instruction<=i_instruction_data;
        o_instruction_valid<=1;
      end
      else
        begin
          o_instruction_valid<=0;
        end
    end
    else
      begin
        o_instruction_valid<=0;
        o_instruction<=256'd0;
      end
  end
  endmodule
