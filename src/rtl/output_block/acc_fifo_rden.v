/*                        controller_fifo_des Module 
- By assessing the empty_flag of the 32 fifos, the read for the first 8 FIFOs are
enabled, followed by subsequent FIFOs until 32nd FIFO. In conjunction to this,
mux select lines are also controlled here. 
*/

module acc_fifo_rden #(
    parameter TOGGLE  = 1,
    parameter FIFO_NO = 8,
    parameter N = 4,
    parameter COL_SA = 4,
    parameter NO_PORT = 2
) (
    output reg [FIFO_NO-1:0] valid_rd_en = 0,
    input rst,
    input [FIFO_NO-1:0] empty_fifo,
    input [FIFO_NO-1:0] almost_empty_fifo,
    input [N-1:0] empty_sa,
    input [N-1:0] almost_empty_sa,
    input op_full,
    input data_valid_tree,
    input clk,
    input istolic_stall,
    input enable,
    output [NO_PORT-1:0] select

);
/*  
reg toggle = TOGGLE;
reg mux_toggle = 0;
reg rden_toggle = 0;
reg [FIFO_NO-1:0] r_empty_fifo;
reg [(N*COL_SA)-1:0] r_empty_sa;
reg r_enable,r_op_full=0;

assign select = 1<<mux_toggle;

wire [NO_PORT-1:0] sel_rden;
assign sel_rden = 1<<rden_toggle;

always @(posedge clk) begin
  r_empty_fifo<=empty_fifo;
  r_empty_sa<=empty_sa;
  r_enable<=enable;
  r_op_full<=op_full;
end

integer i;
always @(posedge clk) begin
    if (!rst) begin
      rden_toggle <= 0;
      valid_rd_en <= 0;
    end else begin
      // if(((&almost_empty_sa) || (&almost_empty_fifo) || op_full) && enable && (|valid_rd_en)) begin
      //   valid_rd_en <= 0;
      // end
      // else 
      if ((~|empty_sa) & (enable & (~|empty_fifo)) && (~op_full)) begin
        //valid_rd_en <= ~valid_rd_en;
        for(i=0;i<NO_PORT;i=i+1) begin
          if(sel_rden[i]==1) begin
            valid_rd_en[COL_SA*(i) +: COL_SA] <= {COL_SA{1'b1}};
          end
          else begin
            valid_rd_en[COL_SA*(i) +: COL_SA] <= {COL_SA{1'b0}};
          end
        end
        if (toggle) begin
          rden_toggle <= ~rden_toggle;
        end
      end else begin
        valid_rd_en <= 0;
        rden_toggle <= rden_toggle;
      end
    end
end

always@(posedge clk) begin
  if(!rst) begin
    mux_toggle <= 0;
  end
  else begin
    if(enable & data_valid_tree) begin
      if (toggle) begin
        mux_toggle <= ~mux_toggle;
      end
    end
    else begin
      mux_toggle <= 0;
    end
  end
end
*/

generate
  if(TOGGLE) begin
    assign select = 1<<mux_toggle;

    wire [NO_PORT-1:0] sel_rden;
    assign sel_rden = 1<<rden_toggle;

    reg [$clog2(NO_PORT)-1:0] mux_toggle = 0;
    reg [$clog2(NO_PORT)-1:0] rden_toggle = 0;
    
    // Signals needed for imagenet_resnet. PSUM FIFO got empty in between running layer, to handle that edge case, below signals are used.
    reg stall_f1, stall_f2, stall_f3 = 0;

    reg empty_sa_delayed_1,empty_sa_delayed_2,empty_sa_delayed_3,empty_sa_delayed_4, empty_sa_delayed_5;
    
    // To sync. with data_valid_tree
    always @(posedge clk) begin
      empty_sa_delayed_1 <= empty_sa;
      empty_sa_delayed_2 <= empty_sa_delayed_1;
      empty_sa_delayed_3 <= empty_sa_delayed_2;
      empty_sa_delayed_4 <= empty_sa_delayed_3;
      empty_sa_delayed_5 <= empty_sa_delayed_4;
    end

    integer i;
    always @(posedge clk) begin
        if (!rst) begin
          rden_toggle <= 0;
          valid_rd_en <= 0;
          stall_f1  <= 0;
        end else begin
            if ((~|empty_sa) & (enable & (~|empty_fifo)) && (~op_full)) begin
              //valid_rd_en <= ~valid_rd_en;
              for(i=0;i<NO_PORT;i=i+1) begin
                if(sel_rden[i]==1) begin
                  valid_rd_en[N*(i) +: N] <= {N{1'b1}};
                end
                else begin
                  valid_rd_en[N*(i) +: N] <= {N{1'b0}};
                end
              end
              if (TOGGLE) begin
                if(rden_toggle == NO_PORT-1) begin
                  rden_toggle <= 0;
                end
                else begin
                  rden_toggle <= rden_toggle + 1;
                end
              end
              stall_f1 <= istolic_stall;
            end else if(istolic_stall && (&empty_sa) && stall_f1) begin
              valid_rd_en <= 0;
              rden_toggle <= rden_toggle + 1;
              stall_f1 <= 0;
            end else begin
              valid_rd_en <= 0;
              rden_toggle <= rden_toggle;
              stall_f1 <= stall_f1;
            end
        end
    end

    always@(posedge clk) begin
      if(!rst) begin
        mux_toggle <= 0;
        stall_f2 <= 0;
        stall_f3 <= 0;
      end
      else begin
        if(enable & data_valid_tree) begin
          if (TOGGLE) begin
            if(mux_toggle == NO_PORT-1) begin
              mux_toggle <= 0;
            end
            else begin
              mux_toggle <= mux_toggle + 1;
            end
          end
          stall_f2 <= istolic_stall;
        end
        else if(istolic_stall && (&empty_sa_delayed_5) && stall_f2) begin
          mux_toggle <= mux_toggle + 1;
          stall_f3 <= 1'b1;
          stall_f2 <= 0;
        end
        else if((&empty_sa_delayed_5) && stall_f3) begin
          mux_toggle <= rden_toggle;
          stall_f2 <= stall_f2;
          stall_f3 <= 1'b0;
        end 
        else if((&empty_sa_delayed_5)) begin
          mux_toggle <= mux_toggle;
          stall_f2 <= stall_f2;
          stall_f3 <= stall_f3;
        end 
        else begin
          mux_toggle <= 0;
          stall_f2 <= stall_f2;
          stall_f3 <= stall_f3;
        end
      end
    end
  end

  else begin
    assign select = 0;
    
    always @(posedge clk) begin
      if(!rst) begin
        valid_rd_en <= 0;
      end
      else begin
        if ((~|empty_sa) & (enable & (~|empty_fifo)) && (~op_full)) begin
          valid_rd_en <= {FIFO_NO{1'b1}};
        end
        else begin
          valid_rd_en <= 0;
        end
      end
    end
  end
endgenerate

endmodule