/*                        controller_fifo_des Module 
- By assessing the empty_flag of the 32 fifos, the read for the first 8 FIFOs are
enabled, followed by subsequent FIFOs until 32nd FIFO. In conjunction to this,
mux select lines are also controlled here. 
*/

module bias_controller #(
   parameter DRAM_BW=32,
    parameter FIFO_NO = 8,
	parameter NO_PORT=8
) (
    output reg [FIFO_NO-1:0] valid_rd_en=0,
    input [FIFO_NO-1:0] empty_fifo,
	output reg[NO_PORT-1:0] sel=0,
	input rst,
    input data_valid_tree,
    input clk,
    input enable
   

);
reg  state=IDLE;

localparam IDLE=1'b0;
localparam NEXT=1'b1;
//reg[DRAM_BW/COL-1:0] sel=0;
reg [1:0] count=0;
reg[$clog2(NO_PORT)-1:0] i=0;
	always@(posedge clk)
	begin 
	if(rst)
		begin 
		if(count==1 & data_valid_tree)
		begin 
			sel<=1<<i;
			i<=i+1;
		end
	end
	end


  always @(posedge clk) begin
	if(!rst)
	begin 
		count<=0;
		state<=IDLE;
		sel<=0;
		i<=0;
	end
	else
		begin 
  
	case(state)
IDLE:
			begin
				if(((~empty_fifo)&data_valid_tree) & enable)
	  begin 
		  valid_rd_en<={FIFO_NO{1'b1}};
		  state<=NEXT;	
	 
	 end
				else valid_rd_en<=0;
			end
NEXT:begin
	valid_rd_en<={FIFO_NO{1'b0}};	
	if(count==1)
	begin 
		count<=count;
		// if(data_valid_tree)
		// begin 
		// sel<=1<<i;
		// i<=i+1;
		// end
	end
	else count<=count+1;
	if(sel[NO_PORT-3]==1'b1)
	begin
		state<=IDLE;	
	end 

  end
	endcase
  end
end
	
endmodule
