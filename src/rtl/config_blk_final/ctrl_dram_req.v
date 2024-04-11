//////////////////////////////////////////////////////////////////////////////////
// Design Name: Config Block
// Module Name: DRAM controller
// Project Name: Gati
// Description:ResponsibLe for sending memory address and read requests to DRAM memory. 
//Is triggered by external user start
//////////////////////////////////////////////////////////////////////////////////
//
module ctrl_dram_req #(
    parameter  ADDR_W=32,
    parameter BURST_LEN_AXI =7 
  )(
    input clkin,
    input user_start, //External trigger to move from IDLE state to NONIDLE state
    input status, //status of instruction queue
    input [ADDR_W-1:0] global_reg_address_start, //start address
    input [ADDR_W-1:0] global_reg_address_stop, //stop address
    output read_req, //read req for dram
    output valid, //valid signal
    output [7:0]o_address, //8 bit chunks of address
    output last, //last chunk of 8 bits
    output [$clog2(BURST_LEN_AXI):0]burst_len //burst length for dram
  );
  reg[5:0] counter1=0;
  reg [7:0] o_address_reg=0;
  reg dv;
  reg read_req_reg;
  reg last_reg=0;
  reg [$clog2(BURST_LEN_AXI):0]burst_len_reg=0;
  reg [3:0]state=0;
  reg [ADDR_W-1:0]internal_reg_start=0;
  reg [ADDR_W-1:0]internal_reg_stop=0;

  always @(posedge clkin)
  begin
    case(state)
      4'd0:
      begin
        if(user_start) //shift from sleep state to idle i.e state =1
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
        if(~status) //check status of instruction queue
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
          o_address_reg<=internal_reg_start[ADDR_W-counter1-1-:8];
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
          burst_len_reg<=BURST_LEN_AXI;
          if(counter1==24)
          begin
            last_reg<=1'b1;
          end
          else
          begin
            last_reg<=1'b0;
          end

          if(counter1<ADDR_W)
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
        if(((internal_reg_stop-((burst_len+1)<<5))>internal_reg_start)) //changed burst_len =>burst_len+1//32'h200)>internal_reg_start))//
        begin
          if(status)
          begin
            internal_reg_start<=internal_reg_start+((burst_len_reg+1)<<5);//for testing 32'h200;   //+//32'h10000; // update internal reg
            state<=4'd2;
          end
          else
          begin
            internal_reg_start<=internal_reg_start+((burst_len_reg+1)<<5);//for testing 32'h200;   //+//32'h10000; // update internal reg
            state<=4'd1; //Back to check status of instruction queue
          end
        end
        else
        begin
          burst_len_reg<=((global_reg_address_stop-internal_reg_start)>>5);
          state<=4'd5;
        end
      end
      4'd4://reached stop address
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
        internal_reg_start<=internal_reg_stop;
        state<=4'd4;
        dv<=1'b0;
        read_req_reg<=1'b0;
        last_reg<=1'b0;
        o_address_reg<=0;
        burst_len_reg<=0;
        counter1<=6'd0;
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
