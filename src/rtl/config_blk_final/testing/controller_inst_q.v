//takes instruction data from DRAM memory and checks it calid signal before passing to instruction queue
module controller_inst_q #(
  parameter instruct_w=256
)(
    input clkin,
    input valid,
    input sel,
    input [instruct_w-1:0]i_instruction_data,
    output reg [instruct_w-1:0]o_instruction,
    output reg o_instruction_valid
  );
  reg [instruct_w-1:0]internal_reg=0;
  always@(posedge clkin)
  begin
    if(sel && valid) //check sel and valid signal for internal data
    begin
        o_instruction<=i_instruction_data;
        o_instruction_valid<=1; //set valid to 1
    end
    else
      begin
        o_instruction_valid<=0; //set valid to 0
      end
  end
  endmodule
