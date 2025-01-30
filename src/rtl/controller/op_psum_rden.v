module op_psum_rden#(parameter N_SA=4,
	parameter COL=4,
	parameter  FIFO=8)
	(	input clk,
		input rst,
		input [FIFO-1:0] empty_vector,
		input [FIFO-1:0] almost_empty_vector,
		input [(N_SA)-1:0] empty_sa,
		input [(N_SA)-1:0] almost_empty_sa,
		input vector_enable,
		input op_full,	

		output reg [(N_SA)-1:0] opsum_rden);


		reg [FIFO-1:0] r_empty_vector;
		reg [(N_SA)-1:0] r_empty_sa;
		reg r_vector_enable,r_op_full=0;
	always @(posedge clk) begin
		r_empty_vector<=empty_vector;
		r_empty_sa<=empty_sa;
		r_vector_enable<=vector_enable;
		r_op_full<=op_full;
	end

	always@(posedge clk)
	begin
		// if(!rst) opsum_rden <= 0;
		// else begin
		// 	if(~vector_enable) begin
		// 		if((~|empty_sa) && (~op_full)) opsum_rden <= {(N_SA*COL){1'b1}};
		// 		else opsum_rden <= 0;
		// 	end
		// 	else begin
		// 		if(op_full) begin
		// 			opsum_rden <= 0;
		// 		end
		// 		else begin
		// 			if(((&almost_empty_sa) || (&almost_empty_vector)) && (|opsum_rden)) begin
		// 				opsum_rden <= 0;
		// 			end
		// 			else if(~(&empty_vector) & ~|empty_sa & ~op_full) begin
		// 				opsum_rden <= {(N_SA*COL){1'b1}};
		// 			end
		// 		end
		// 	end
		// end
		if(vector_enable && (~|empty_vector  & ~|empty_sa) && (~op_full))
			opsum_rden<={(N_SA){1'b1}};

		else if(~vector_enable && (~|empty_sa) && (~op_full))
			opsum_rden<={(N_SA){1'b1}};

		else
			opsum_rden<={(N_SA){1'b0}};

	end

endmodule
	
