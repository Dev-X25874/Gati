module vector_mux_param 
	#( 
		parameter NO_PORT=8,
		parameter PORT_SIZE=8
	)
	(
		input clk,
		input [(NO_PORT*PORT_SIZE)-1:0] in,
		input [NO_PORT-1:0] sel,
		output reg [PORT_SIZE-1:0] out=0
	);

	integer i=0;

	always @(posedge clk) begin 
		for(i=0;i<NO_PORT;i=i+1) begin 
			if(sel[i]==1) begin 
				out<=in[PORT_SIZE*(NO_PORT-i)-1 -:PORT_SIZE];
			end
			 
		end
	end
endmodule

