module vector_mux_param #(parameter PORT_SIZE=1'b1,
                     parameter NO_PORT=2  )
 (
       input [(PORT_SIZE*NO_PORT) -1:0] in,
    output wor  [PORT_SIZE-1:0] out,
        	 input[NO_PORT-1:0]  sel);


	 genvar i;
	 generate 
		 for(i=0;i<NO_PORT;i=i+1)
		 begin 
		 assign out=(sel[i])?in[i*PORT_SIZE +:PORT_SIZE]:0;
		end
 	 endgenerate 



endmodule
