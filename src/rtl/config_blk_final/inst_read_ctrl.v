module inst_read_ctrl(
    input clkin,
    //input [3:0]opcode,//from busmaster
    //input [7:0]prev_sent_reg,//from status reg(i think)
    input status_inst_q,//status of I.Q
    input user_start,//not sure what it does yet
    input done_status,

    ////set next status reg
    //output reg [3:0]ack_set_status,//set ack reg 1
    output read_signal// read IQ
    //output reg start_signal_inst,//for status
    //output reg bus_master_valid //for bus master idc
  );
  reg read_signal_reg;
  reg [3:0]top_state=4'd0;
  
  //reg [7:0]prev_sent;
  //reg [7:0]next_sent=8'b0;

  always @(posedge clkin)
  begin
    case(top_state)
    4'd0:begin
      if(user_start)begin
        top_state<=4'd1;//shift to nonidle state
      end
      else
        top_state<=4'd0;
    end
    4'd1:begin
      if(status_inst_q)
    begin
      if(done_status)
      begin
        read_signal_reg<=1'b1;
      end
      else
      begin
        read_signal_reg<=1'b0;
      end
    end
    end    
    endcase
  end
  assign read_signal=read_signal_reg;
  //assign next_status_reg=next_sent;

endmodule
