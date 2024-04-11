//////////////////////////////////////////////////////////////////////////////////
// Design Name: Config Block
// Module Name: Acknowledgement COntroller
// Project Name: Gati
// Description:Sends acknowledgement signal to instruction read controller block which
//sets respective previous registers as 11 and sets respective acknowledgement registers as 0
//////////////////////////////////////////////////////////////////////////////////
// 
module ctrl_ack #(
  parameter  NUM_INSTRUCTIONS=4
)(
  input clkin,
  input [NUM_INSTRUCTIONS-1:0] inst_signals,
  output reg [NUM_INSTRUCTIONS-1:0]status_ack,
  output reg [(2*NUM_INSTRUCTIONS)-1:0]status_prev,
  output reg [NUM_INSTRUCTIONS-1:0]o_valid_sig
);

genvar i;
generate
  for(i=0;i<NUM_INSTRUCTIONS;i=i+1)
  begin
    always @(posedge clkin)
    begin
      if(inst_signals[i])
      begin
        status_ack[i]<=0; //set ack as 0
        status_prev[(2*i)+:2]<=2'b11; //set prev 11
        o_valid_sig[i]<=1'b1; //valid signal 1
      end
      else
        o_valid_sig[i]<=1'b0; //valid signal 0
    end
  end
endgenerate

endmodule
