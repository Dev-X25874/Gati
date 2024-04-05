module ctrl_dram_req #(
    parameter  addr_w=32,
    parameter burst_len_width=8
  )(
    input clkin,
    input user_start,
    input status,
    input [31:0] global_reg_address_start,
    input [31:0] global_reg_address_stop,
    output read_req,
    output valid,
    output [7:0]o_address,
    output last,
    output [burst_len_width-1:0]burst_len
  );
  reg[5:0] counter1=0;
  reg [7:0] o_address_reg=0;
  reg dv;
  reg read_req_reg;
  reg last_reg=0;
  reg [burst_len_width-1:0]burst_len_reg=0;
  reg [3:0]state=0;
  reg [31:0]internal_reg_start=0;
  reg [31:0]internal_reg_stop=0;

  always @(posedge clkin)
  begin
    case(state)
      4'd0:
      begin
        if(user_start)
        begin
          state<=1;
          internal_reg_start<=global_reg_address_start;
          internal_reg_stop<=global_reg_address_stop;
        end
        else
          state<=0;

      end
      4'd1:
      begin
        //idle state
        if(~status)
        begin
          read_req_reg<=1'b0;
          dv<=1'b0;
          o_address_reg<=0;
          last_reg<=0;
          burst_len_reg<=0;
          state<=4'd1;
        end
        else
          state<=4'd2;
      end
      4'd2:
      begin
        //send address to mem controller in 8bits with required signals
          o_address_reg<=internal_reg_start[addr_w-counter1-1-:8];
          counter1<=counter1+8;
          dv<=1'b1;
          if(counter1==0)
          begin
            read_req_reg<=1'b1;
          end
          else
          begin
            read_req_reg<=1'b0;
          end
          burst_len_reg<=7'd7;
          if(counter1==24)
          begin
            last_reg<=1'b1;
          end
          else
          begin
            last_reg<=1'b0;
          end

          if(counter1<32)
          begin
            state<=4'd2;
          end
          else
          begin
            state<=4'd3;
            dv<=1'b0;
            read_req_reg<=1'b0;
            last_reg<=1'b0;
            o_address_reg<=8'd0;
            counter1<=6'd0;
          end
        end
      4'd3:
      begin
        if(((internal_reg_stop-32'h200)>internal_reg_start))//((burst_len+1)<<5))>internal_reg_start)) //changed burst_len =>burst_len+1
        begin
          if(status)
          begin
            internal_reg_start<=internal_reg_start+32'h200;   //+//32'h10000; //((burst_len_reg+1)<<5);//for testing
            state<=4'd2;
          end
          else
          begin
            internal_reg_start<=internal_reg_start+32'h200;   //+//32'h10000; //((burst_len_reg+1)<<5);//for testing
            state<=4'd1;
          end
        end
        else
        begin
          burst_len_reg<=(global_reg_address_stop-internal_reg_start)>>5;
          state<=4'd5;
        end
      end
      4'd4:
      begin
        state<=4'd0;
        read_req_reg<=1'b0;
        dv<=1'b0;
        o_address_reg<=0;
        last_reg<=0;
        burst_len_reg<=0;
      end
      4'd5:
      begin
        //o_address_reg<=internal_reg_stop[addr_w-counter1-1-:8];
        /* counter1<=counter1+8;
        dv<=1'b1;
        read_req_reg<=1'b1;
        if(counter1==24)
        begin
          last_reg<=1'b1;
        end
        else
        begin
          last_reg<=1'b0;
        end

        if(counter1<32)
        begin
          state<=4'd5;
        end
        else
        begin */
        internal_reg_start<=internal_reg_stop;
        state<=4'd4;
        dv<=1'b0;
        read_req_reg<=1'b0;
        last_reg<=1'b0;
        o_address_reg<=8'd0;
        burst_len_reg<=8'd0;
        counter1<=6'd0;
        //end
      end
      default:
      begin
        read_req_reg<=1'b0;
        dv<=1'b0;
        o_address_reg<=0;
        last_reg<=0;
        burst_len_reg<=0;
        state<=0;
      end
    endcase
  end
  assign burst_len=burst_len_reg;
  assign last= last_reg;
  assign o_address=o_address_reg;
  assign valid=dv;
  assign read_req=read_req_reg;
endmodule
