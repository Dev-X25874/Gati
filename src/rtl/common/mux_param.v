/*
   This is a parametrized multiplexer that accepts two parameters
      1. PORT_SIZE = data width of input data to the mux
      2. NO_PORT   = size of the mux (Ex: 8x1, 4x1)
   Description of input and output ports
   in: data input port whose data width = PORT_SIZE*NO_PORT
       Ex: 32-bit 8x1 mux, in_data_width = 32*8 = 256
   out: data output whose data width = PORT_SIZE
   sel: select line input of size $clog2(NO_PORT)
*/

module mux_param #(parameter PORT_SIZE=32,
                  parameter NO_PORT = 8)
 (  
    input [PORT_SIZE*NO_PORT -1:0] in,
	input clk,
    output reg [PORT_SIZE-1:0] out,
    input  [$clog2(NO_PORT)-1:0] sel
 );
	integer i;
    (* syn_use_dsp = "no" *) reg  signed [PORT_SIZE-1:0] out; //This synthesis attribute is used to avoid the usage of DSP block for data slicing
	always@(posedge clk)
	begin 
		for(i=0;i<NO_PORT;i=i+1) begin 
			if(sel==i) begin 
				out <= in[PORT_SIZE*(NO_PORT-i) -1 -: PORT_SIZE] ;
			end

		end
	end
endmodule

