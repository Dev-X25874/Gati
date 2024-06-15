module op_psum_rden#(parameter N_SA=4,
	parameter COL=4,
	parameter  FIFO=8)
	(	input clk,
		input [FIFO-1:0] empty_vector,
		input [(N_SA*COL)-1:0] empty_sa,
		input vector_enable,
	

		output reg [(N_SA*COL)-1:0] opsum_rden);


		reg [FIFO-1:0] r_empty_vector;
		reg [(N_SA*COL)-1:0] r_empty_sa;
		reg r_vector_enable;
	always @(posedge clk) begin
		r_empty_vector<=empty_vector;
		r_empty_sa<=empty_sa;
		r_vector_enable<=vector_enable;
	end









	always@(posedge clk)
	begin 
		if(r_vector_enable && (~|r_empty_vector  & ~|r_empty_sa))
			opsum_rden<={(N_SA*COL){1'b1}};

		else if(~vector_enable && (~|empty_sa))
			opsum_rden<={(N_SA*COL){1'b1}};

		else
			opsum_rden<={(N_SA*COL){1'b0}};

	end

endmodule
	
