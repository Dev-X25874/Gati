//Acts as fake slave for testing ack block in config block
module counter_ack_block #(
    parameter num_instructions=4
  )(
    input clkin,
    input [num_instructions-1:0]trigger_start,
    output reg [num_instructions-1:0] ack_signals
  );
  genvar i;
  genvar l;
  reg [7:0]counter[num_instructions-1:0];
  reg [3:0]state=0;
  reg [3:0]sub_state[num_instructions-1:0];

  generate
  for(l=0;l<num_instructions;l=l+1)
  begin
    initial begin
    sub_state[l]=0;
    counter[l]=0;
    end
  end
  endgenerate

  generate
    for(i=0;i<num_instructions;i=i+1)
    begin
      always @(posedge clkin)
      begin

        if(trigger_start[i])
        begin
          sub_state[i]<=4'd1;
        end
        case(sub_state[i])
          4'd0:
          begin
            ack_signals[i]<=0;
          end
          4'd1:
          begin
            if(counter[i]<(i+5)*10)
            begin
              counter[i]=counter[i]+1;
            end
            else
            begin
              sub_state[i]<=4'd2;
              ack_signals[i]<=1'b1;
            end
          end
          4'd2:
          begin
            ack_signals[i]<=1'b0;
            sub_state[i]<=4'd0;
            counter[i]<=0;
          end
        endcase
      end
    end
  endgenerate
endmodule
