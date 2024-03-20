module bus_master_fake(
    input clkin,
    input [255:0]instruction_from_q,
    //input start_trigger,//when one send latched instruction to blocks in 8 bits
    input bus_master_valid,//from status reg
    output done_status,
    output reg ack_im2col,
    output reg ack_im2col_valid,
    output reg ack_tail,
    output reg ack_tail_valid,
    output reg [3:0]opcode,
    output reg opcode_valid,
    output reg start_blocks
  );
  reg done_status_reg=1'b1;
  reg [255:0]latched_instruction;
  reg [29:0]counter=30'd0;
  reg [3:0]state1=4'd0;
  always @(posedge clkin)
  begin
    case(state1)
      4'd0:
      begin
        if(instruction_from_q==256'd123456)
        begin
          state1<=4'd1;
          //start_signal<=1'b0;
          latched_instruction<=instruction_from_q;
          ack_im2col<=1'b0;
          ack_im2col_valid=1'b0;
          done_status_reg<=1'b1;
          start_blocks<=1'b0;
        end
        else if (instruction_from_q==256'd234567)
        begin
          latched_instruction<=instruction_from_q;
          ack_tail<=1'b0;
          ack_tail_valid=1'b0;
          done_status_reg<=1'b1;
          state1<=4'd1;
        end
        else if (instruction_from_q==256'd111111)
        begin
          latched_instruction<=instruction_from_q;
          /* ack_tail<=1'b0;
          ack_tail_valid=1'b0; */
          done_status_reg<=1'b1;
          state1<=4'd1;
        end
        else
          state1<=4'd0;
      end
      4'd1:
      begin
        if(counter<30'd50)
        begin
          opcode_valid=1'b0;
          counter<=counter+1;
          done_status_reg<=1'b0;
          case(latched_instruction)
            256'd123456:
              opcode<=4'd0;
            256'd234567:
              opcode<=4'd1;
            256'd111111:
              opcode<=4'b1111;
          endcase
        end
        else
        begin
          state1<=4'd2;
          opcode_valid=1'b1;
        end
      end
      4'd2:begin
        if(bus_master_valid)begin
          opcode_valid=1'b0;
          counter<=30'd0;
          done_status_reg<=1'b1;
          state1<=1'b0;

          case(latched_instruction)
            256'd123456:
            begin
              ack_im2col<=1'b1;
              ack_im2col_valid=1'b1;
            end
            256'd234567:
            begin
              ack_tail<=1'b1;
              ack_tail_valid=1'b1;
            end
            256'd111111:
            begin
              start_blocks<=1'b1;
            end
          endcase
        end
        else
          begin
            state1<=4'd2;
            done_status_reg<=1'b0;
            ack_tail<=1'b0;
            ack_tail_valid=1'b0;
            ack_im2col<=1'b0;
            ack_im2col_valid=1'b0;
            start_blocks<=1'b0;
            opcode_valid=1'b1;
          end
      end
    endcase
  end
  assign done_status=done_status_reg;
endmodule
