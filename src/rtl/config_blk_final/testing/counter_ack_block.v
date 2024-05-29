//////////////////////////////////////////////////////////////////////////////////
// Design Name: Config Block
// Module Name: Counter Acknowledgement Block
// Project Name: Gati
// Description: Acts as fake slave for testing ack block in config block by relaying acknowledgement signal after receiving start signal after a 
// delay. 
//////////////////////////////////////////////////////////////////////////////////
//
module counter_ack_block #(
    parameter NUM_INSTRUCTIONS=4
  )(
    input clkin,
    input [NUM_INSTRUCTIONS-1:0]trigger_start,
    output reg [NUM_INSTRUCTIONS-1:0] ack_signals
  );
  genvar i;
  genvar l;
  reg [7:0]counter[NUM_INSTRUCTIONS-1:0];
  reg [3:0]state=0;
  reg [3:0]sub_state[NUM_INSTRUCTIONS-1:0];

  generate
  for(l=0;l<NUM_INSTRUCTIONS;l=l+1)
  begin
    initial begin
    sub_state[l]=0;
    counter[l]=0;
    end
  end
  endgenerate

  generate
    for(i=0;i<NUM_INSTRUCTIONS;i=i+1)
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
