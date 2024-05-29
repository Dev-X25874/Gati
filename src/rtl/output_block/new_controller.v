/*                        controller_fifo_des Module 
- By assessing the empty_flag of the 32 fifos, the read for the first 8 FIFOs are
enabled, followed by subsequent FIFOs until 32nd FIFO. In conjunction to this,
mux select lines are also controlled here. 
*/

module new_controller #(
  parameter BIAS=1,

parameter TOGGLE=1,
    parameter FIFO_NO = 8
) (
    output reg [FIFO_NO-1:0] valid_rd_en=0,
   input rst,
       	input [FIFO_NO-1:0] empty_fifo,
    input channel_done ,
    input data_valid_tree,
    input clk,
    input enable,
    output reg mux_toggle=1

);
reg [1:0] state=0;
reg  bias=BIAS;
reg toggle=TOGGLE;
reg now=0;
  always @(posedge clk) begin
 if(!rst)
begin 
	now<=0;
	state<=0;
	mux_toggle<=1;
end
	  else
	  begin 
    if(~bias)
   begin 
      if (data_valid_tree & (enable & (~empty_fifo)))
       begin
      valid_rd_en <= ~valid_rd_en;
      if(toggle)
      begin
        mux_toggle<=~mux_toggle;
      end
    end else 
      begin
      valid_rd_en <= 0;

   end
  end

  else if(bias)

      begin 
        case(state)
        2'd0:
        begin 
          if (data_valid_tree & (enable & (~now)))
          begin
          valid_rd_en <= 8'hFF;
          state<= 2'd1;
        end
         else begin
          valid_rd_en <= 0;
          state <= 2'd1;
        end
        end
        2'd1:
        begin 
          valid_rd_en<=8'h00;
        if(channel_done)
        begin
           if(toggle)
             begin
        mux_toggle<=~mux_toggle;
              end
        now<=~now;
        state<=2'd0;
        end
      end
        endcase
      end
	  end

    end




endmodule
