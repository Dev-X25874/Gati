module ctrl_ack(
    input clkin,
    input inst_1,
    input inst_2,
    input inst_3,
    input inst_4,
    output reg [3:0]status_ack,
    output reg [7:0]status_prev,
    output reg [3:0]o_valid_sig
);
always@(posedge clkin)begin
    if(inst_1)begin
        status_ack[0]<=0;
        status_prev[1:0]<=2'b11;
        o_valid_sig[0]<=1'b1;
    end
    else
        o_valid_sig[0]<=1'b0;
    if(inst_2)begin
        status_ack[1]<=0;
        status_prev[3:2]<=2'b11;
        o_valid_sig[1]<=1'b1;
    end
    else
        o_valid_sig[1]<=1'b0;
    if(inst_3)begin
        status_ack[2]<=0;
        status_prev[5:4]<=2'b11;
        o_valid_sig[2]<=1'b1;
    end
    else
        o_valid_sig[2]<=1'b0;
    if(inst_4)begin
        status_ack[3]<=0;
        status_prev[7:6]<=2'b11;
        o_valid_sig[3]<=1'b1;
    end
    else
        o_valid_sig[3]<=1'b0;
end
endmodule   