//////////////////////////////////////////////////////////////////////////////////
// Design Name: Config Block
// Module Name: Controller Instruction Queue
// Project Name: Gati
// Description:Takes instruction data from DRAM memory and checks its validity before passing to Instruction Queue 
//////////////////////////////////////////////////////////////////////////////////
module controller_inst_q #(
  parameter INSTRUCT_W=256,
  parameter ADDR_W=32
)(
    input clkin,
    input valid,
    input sel,
    input user_start,
    input [INSTRUCT_W-1:0]i_instruction_data,
    output reg [INSTRUCT_W-1:0]o_instruction,
    output reg o_instruction_valid, //also used as address valid
    output [ADDR_W-1:0]o_global_start,
    output [ADDR_W-1:0]o_global_stop
  );
  reg [3:0]state=0;
  reg [ADDR_W-1:0]internal_start;
  reg [ADDR_W-1:0]internal_stop;
  always@(posedge clkin)
  begin
    case(state)
      4'd0:
      begin
        if(user_start)
        begin
          state<=1;
        end
        else
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
      end
      4'd1:
      begin
        if(sel && valid) 
        begin
            internal_start<=i_instruction_data[ADDR_W-1:0];
            internal_stop<=i_instruction_data[2*ADDR_W-1:ADDR_W];
            o_instruction_valid<=1;
            state<=0;
        end
        else
        begin
          o_instruction_valid<=0; //set valid to 0
        end
      end
    endcase

  end
  assign o_global_start=internal_start;
  assign o_global_stop=internal_stop;

  endmodule
