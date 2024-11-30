//////////////////////////////////////////////////////////////////////////////////
// Design Name: Config Block
// Module Name: Instruction Read Controller
// Project Name: Gati
// Description:
//Responsible for sending read signal to instruction q based on done status of bus master
// Also has 3 registers which show the status of the slave blocks for respective instructions and the next and previous instructions to be executed.
// These are status reg, prev reg and next reg.
//////////////////////////////////////////////////////////////////////////////////
module inst_read_ctrl#(
    parameter  NUM_INSTRUCTIONS=4,
    parameter  OPCODE_W=4,
    parameter LAY_N=12,
    parameter TOTAL_LAY_N=12
  )(
    input clkin,
    input valid_inst,
    input [NUM_INSTRUCTIONS-1:0]valid_ack,
    input [(NUM_INSTRUCTIONS*2)-1:0]prev_in,
    input [NUM_INSTRUCTIONS-1:0]ack_in,
    input [LAY_N-1:0]layer_number, //data from instruction
    input [TOTAL_LAY_N-1:0]total_layers, //data from instruction
    input status_inst_q,
    input user_start,
    input done_status,
    input [OPCODE_W-1:0]opcode, //opcode received from instruction data
    input dispatch_busy,
    output reg bus_master_valid, //valid signal for bus master(start)
    output reg [NUM_INSTRUCTIONS-1:0] start_command, //sends start signal to respective slave blocks
    output reg start_out,//pulses start for one cycle every time we get a start instruction
    output read_signal//read signal for instruction queue
  );
  localparam [OPCODE_W-1:0]ALL_ONES ={OPCODE_W{1'b1}} ;

  integer i;
  integer k;
  reg read_signal_reg=1'b0;
  reg [3:0]top_state=4'd0;
  reg [3:0]state0=4'd0;
  reg [1:0] counter=2;
  reg [OPCODE_W-1:0]r_opcode=0;
  reg [3:0]super_state=4'd0;
  reg [3:0]state_start=4'd0;
  reg [3:0]state_start_2=4'd0;
  reg flag=1; //for the first instruction
  reg flag_2=1; //used to stop loopback from last instruction

  reg [(NUM_INSTRUCTIONS*2)-1:0]prev_reg=0; //shows the previous instructions, is set to 11 by ack block and 01 from next reg
  reg [(NUM_INSTRUCTIONS*2)-1:0]next_reg=0; //shows the next instructions, is set to 01 based on the opcode received
  reg [NUM_INSTRUCTIONS-1:0]ack_reg=0; //shows status of the slave blocks, is 1 if the slave block is busy is 0 if slave block is free/done
  reg [NUM_INSTRUCTIONS-1:0]psedo_ack_reg=0; //interim register
  reg [NUM_INSTRUCTIONS-1:0]valid_ack_reg=0;


reg f1,f2;
always @(*) begin 

	f1<=((layer_number==total_layers)&&(opcode==ALL_ONES))?1:0;
	f2<=((status_inst_q && done_status)| (flag&&status_inst_q))?1:0;

end










  always @(posedge clkin)
  begin
    case(super_state)
      4'd0:
      begin
        //layer_done<=0;
        if(f1) //if conditions match make config block wait for user start again
        begin
          if(flag_2)
          begin
            super_state<=4'd1;
            flag_2<=0;
          end
        end
        valid_ack_reg<=valid_ack;
        if(valid_ack_reg!=4'd0) //acknowledgement signal from Acknowledgement Controller
        begin
          for(i=0;i<NUM_INSTRUCTIONS;i=i+1)
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
                flag_2<=1;
                ack_reg<=0;
                prev_reg<=0;
                flag<=1;
                next_reg<=0;
              end
              else
                top_state<=4'd0;
            end
            4'd1:
            begin

              if(f2) //send read signal
              begin
                read_signal_reg<=1'b1;
                flag<=0;
                top_state<=4'd2;
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
              if(valid_inst) begin
                r_opcode<=opcode; //store opcode
                top_state<=4'd4;
              end
            end
            4'd4:
            begin
              if(r_opcode!=ALL_ONES) //based on opcode and prev_reg  set next reg
              begin
                case(state0)
                  4'd0:
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
              if(r_opcode==ALL_ONES) //if start signal prefetch and wait for ack reg 0
              begin
                case(state_start)
                  4'd0:
                  begin
                    read_signal_reg<=1'b0;
                    bus_master_valid<=1'b0;
                    if((ack_reg==0)&&(~dispatch_busy)) //when dispacter is busy i.e signal one we do not send start signal to slave blocks
                    begin
                      ack_reg<=psedo_ack_reg;
                      prev_reg<=next_reg;
                      next_reg<=8'd0;
                      state_start<=4'd1;
                    end
                  end
                  4'd1:
                  begin
                    start_command<=psedo_ack_reg;
                    start_out<=1;
                    read_signal_reg<=1'b1;
                    state_start<=4'd2;
                    bus_master_valid<=1'b0;

                  end
                  4'd2:
                  begin
                    start_command<=0;
                    start_out<=0;
                    state_start<=4'd0;
                    read_signal_reg<=1'b0;
                    top_state<=4'd3;
                    psedo_ack_reg<=0;
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
        if(valid_ack_reg!=0)
        begin
          for(k=0;k<NUM_INSTRUCTIONS;k=k+1)
          begin
            if(valid_ack_reg[k])
            begin
              prev_reg[(2*k)+:2]<=prev_in[(2*k)+:2];
              ack_reg[k]<=ack_in[k];
            end

          end
        end

        case(state_start_2)
          4'd0:
          begin
            read_signal_reg<=1'b0;
            bus_master_valid<=1'b0;
            if((ack_reg==0)&&(~dispatch_busy))//when dispacter is busy i.e signal one we do not send start signal to slave blocks
            begin
              ack_reg<=psedo_ack_reg;
              prev_reg<=next_reg;
              next_reg<=8'd0;
              state_start_2<=4'd1;
            end
          end
          4'd1:
          begin
            start_command<=psedo_ack_reg;
            start_out<=1;
            state_start_2<=4'd2;
            bus_master_valid<=1'b0;

          end
          4'd2:
          begin
            start_command<=0;
            start_out<=0;
            state_start_2<=4'd0;
            read_signal_reg<=1'b0;
            top_state<=4'd0;
            psedo_ack_reg<=0;
            bus_master_valid<=1'b0;
            super_state<=4'd0;
            state0<=0;
            state_start<=0;
          end
        endcase

      end
    endcase
  end
  assign read_signal=read_signal_reg;

endmodule
