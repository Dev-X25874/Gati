module inst_read_ctrl#(
    parameter  num_instructions=4
  )(
    input clkin,
    input [num_instructions-1:0]valid_ack,
    input [(num_instructions*2)-1:0]prev_in,
    input [num_instructions-1:0]ack_in,
    input [11:0]layer_number,
    input [11:0]total_layers,
    input status_inst_q,
    input user_start,
    input done_status,
    input [3:0]opcode,
    output reg bus_master_valid,
    output reg [num_instructions-1:0] start_command,
    output read_signal
  );

  integer i;
  integer k;
  reg read_signal_reg=1'b0;
  reg [3:0]top_state=4'd0;
  reg [3:0]state0=4'd0;
  reg [1:0] counter=2;
  reg [4:0]r_opcode=0;
  reg [3:0]super_state=4'd0;
  reg [3:0]state_start=4'd0;
  reg flag=1;
  //reg [7:0]prev_reg;
  //reg [7:0]next_sent=8'b0;

  reg [(num_instructions*2)-1:0]prev_reg=0;
  reg [(num_instructions*2)-1:0]next_reg=0;
  reg [num_instructions-1:0]ack_reg=0;
  reg [num_instructions-1:0]psedo_ack_reg=0;
  reg [num_instructions-1:0]valid_ack_reg=0;

  always @(posedge clkin)
  begin
    case(super_state)
      4'd0:
      begin
        if((layer_number==total_layers)&&(opcode==4'b1111))
        begin
          super_state<=4'd1;
        end
        valid_ack_reg<=valid_ack;
        if(valid_ack_reg!=4'd0)
        begin
          for(i=0;i<num_instructions;i=i+1)
          begin
            if(valid_ack_reg[i])
            begin
              prev_reg[(2*i)+:2]<=prev_in[(2*i)+:2];
              ack_reg[i]<=ack_in[i];
            end

          end
        end
        else
        begin
          case(top_state)
            4'd0:
            begin
              if(user_start)
              begin
                top_state<=4'd1;//shift to nonidle state
              end
              else
                top_state<=4'd0;
            end
            4'd1:
            begin

              if((status_inst_q && done_status)| (flag&&status_inst_q))
              begin
                read_signal_reg<=1'b1;
                flag<=0;
                top_state=4'd2;
              end
              else
              begin
                top_state<=4'd1;
                read_signal_reg<=1'b0;
              end
            end
            4'd2:
            begin
              read_signal_reg<=1'b0;
              top_state<=4'd3;
            end
            4'd3:
            begin
              r_opcode<=opcode;
              top_state<=4'd4;
            end
            4'd4:
            begin
              //r_opcode<=opcode;
              if(r_opcode!=4'b1111)
              begin
                case(state0)
                  4'b0:
                  begin
                    if(prev_reg[((r_opcode<<1)+1)-:2]==2'b00)
                    begin
                      state0<=1;
                    end
                    else if(prev_reg[((r_opcode<<1)+1)-:2]==2'b01)
                    begin
                      state0<=2;
                    end
                    else if(prev_reg[((r_opcode<<1)+1)-:2]==2'b11)
                    begin
                      state0<=3;
                    end
                  end
                  4'd1:
                  begin
                    next_reg[((r_opcode<<1)+1)-:2]<=2'b01;
                    psedo_ack_reg[r_opcode]<=1'b1;
                    bus_master_valid<=1'b1;//send to bus to give green light to bus_master
                    counter<=counter-1;
                    if(counter==0)
                    begin
                      top_state=4'd1;
                      bus_master_valid<=1'b0;
                      counter<=2;
                      state0<=4'd0;
                    end
                  end
                  4'd2:
                  begin
                    if(prev_reg[((r_opcode<<1)+1)-:2]==2'b11)
                    begin
                      state0<=3;
                    end
                    else
                      state0<=2;
                  end
                  4'd3:
                  begin
                    next_reg[((r_opcode<<1)+1)-:2]<=2'b01;
                    psedo_ack_reg[r_opcode]<=1'b1;
                    bus_master_valid<=1'b1;
                    counter<=counter-1;
                    if(counter==0)
                    begin
                      top_state=4'd1;
                      counter<=2;
                      bus_master_valid<=1'b0;
                      state0<=4'd0;
                    end
                  end
                endcase

              end
              if(r_opcode==5'b01111)
              begin
                if(ack_reg==4'd0)
                begin
                  ack_reg<=psedo_ack_reg;
                  prev_reg<=next_reg;
                  next_reg<=8'd0;
                  state_start<=4'd1;
                end
                case(state_start)
                  4'd0:
                  begin
                    read_signal_reg<=1'b0;
                    bus_master_valid<=1'b0;
                  end
                  4'd1:
                  begin
                    start_command<=psedo_ack_reg;
                    read_signal_reg<=1'b1;
                    state_start<=4'd2;
                    bus_master_valid<=1'b1;

                  end
                  4'd2:
                  begin
                    start_command<=4'd0;
                    state_start<=4'd0;
                    read_signal_reg<=1'b0;
                    top_state<=4'd3;
                    psedo_ack_reg<=4'd0;
                    bus_master_valid<=1'b0;
                  end
                endcase
              end

            end
          endcase
        end
      end
      4'd1:
      begin
        if(valid_ack_reg!=4'd0)
        begin
          for(k=0;k<num_instructions;k=k+1)
          begin
            if(valid_ack_reg[k])
            begin
              prev_reg[(2*k)+:2]<=prev_in[(2*k)+:2];
              ack_reg[k]<=ack_in[k];
            end

          end
        end
        if(ack_reg==4'b0000)
        begin
          prev_reg<=8'd0;
          next_reg<=8'd0;
          super_state<=4'd0;
          top_state<=4'd0;
          state0<=4'd0;
          psedo_ack_reg<=4'b0;
        end
      end
    endcase
  end
  assign read_signal=read_signal_reg;

endmodule
