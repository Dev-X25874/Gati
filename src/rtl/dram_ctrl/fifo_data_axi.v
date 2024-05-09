module fifo_data_axi(
    input clkin,
    input memory_acknowledgement,
    input [7:0]burst_length,
    output reg last,
    output reg read_enable
  );
  reg [10:0]count=0;
  reg [3:0]state=0;
  always @(posedge clkin)
  begin
    case(state)
      4'd0:
      begin
        last<=0;
        if(memory_acknowledgement)begin
            state<=1;
            count<=burst_length+1;
        end
        else begin
            count<=burst_length+1;
            state<=0;
        end
      end
      4'd1:begin
        count<=count-1;
        if(count>0)begin
            state<=1;
            read_enable<=1;
        end
        else begin
            state<=0;
            read_enable<=0;
        end
        if(count==1)begin
            last<=1;
        end
        else begin
            last<=0;
        end
      end
    endcase
  end

endmodule
