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
    input [$clog2((DRAM_BW/N_SA))-1:0] count,
    output [DRAM_BW -1:0] rden 
);

  reg state = INITIAL;
  parameter INITIAL = 1'b0;
  parameter ONGOING = 1'b1;
  assign rden = rd;
  reg [DRAM_BW-1:0] rd = 0;

  generate
    if(DRAM_BW/N_SA > 2) begin
      always @(posedge clk) begin
        if (!rst) begin
          state <= INITIAL;
          rd <= {DRAM_BW{1'b0}};
        end else begin
          case (state)
            INITIAL: begin
              if (((|fifo_empty) == 0) && ~stall_on) begin
                rd <= {DRAM_BW{1'b1}};
                state <= ONGOING;
              end
              else rd <= 0;
            end
            ONGOING: begin
              rd <= {DRAM_BW{1'b0}};
              if ((count == POP_THRESHOLD) && (~|fifo_empty) && ~stall_on && read_buf_data) begin
                rd <= {DRAM_BW{1'b1}};
                state <= ONGOING;
              end
              else if((count!=0 && count<POP_THRESHOLD) && (~|fifo_empty) && ~stall_on && im2col_done) begin
                rd <= {DRAM_BW{1'b1}};
                state <= ONGOING;
              end
            end
          endcase
        end
      end
    end

    else begin
      reg r_fifo_empty = 0;
      wire fifo_empty_fall;
      always @(posedge clk) r_fifo_empty <= &(fifo_empty);
      assign fifo_empty_fall = r_fifo_empty && ~&fifo_empty;

      always @(posedge clk) begin
        if (!rst) begin
          state <= INITIAL;
          rd <= {DRAM_BW{1'b0}};
        end else begin
          case (state)
            INITIAL: begin
              if (((|fifo_empty) == 0) && ~stall_on) begin
                rd <= {DRAM_BW{1'b1}};
                state <= ONGOING;
              end
              else rd <= 0;
            end
            ONGOING: begin
              rd <= {DRAM_BW{1'b0}};
              if ((count == POP_THRESHOLD) && (~|fifo_empty) && ~stall_on && read_buf_data) begin
                rd <= {DRAM_BW{1'b1}};
                state <= ONGOING;
              end
              else if ((~|fifo_empty) && count == 1 && fifo_empty_fall && read_buf_data) begin
                rd <= {DRAM_BW{1'b1}};
                state <= ONGOING;
              end
              // else if((count!=0) && (~|fifo_empty) && ~stall_on && im2col_done) begin
              //   rd <= {DRAM_BW{1'b1}};
              //   state <= ONGOING;
              // end
            end
          endcase
        end
      end
    end
  endgenerate

  
endmodule
