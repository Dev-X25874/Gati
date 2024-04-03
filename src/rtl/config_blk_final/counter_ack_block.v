module counter_ack_block(
    input clkin,
    input [3:0]trigger_start,
    output reg ack_conv,
    output reg ack_fc,
    output reg ack_tail,
    output reg ack_op
  );
  reg [7:0]counter_conv=0;
  reg [7:0]counter_fc=0;
  reg [7:0]counter_tail=0;
  reg [7:0]counter_op=0;
  reg [3:0]state=0;
  reg [3:0]sub_state_0=0;
  reg [3:0]sub_state_1=0;
  reg [3:0]sub_state_2=0;
  reg [3:0]sub_state_3=0;
  always @(posedge clkin)
  begin

    if(trigger_start[0])
    begin
      sub_state_0<=4'd1;
    end
    if(trigger_start[1])
    begin
      sub_state_1<=4'd1;
    end
    if(trigger_start[2])
    begin
      sub_state_2<=4'd1;
    end
    if(trigger_start[3])
    begin
      sub_state_3<=4'd1;
    end


    case(sub_state_0)
      4'd0:
      begin
        ack_conv<=0;
      end
      4'd1:
      begin
        if(counter_conv<10'd50)
        begin
          counter_conv=counter_conv+1;
        end
        else
        begin
          sub_state_0<=4'd2;
          ack_conv<=1'b1;
        end
      end
      4'd2:
      begin
        ack_conv<=1'b0;
        sub_state_0<=4'd0;
      end
    endcase

    case(sub_state_1)
      4'd0:
      begin
        ack_fc<=0;
      end
      4'd1:
      begin
        if(counter_fc<10'd50)
        begin
          counter_fc=counter_fc+1;
        end
        else
        begin
          sub_state_1<=4'd2;
          ack_fc<=1'b1;
        end
      end
      4'd2:
      begin
        ack_fc<=1'b0;
        sub_state_1<=4'd0;
      end
    endcase


    case(sub_state_2)
      4'd0:
      begin
        ack_tail<=0;
      end
      4'd1:
      begin
        if(counter_tail<10'd50)
        begin
          counter_tail=counter_tail+1;
        end
        else
        begin
          sub_state_2<=4'd2;
          ack_tail<=1'b1;
        end
      end
      4'd2:
      begin
        ack_tail<=1'b0;
        sub_state_2<=4'd0;
      end
    endcase


    case(sub_state_3)
      4'd0:
      begin
        ack_op<=0;
      end
      4'd1:
      begin
        if(counter_op<10'd50)
        begin
          counter_op=counter_op+1;
        end
        else
        begin
          sub_state_3<=4'd2;
          ack_op<=1'b1;
        end
      end
      4'd2:
      begin
        ack_op<=1'b0;
        sub_state_3<=4'd0;
      end
    endcase


  end
endmodule
