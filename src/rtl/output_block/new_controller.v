/*                        controller_fifo_des Module 
- By assessing the empty_flag of the 32 fifos, the read for the first 8 FIFOs are
enabled, followed by subsequent FIFOs until 32nd FIFO. In conjunction to this,
mux select lines are also controlled here. 
*/

module new_controller #(
    parameter BIAS = 1,
    parameter TOGGLE  = 1,
    parameter NO_PORT = 2,
    parameter COL_SA = 4,
    parameter FIFO_NO = 8
) (
    output reg [FIFO_NO-1:0] valid_rd_en = 0,
    input rst,
    input CONV_FC,
    input [FIFO_NO-1:0] empty_fifo,
    input channel_done,
    input data_valid_tree,
    input clk,
    input enable,
    output reg [$clog2(NO_PORT)-1:0] mux_toggle_fc = 0,
    output reg [$clog2(NO_PORT)-1:0] mux_toggle_conv = NO_PORT-1

);

generate
  if(TOGGLE) begin
    reg [1:0] state = 0;
    integer i;

    wire [NO_PORT-1:0] sel_fc;
    wire [NO_PORT-1:0] sel_conv;
    assign sel_fc = 1<<mux_toggle_fc;
    assign sel_conv = 1<<mux_toggle_conv;

    always @(posedge clk) begin
      if (!rst) begin
        state <= 0;
        mux_toggle_conv <= NO_PORT-1;
        mux_toggle_fc <= 0;
        valid_rd_en <= 0;
      end else begin
        if (CONV_FC) begin
          if (data_valid_tree & (enable && (~|empty_fifo))) begin
            for(i=0;i<NO_PORT;i=i+1) begin
              if(sel_fc[i]==1) begin
                valid_rd_en[COL_SA*(i) +: COL_SA] <= {COL_SA{1'b1}};
              end
              else begin
                valid_rd_en[COL_SA*(i) +: COL_SA] <= {COL_SA{1'b0}};
              end
            end
            if (TOGGLE) begin
              if(mux_toggle_fc == NO_PORT-1) begin
                mux_toggle_fc <= 0;
              end
              else begin
                mux_toggle_fc <= mux_toggle_fc + 1;
              end
            end
          end else begin
            valid_rd_en <= 0;
          end
        end else if (~CONV_FC) begin
          case (state)
            2'd0: begin
              if (data_valid_tree & (enable)) begin
                valid_rd_en <= {FIFO_NO{1'b1}};
                state <= 2'd1;
              end
              else begin
                valid_rd_en <= 0;
                state <= 2'd0;
              end
            end
            2'd1: begin
              valid_rd_en <= 0;
              if (channel_done) begin
                if (TOGGLE) begin
                  if(mux_toggle_conv == 0) begin
                    mux_toggle_conv <= NO_PORT-1;
                    state <= 0;
                  end
                  else begin
                    mux_toggle_conv <= mux_toggle_conv - 1;
                    state <= 1;
                  end
                end
              end
            end
          endcase
        end
      end
    
    end
  end

  else begin
    reg [1:0] state = 0;
    
    always @(posedge clk) begin
      mux_toggle_conv <= 0;
      mux_toggle_fc <= 0;
      if (!rst) begin
        state <= 0;
        valid_rd_en <= 0;
      end else begin
        if (CONV_FC) begin
          if (data_valid_tree & (enable && (~|empty_fifo))) begin
            valid_rd_en <= {FIFO_NO{1'b1}};
          end else begin
            valid_rd_en <= 0;
          end
        end else if (~CONV_FC) begin
          case (state)
            2'd0: begin
              if (data_valid_tree & (enable)) begin
                valid_rd_en <= {FIFO_NO{1'b1}};
                state <= 2'd1;
              end 
              else begin
                valid_rd_en <= 0;
                state <= 2'd0;
              end
            end
            2'd1: begin
              valid_rd_en <= 0;
              if (channel_done) begin
                state <= 2'd0;
              end
            end
          endcase
        end
      end
  
    end
  end
endgenerate

endmodule
