//make id 32 bit, datasize 2 chunks 16,16, SOF 32 Bit
module mipi_formatter#(
    parameter IDWIDTH=32,
    parameter DATASIZE_WIDTH=32,
    parameter DATA_WIDTH=256,
    parameter MIPI_S=48,
    parameter LCM_MIPI=768,
    parameter SOF_W=32
  )(
    input clkin,
    input [IDWIDTH-1:0]id,
    input [DATASIZE_WIDTH-1:0]data_size,
    input valid_req,
    input start,
    input [DATA_WIDTH-1:0]data_fifo,
    input data_valid,
    output reg ready_sig,
    output reg [MIPI_S-1:0]mipi_packet,
    output reg mipi_valid,
    output reg read_enable
  );
  reg [31:0]SOF={SOF_W{1'b1}};
  reg [LCM_MIPI-1:0]reg_array=0;// forstoring 768 bits which is send easily
  //reg [LCM_MIPI-1:0]splice_array=0;//for remaining data which has to be zero padded
  reg [4:0]state=0;
  reg [IDWIDTH-1:0]id_reg;
  reg signed [DATASIZE_WIDTH-1:0]data_size_reg;
  //reg [DATASIZE_WIDTH-1:0]data_size_reg_1;
  reg [DATASIZE_WIDTH-1:0]zero_pad;
  reg [3:0]data_count=0;
  reg [4:0]count=(LCM_MIPI/MIPI_S);
  reg [10:0]splice_value=0;
  reg [6:0]splice_count=0;
  reg [8:0]packet_count=0;
  reg [7:0]i=0;
  reg flag=1;//to load remaining data once
  always @(posedge clkin)
  begin
    case(state)
      4'd0:
      begin
        ready_sig<=1;
        if(valid_req)
        begin
          data_size_reg<=data_size;
          //data_size_reg_1<=data_size;
          id_reg<=id;
        end
        if(start)
        begin
          state<=4'd1;
        end
      end
      4'd1:
      begin
        ready_sig<=0;
        /*         //precalculation if zero padding is needed
                if(data_size_reg_1>=6)
                begin
                  data_size_reg_1=data_size_reg_1-6;
                  state<=4'd1;
                end
                else
                begin
                  zero_pad<=(6-data_size_reg_1)<<3;//in bits
                  state<=4'd2;
                end */
        zero_pad<=(6-(data_size_reg%6))<<3;//in bits
        state<=4'd2;
      end
      4'd2:
      begin
        mipi_packet[(MIPI_S-1)-:DATASIZE_WIDTH]<=SOF;
        mipi_packet[((DATASIZE_WIDTH>>1)-1)-:(DATASIZE_WIDTH>>1)]<=data_size_reg[DATASIZE_WIDTH-1 -:DATASIZE_WIDTH>>1];
        mipi_valid<=1;
        state<=4'd3;
      end
      4'd3:
      begin
        mipi_packet[(MIPI_S-1)-:(DATASIZE_WIDTH>>1)]<=data_size_reg[0+:(DATASIZE_WIDTH>>1)];
        mipi_packet[0+:DATASIZE_WIDTH]<=id_reg;
        mipi_valid<=1;
        state<=4'd4;
      end
      4'd4:
      begin
        //mipi_packet<=0;
        mipi_valid<=0;
        state<=4'd5;
        read_enable<=1;//make data fifo send data
        //make either mipi_packet or mipi valid 0
      end
      //first 2 frames done
      //now data frames
      4'd5:
      begin
        if((data_size_reg)>=96)//768/8
        begin
          if(data_count<(LCM_MIPI/DATA_WIDTH))//------->3
          begin
            if(data_valid)
            begin
              data_count<=data_count+1;
              //[((data_count)<<$clog2(DATA_WIDTH))-:DATA_WIDTH]reg_array<=data_fifo;
              reg_array[((LCM_MIPI-1)-((data_count)<<$clog2(DATA_WIDTH)))-:DATA_WIDTH]<=data_fifo;
              data_size_reg<=data_size_reg-(DATA_WIDTH>>3);//-------->
            end
          end
          else
          begin
            data_count<=0;
            state<=4'd6;//---->mipi it
            read_enable<=0;
          end
        end
        else
        begin
          if(flag)
          begin
            splice_value<=(data_size_reg<<3)+zero_pad;//how much data is left to be spliced out in bits
            flag<=0;
          end
          if(data_size_reg>0)
          begin
            if(data_valid)
            begin
              reg_array[(LCM_MIPI-1-(splice_count<<8))-:DATASIZE_WIDTH]<=data_fifo;
              data_size_reg<=data_size_reg-32;
              splice_count<=splice_count+1;
            end
          end
          else
          begin
            state<=7;
            read_enable<=0;
            splice_count<=0;
          end
        end
      end
      4'd6:
      begin
        if(count>0)
        begin
          mipi_packet<=reg_array[((count*48)-1)-:MIPI_S];
          mipi_valid<=1;
          count<=count-1;
        end
        else
        begin
          count<=(LCM_MIPI/MIPI_S);
          mipi_packet<=0;
          state<=5;
          read_enable<=1;
          mipi_valid<=0;
          reg_array<=0;
        end
      end
      4'd7:
      begin
        //calculate number of mipi packets remaining
        /*         if(splice_value>0)
                begin
                  splice_value=splice_value-48;
                  packet_count<=packet_count+1
                end
                else
                begin
                  state<=8;
                end */
        packet_count<=splice_value/48;
        state<=8;
      end
      4'd8:
      begin
        if(packet_count>0)
        begin
          mipi_packet<=reg_array[((LCM_MIPI-1) - (i * MIPI_S)) -: MIPI_S];
          i=i+1;
          packet_count<=packet_count-1;
        end
        else
        begin
          state<=0;
          flag<=1;
          reg_array<=0;
          splice_value<=0;
          packet_count<=0;
          i<=0;
        end
      end
    endcase
  end
endmodule
