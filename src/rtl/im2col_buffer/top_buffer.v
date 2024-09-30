module top_buffer #(
    parameter BUFFER_SIZE = 8,
    parameter N_SA = 4,
    parameter DRAM_BW = 32
) (
    input clk,
    input rst,
	  input stall_on,
    input [(DRAM_BW*BUFFER_SIZE) -1:0] data_in,
    input data_signal,
    output [BUFFER_SIZE*N_SA -1 : 0] data_out,
    output [2:0] elements_poped
);
  wire [(N_SA*3)-1:0] element_poped;
  assign elements_poped = element_poped[2:0];
  genvar i;
  generate
    for (i = 0; i < N_SA; i = i + 1) begin
      buffers #(
          .BUFFER_SIZE(BUFFER_SIZE),
          .N_SA(N_SA),
          .DRAM_BW(DRAM_BW)
      ) b1 (
          .clk(clk),
          .rst(rst),
		      .stall_on(stall_on),
          .data_in(data_in[(DRAM_BW/N_SA)*(N_SA-i)*BUFFER_SIZE-1-:BUFFER_SIZE*(DRAM_BW/N_SA)]),
          .data_signal(data_signal),
          .element_poped(element_poped[((N_SA-i)*3) -1 -:3]),
          .data_out(data_out[BUFFER_SIZE*(N_SA-i)-1-:BUFFER_SIZE])
      );
    end
  endgenerate


endmodule
module buffers #(
    parameter BUFFER_SIZE = 8,
    parameter N_SA = 8,
    parameter DRAM_BW = 32

) (
    input clk,
    input rst,
	  input stall_on,
    input [((DRAM_BW/N_SA)*BUFFER_SIZE) - 1:0] data_in,
    input data_signal,
    output reg [2:0] element_poped = 0,
    output reg [BUFFER_SIZE -1 : 0] data_out
);

  reg [(BUFFER_SIZE*(DRAM_BW/N_SA))-1:0] buffer = 0;

  reg  [$clog2((DRAM_BW/N_SA))-1:0] j = 0;
	integer i;
  //	reg [2:0] element_count=3'd7;	 



  always @(posedge clk) begin

    if (~rst) begin
      buffer <= 64'd0;
      j <= 0;
    end else begin
      buffer <= data_in;

    end
    //	if(read_state) stat<=read_fifo;

    if (data_signal && (~stall_on)) begin
		for( i=0;i<(DRAM_BW/N_SA);i=i+1) begin 
			if(j==i) begin 
				data_out <= buffer[BUFFER_SIZE*((DRAM_BW/N_SA)-i)-1-:BUFFER_SIZE];
			end
		end 
      j <= j + 1;
      element_poped <= element_poped + 1;
	  end
  end

endmodule
