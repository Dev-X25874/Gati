//////////////////////////////////////////////////////////////////////////////////
// Design Name: Config Block
// Module Name: Controller Instruction Queue
// Project Name: Gati
// Description:Takes instruction data from DRAM memory and checks its validity before passing to Instruction Queue 
//////////////////////////////////////////////////////////////////////////////////
module controller_inst_q #(
  parameter INSTRUCT_W=256
)(
    input clkin,
    input valid,
    input sel,
    input [INSTRUCT_W-1:0]i_instruction_data,
    output reg [INSTRUCT_W-1:0]o_instruction,
    output reg o_instruction_valid
  );
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
