//////////////////////////////////////////////////////////////////////////////////
// Design Name: Config Block
// Module Name: Burst Memory Module
// Project Name: Gati
// Description: Memory module that sends instruction data in bursts of 8 to the instruction queue controller along with a
// valid signal.
//////////////////////////////////////////////////////////////////////////////////
//
module burst_mem_module(
    input clkin,
    input burst_read_trigger,
    input [7:0]burst_length,
    output reg [255:0]mem_instruction,
    output reg valid_signal
  );
  reg [255:0]internal_mem[0:100];
  reg [4:0]counter1=0;
  reg [3:0]state=0;
  reg [3:0]state_2=0;
  reg [10:0]pointer=0;
  reg [9:0]counter2=0;
  initial
  begin
    $readmemh("vgg16.mem",internal_mem,0,100); //load mem file into local registers of 256 bits
  end
  always @(posedge clkin)
  begin

    case(state)
      4'd0:
      begin
        counter1<=0;
        valid_signal<=1'b0;
        if(burst_read_trigger)
        begin
          state<=1;
        end
      end
      4'd1:
      begin
        if(counter1>=(burst_length+1))
        begin
          state<=4'd0;
          valid_signal<=1'b0;
        end
        else
        begin
          counter1<=counter1+1;
          mem_instruction<=internal_mem[pointer];
          pointer<=pointer+1;
          valid_signal<=1'b1;
        end
      end
    endcase
  end
  /*     /*     case(state_2)
            4'd0:
            begin
              counter2<=0;
              if(burst_read_trigger)
              begin
                state_2<=1;
              end
            end
            4'd1:
            begin
       
              //if(counter2>=30)
              //begin
              state_2<=0;
              state<=1;
              //end
              /*         else begin
                        counter2<=counter2+1;
                      end */
  //end
  //endcase */ */
  //end
endmodule
