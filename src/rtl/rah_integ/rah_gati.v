module rah_gati
	(
		input clk,
		input empty,
		input [47:0] data,
		output rden
	)
	
	reg [47:0] r_data=0;
	reg valid_data=0;
	
	always @ (posedge clk) begin 
		
		if(!empty) begin 
			rden<=1;
		end
		else begin 
			rden<=0;
		end

		if(rden)  
			valid_data<=1;
		else
			valid_data<=0;
		
		if(valid_data) 
			r_data<=data;
	end


////////////////////////////MIPI controller rx
	
//////////////////////////////
	

///////////////////////////////Memory Controller
	
/////////////////////////////////

	
	

//////////////////////////////// gati module instatiation

///////////////////////////////	

//////////////////////////////////// MIPI controller tx

///////////////////////////////////



