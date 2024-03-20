module status_reg#(
    parameter inst_num=8'd4
  )(
    input clkin,
    input [3:0]opcode,//from busmaster

    input [7:0]prev_in,//from ctrlack
    input [inst_num-1:0]ack_in,//from ctrlack
    input [3:0]valid_ack,//from ctrlack valid signal
    input opcode_valid,
    //input [5:0]total_layer,//from top

    //input [7:0]next_reg_update,//from inst_red_ctrl to set next as 01
    //input [3:0]ack_set, //from inst_read_ctrl for setting ack 1
    //input start_signal,//from bus master //actually from isnt ctrl after opcode 1111(mar 16)

    output [7:0]prev_out,
    output [inst_num-1:0]ack_sig,
    output [7:0]next_out,
    output reg bus_master_valid
  );
  //reg [5:0]layer_number=6'd0;
  reg [(inst_num<<1)-1:0]prev_sent=0;// [7:0] prev_sent
  reg [(inst_num<<1)-1:0]next_sent=0;// [7:0] next_sent
  reg [inst_num-1:0]ack_reg=0;
  reg [3:0]statelayer=4'd0;
  reg [3:0]new_state=4'd0;
  reg [3:0]state0=4'd0;
  reg [3:0]state1=4'd0;
  reg [3:0]state2=4'd0;
  reg [3:0]state3=4'd0;
  reg [3:0]state4=4'd0;

  // opcode 0,1,2,3 for respective registers in prev next
  always @(posedge clkin)
  begin
    //resetting ack based on ctrl ackz

    if(valid_ack[0])
    begin
      prev_sent[1:0]<=prev_in[1:0]; // makes prev 11
      ack_reg[0]<=ack_in[0]; // makes ack 0
    end
    if(valid_ack[1])
    begin
      prev_sent[3:2]<=prev_in[3:2];
      ack_reg[1]<=ack_in[1];
    end

    if(valid_ack[2])
    begin
      prev_sent[5:4]<=prev_in[5:4];
      ack_reg[2]<=ack_in[2];
    end

    if(valid_ack[3])
    begin
      prev_sent[7:6]<=prev_in[7:6];
      ack_reg[3]<=ack_in[3];
    end

    if(opcode_valid)
    begin
      if(opcode==4'd0)
      begin
        //ack_set_status[0]<=1'b1;
        case(state0)
          4'b0:
          begin
            if(prev_sent[1:0]==2'b00)
            begin
              state0<=1;
              bus_master_valid<=1'b0;
            end
            else if(prev_sent[1:0]==2'b01)
            begin
              state0<=2;
              bus_master_valid<=1'b0;
            end
            else if(prev_sent[1:0]==2'b11)
            begin
              state0<=3;
              bus_master_valid<=1'b0;
            end
          end
          4'd1:
          begin
            next_sent[1:0]<=2'b01;
            bus_master_valid<=1'b1;//send to bus to give green light to bus_master
            state0<=4'd0;
          end
          4'd2:
          begin
            if(prev_sent[1:0]==2'b11)
            begin
              state0<=3;
            end
            else
              state0<=2;
          end
          4'd3:
          begin
            next_sent[1:0]<=2'b01;
            bus_master_valid<=1'b1;
            state0<=4'd0;
          end

        endcase
      end
      /* else
      begin
        ack_set_status[0]=1'b0;
      end */
      if(opcode==4'd1)
      begin
        //ack_set_status[1]<=1'b1;
        case(state2)
          4'b0:
          begin
            if(prev_sent[3:2]==2'b00)
            begin
              state2<=1;
              bus_master_valid<=1'b0;
            end
            else if(prev_sent[3:2]==2'b01)
            begin
              state2<=2;
              bus_master_valid<=1'b0;
            end
            else if(prev_sent[3:2]==2'b11)
            begin
              state2<=3;
              bus_master_valid<=1'b0;
            end
          end
          4'd1:
          begin
            next_sent[3:2]<=2'b01;
            bus_master_valid<=1'b1;
            state2<=4'd0;
          end
          4'd2:
          begin
            if(prev_sent[3:2]==2'b11)
            begin
              state2<=3;
            end
            else
              state2<=2;
          end
          4'd3:
          begin
            next_sent[3:2]<=2'b01;
            bus_master_valid<=1'b1;
            state2<=4'd0;
          end

        endcase
      end
      /* else
      begin
        ack_set_status[1]=1'b0;
      end */
      if(opcode==4'd2)
      begin
        //ack_set_status[2]<=1'b1;
        case(state3)
          4'b0:
          begin
            if(prev_sent[5:4]==2'b00)
            begin
              state3<=1;
              bus_master_valid<=1'b0;
            end
            else if(prev_sent[5:4]==2'b01)
            begin
              state3<=2;
              bus_master_valid<=1'b0;
            end
            else if(prev_sent[5:4]==2'b11)
            begin
              state3<=3;
              bus_master_valid<=1'b0;
            end
          end
          4'd1:
          begin
            next_sent[5:4]<=2'b01;
            bus_master_valid<=1'b1;
            state3<=4'd0;
          end
          4'd2:
          begin
            if(prev_sent[5:4]==2'b11)
            begin
              state3<=3;
            end
            else
              state3<=2;
          end
          4'd3:
          begin
            next_sent[5:4]<=2'b01;
            bus_master_valid<=1'b1;
            state3<=4'd0;
          end

        endcase
      end
      /* else
      begin
        ack_set_status[2]=1'b0;
      end */
      if(opcode==4'd3)
      begin
        //ack_set_status[3]<=1'b1;
        case(state4)
          4'b0:
          begin
            if(prev_sent[7:6]==2'b00)
            begin
              state4<=1;
              bus_master_valid<=1'b0;
            end
            else if(prev_sent[7:6]==2'b01)
            begin
              state4<=2;
              bus_master_valid<=1'b0;
            end
            else if(prev_sent[7:6]==2'b11)
            begin
              state4<=3;
              bus_master_valid<=1'b0;
            end
          end
          4'd1:
          begin
            next_sent[7:6]<=2'b01;
            bus_master_valid<=1'b1;
            state4<=4'd0;
          end
          4'd2:
          begin
            if(prev_sent[7:6]==2'b11)
            begin
              state4<=3;
            end
            else
              state4<=2;
          end
          4'd3:
          begin
            next_sent[7:6]<=2'b01;
            bus_master_valid<=1'b1;
            state4<=4'd0;
          end
        endcase

      end
      if(opcode==4'b1111)
      begin
        if(ack_reg==4'b0000)
        begin
          prev_sent<=next_sent;
          bus_master_valid<=1'b1;
          if(next_sent[1:0]==2'b01)
          begin
            ack_reg[0]<=1'b1;
          end
          if(next_sent[3:2]==2'b01)
          begin
            ack_reg[1]<=1'b1;
          end
          if(next_sent[5:4]==2'b01)
          begin
            ack_reg[2]<=1'b1;
          end
          if(next_sent[7:6]==2'b01)
          begin
            ack_reg[3]<=1'b1;
          end
        end
        else
        begin
          bus_master_valid<=1'b0;
        end
      end
    end
  end
  assign ack_sig=ack_reg;
  assign prev_out=prev_sent;
  assign next_out=next_sent;
endmodule
