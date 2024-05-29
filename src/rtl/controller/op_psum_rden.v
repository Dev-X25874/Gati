module op_psum_rden#(parameter N_SA=4,
	parameter COL=4,
	parameter  FIFO=8)
	(input clk,
		input [FIFO-1:0] empty_vector,
		input [(N_SA*COL)-1:0] empty_sa,
		input vector_enable,
	output reg [(N_SA*COL)-1:0] opsum_rden);


	always@(posedge clk)
	begin 
		if(vector_enable && (~|empty_vector  & ~|empty_sa))
		begin 
			opsum_rden<={(N_SA*COL){1'b1}};
		end
		else if(~vector_enable && (~|empty_sa))
		begin 
			opsum_rden<={(N_SA*COL){1'b1}};

		end
		else
			opsum_rden<=0;
	end

endmodule
	
