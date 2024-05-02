module chunk_generator(
    input clkin,
    input [31:0]acc_address,
    input [31:0]op_address,
    input acc_address_valid,
    input op_valid,
    output reg[7:0]chunk_address,
    output reg chunk_valid,
    output reg last
  );
  reg [3:0]state=0;
  reg [31:0]internal_address;
  reg [7:0]counter=7;
  always @(posedge clkin)
  begin
    case(state)
      4'd0:
      begin
        if(acc_address_valid)
        begin
          state<=1;
          internal_address<=acc_address;
        end
        else if(op_valid)
        begin
          state<=1;
          internal_address<=op_address;
        end
        else
        begin
          state<=0;
        end
      end
      4'd1:
      begin
        if(counter<40)
        begin
          chunk_address<=internal_address[(counter)-:8];
          counter<=counter+8;
        end
        else
        begin
          counter<=7;
          state<=0;
        end
        if(counter==7)
        begin
          chunk_valid<=1;
        end
        else
        begin
          chunk_valid<=0;
        end
        if(counter==39)begin
            last<=1;
        end
        else begin
            last<=0;
        end
      end
    endcase

  end
endmodule
