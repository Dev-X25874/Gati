module vector_mux #(parameter PORT_SIZE=128,
                     parameter NO_PORT=2  )
 ( input clk,
       input [PORT_SIZE*NO_PORT -1:0] in,
    output reg [PORT_SIZE-1:0] out,
        	 input  sel);


	always@(posedge clk)
	 	
		case(sel)
		
				1'b0:out<=in[PORT_SIZE-1:0];
				1'b1:out<=in[(PORT_SIZE*NO_PORT)-1-:PORT_SIZE];
				default:out<=in[PORT_SIZE*NO_PORT-1:PORT_SIZE];
	
		endcase
	
endmodule
