module axi_addr_generator#(
    parameter ADDR_WIDTH=32
  )(
    input clkin,
    input [ADDR_WIDTH-1:0]acc_address,
    input [ADDR_WIDTH-1:0]op_address,
    input acc_address_valid,
    input op_valid,
    input [7:0]burst_len,
    input [7:0]burst_len_2,
    output reg[7:0]chunk_address,
    output reg chunk_valid,
    output reg [7:0]o_burst_len,
    output reg last
  );
  reg [3:0]state=0;
  reg [31:0]internal_address;
  reg [7:0]counter=0;
  always @(posedge clkin)
  begin
    case(state)
      4'd0:
      begin
        if(acc_address_valid)
        begin
          state<=1;
          internal_address<=acc_address;
          o_burst_len<=burst_len;
        end
        else if(op_valid)
        begin
          state<=1;
          internal_address<=op_address;
          o_burst_len<=burst_len_2;
        end
        else
        begin
          state<=0;
        end
        chunk_valid<=0;
      end
      4'd1:
      begin
        chunk_address<=internal_address[ADDR_WIDTH-counter-1-:8];
        counter<=counter+8;
        if(counter==0)
        begin
          chunk_valid<=1'b1;
        end
/*         else
        begin
          chunk_valid<=1'b0;
        end */
        if(counter<ADDR_WIDTH)
        begin
          state<=4'd1;
        end
        else
        begin
          state<=4'd0;
          counter<=0;
        end
        if(counter==24)
        begin
          last<=1'b1;
        end
        else
        begin
          last<=1'b0;
        end

      end
    endcase

  end
endmodule
