module im2col_buffer_write #(
    parameter N_SA = 4,
    parameter DRAM_BW = 32,
    parameter POP_THRESHOLD = 5
) (
    input clk,
	  input rst,
    input im2col_done,
    input read_buf_data,
    input stall_on,
	  input [DRAM_BW-1:0] fifo_empty,
    input [2:0]count,
    output [DRAM_BW -1:0] rden 
);

  reg state = INITIAL;
  parameter INITIAL = 1'b0;
  parameter ONGOING = 1'b1;
  assign rden = {N_SA{rd}};
  reg [(DRAM_BW/N_SA)-1:0] rd = 0;


  always @(posedge clk) begin
    if (!rst) begin
      state <= INITIAL;
      rd <= {N_SA{1'b0}};
    end else begin
      case (state)
        INITIAL:
        if (((|fifo_empty) == 0) && ~stall_on) begin
          rd <= {N_SA{1'b1}};
          state <= ONGOING;
        end
        else rd <= 0;
        ONGOING: begin
          rd <= {N_SA{1'b0}};
          if ((count == POP_THRESHOLD) && (~|fifo_empty) && ~stall_on && read_buf_data) begin
            rd <= {N_SA{1'b1}};
            state <= ONGOING;
          end
          else if(count!=0 && (~|fifo_empty) && ~stall_on && im2col_done) begin
            rd <= {N_SA{1'b1}};
            state <= ONGOING;
          end
        end
      endcase
    end
  end
endmodule
