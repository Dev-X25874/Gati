// sends acknowledgement signal to instruction read controller block
module ctrl_ack #(
    parameter  num_instructions=4
  )(
    input clkin,
    input [num_instructions-1:0] inst_signals,
    output reg [num_instructions-1:0]status_ack,
    output reg [(2*num_instructions)-1:0]status_prev,
    output reg [num_instructions-1:0]o_valid_sig
  );

  genvar i;
  generate
    for(i=0;i<num_instructions;i=i+1)
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
