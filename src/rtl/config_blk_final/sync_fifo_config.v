module synchronous_fifo #(parameter DEPTH=100, DATA_WIDTH=256) (
    input clk, rst_n,
    input w_en, r_en,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output full, empty,
    output [8:0]occupants,
    output ten_trigg,
    output not_empty
  );

  reg [5:0] w_ptr=1'b0;
  reg [5:0] r_ptr=1'b0;
  reg [DATA_WIDTH-1:0] fifo[DEPTH:0];
  reg [8:0]occupants_reg=1'b0;
  reg [3:0]whatever;
  // Set Default values on reset.
  always@(posedge clk)
  begin
    if(!rst_n)
    begin
      w_ptr <= 0;
      r_ptr <= 0;
      data_out <= 0;
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
        r_ptr <= r_ptr + 1;
      end
      whatever<=(w_en&&!full)+(r_en&&!empty);
      case(whatever)
        2'd0:
          occupants_reg<=occupants_reg;
        2'd1:
        begin
          if(w_en)
          begin
            occupants_reg<=occupants_reg+1;
          end
          else
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
  assign ten_trigg=(occupants<10);
  assign not_empty=~(w_ptr == r_ptr);
endmodule
