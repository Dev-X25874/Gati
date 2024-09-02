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
    input [(N*COL_SA)-1:0] empty_sa,
    input op_full,
    input data_valid_tree,
    input clk,
    input enable,
    output [NO_PORT-1:0] select

);
  
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
          rden_toggle <= 0;
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
endmodule