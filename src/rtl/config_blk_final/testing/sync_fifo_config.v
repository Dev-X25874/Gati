//////////////////////////////////////////////////////////////////////////////////
// Design Name: Config Block
// Module Name: Synchronous FIFO
// Project Name: Gati
// Description: FIFO that stores the instruction data. 
//It also sends status signals to the DRAM controller and the Instruction Read Controller.
//It also counts number of instructions stored in the FIFO.
//////////////////////////////////////////////////////////////////////////////////
module synchronous_fifo #(parameter DEPTH=100, 
parameter DATA_WIDTH=256,
parameter  STATUS_DRAM_LIM=10 ) (
    input clk, rst_n,
    input w_en, r_en,
    input [(DATA_WIDTH-1):0] data_in,
    output reg [(DATA_WIDTH-1):0] data_out,
    output reg data_out_valid,
    output full, empty,
    output [($clog2(DEPTH)):0] occupants,
    output ten_trigg,
    output not_empty
  );

  reg [($clog2(DEPTH)-1):0] w_ptr=0;
  reg [($clog2(DEPTH)-1):0] r_ptr=0;
  reg [DATA_WIDTH-1:0] fifo[DEPTH:0];
  reg [$clog2(DEPTH):0]occupants_reg=9'd0;
  // Set Default values on reset.
  always@(posedge clk)
  begin
    if(!rst_n) //reset FIFO
    begin
      w_ptr <= 0;
      r_ptr <= 0;
      data_out <= 0;
      data_out_valid<=0;
      occupants_reg<=0;
    end

    // To write data to FIFO
    else
    begin
      if(w_en & !full)
      begin
        fifo[w_ptr] <= data_in;
        w_ptr <= w_ptr + 1;
      end

      // To read data from FIFO
      if(r_en & !empty)
      begin
        data_out <= fifo[r_ptr];
        data_out_valid=1'b1;
        r_ptr <= r_ptr + 1;
      end
      else
      begin
        data_out_valid<=1'b0;
        data_out<=256'd0;
      end
      
      case((w_en&&!full)+(r_en&&!empty)) //occupants logic
        2'd0:
          occupants_reg<=occupants_reg;
        2'd1:
        begin
          if(w_en)
          begin
            occupants_reg<=occupants_reg+1;
          end
          else if(r_en)
          begin
            occupants_reg<=occupants_reg-1;
          end
        end
        2'd2:
          occupants_reg<=occupants_reg;
      endcase
    end
  end


  assign occupants=occupants_reg;
  assign full = ((w_ptr+1'b1) == r_ptr);
  assign empty = (w_ptr == r_ptr);
  assign ten_trigg=(occupants<STATUS_DRAM_LIM); //should be 10 is 1 for testing
  assign not_empty=~(w_ptr == r_ptr);
endmodule
