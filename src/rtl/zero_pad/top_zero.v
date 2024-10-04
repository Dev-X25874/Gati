module top_zero #(parameter DW=32, 
	parameter COL=4,
	parameter I_SIZE_WIDTH=16,
	parameter MOD=8)

	(input clk,
		input rst,
		input [I_SIZE_WIDTH-1:0] i_size,
		input [(COL*DW)-1:0] data_in,
		input [COL-1:0] i_dv,
		output [(COL*DW)-1:0] data_out,
		output [COL-1:0] o_dv);


	genvar i;
	generate 
		for(i=0;i<COL;i=i+1) begin :ITR
			zero_padder #(.DW(DW),
				.I_SIZE_WIDTH(I_SIZE_WIDTH),
				.MOD(MOD))
			z1
			(.clk(clk),
			.rst(rst),
			.i_size(i_size),
			.data_in(data_in[((COL-i)*DW)-1 -:DW]),
			.i_dv(i_dv[(COL-i)-1 -:1]),
             .data_out(data_out[((COL-i)*DW)-1 -:DW]),
			.o_dv(o_dv[(COL-i)-1 -:1])
		);
		end
endgenerate 
endmodule
