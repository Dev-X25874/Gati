
module top_booth(input signed [7:0] a,
	input signed [7:0] b,
	input clk,
	output reg signed [15:0] c);

wire signed [8:0] temp_a;
wire signed [7:0] temp_b;
wire signed [63:0] pp;
reg signed [15:0] pp_1;
reg signed [31:16] pp_2;
reg signed [47:32] pp_3;
reg signed [63:48] pp_4;

assign temp_a=a>=b?{a,1'b0}:{b,1'b0};
assign temp_b=a>=b?b:a;

//perfom addition of the four partial sum 
always@(posedge clk)
begin
	pp_1=pp[15:0];
	pp_2=pp[31:16];
	pp_3=pp[47:32];
    pp_4=pp[63:48];
 	c=pp_1+pp_2+pp_3+pp_4;
	
end
//generate 4 blocks to calculate the 4 partial sums	
genvar i;
generate 
	for (i=0;i<4;i=i+1)
	begin 
	
		booth_partial_product b1(
			.clk(clk),
			.opr(temp_a[i*2 +:3]),
			.extend_one(i),
			.b(temp_b),
			.pp(pp[i*16+:16])
		);

end
endgenerate
	
endmodule

	



