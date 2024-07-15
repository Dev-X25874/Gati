module demux_controller_sel_op #(
	parameter  COL=4,
	parameter NUM_PORTS = 2,
	parameter OP_FIFO_WRITE=8
)
	( 
	  input rst, 
	  input clk,	
	  input [COL-1:0]data_valid,
	  output   [OP_FIFO_WRITE-1:0] op_wren,
	  output reg [$clog2(NUM_PORTS)-1 : 0] sel=0
	);

	reg flag=0;
	assign op_wren=r_op_wren;
(*syn_use_dsp = "no"*) reg [OP_FIFO_WRITE-1:0] r_op_wren;
always @(*)
begin
	if(data_valid=={COL{1'b1}})
	begin 
		r_op_wren = 0;
		r_op_wren[(COL*sel) +: COL] = {COL{1'b1}};
		// r_op_wren[(COL*(NUM_PORTS-sel)-1) -: COL] = {COL{1'b1}};
	end
	else begin
		r_op_wren <= {OP_FIFO_WRITE{1'b0}};
	end
end

always @(posedge clk)
begin 
if(!rst) begin 
	sel<=0;
	flag<=0;
end

else
	begin 
	if(data_valid=={COL{1'b1}})
	begin
		flag<=1;	
		sel<= sel + 1;
	end
	else
	begin 
		sel<=sel;
		flag<=0;
	end
end
end

endmodule
