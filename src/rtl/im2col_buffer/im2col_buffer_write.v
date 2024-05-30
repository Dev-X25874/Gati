module im2col_buffer_write #(
    parameter N_SA = 4,
    parameter DRAM_BW = 32,
    parameter POP_THRESHOLD = 5
) (
    input clk,
	input rst,
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
      rd <= 8'h00;
    end else begin
      case (state)
        INITIAL:
        if ((|fifo_empty) == 0) begin
          rd <= 8'hFF;
          state <= ONGOING;
        end

        ONGOING: begin

          rd <= 8'h00;
          if (count == POP_THRESHOLD) begin
            rd <= 8'hFF;
            state <= ONGOING;
          end

        end

      endcase





    end












  end
endmodule
