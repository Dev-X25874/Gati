module top_mux #(
    parameter N_SA = 4,
    parameter INPUT_SIZE = 8
) (
    input clk,
    input sel,
    input [INPUT_SIZE*N_SA -1:0] data_a,
    output [INPUT_SIZE*N_SA -1:0] out_mux
);


  genvar i;
  generate
    for (i = 0; i < N_SA; i = i + 1) begin

	  wire sel1;
	  assign sel1=sel;
      mux_image #(
          .INPUT_SIZE(INPUT_SIZE)
      ) m1 (
          .clk(clk),
          .sel(sel1),
          .data_a(data_a[INPUT_SIZE*(N_SA-i)-1-:INPUT_SIZE]),
          .out_mux(out_mux[INPUT_SIZE*(N_SA-i)-1-:INPUT_SIZE])
      );

    end
  endgenerate
endmodule






module mux_image #(
    parameter INPUT_SIZE = 8
) (
    input clk,
    input sel,
    input [INPUT_SIZE -1:0] data_a,
    output reg [INPUT_SIZE-1:0] out_mux
);
//  assign out_mux=(sel)?8'd0:data_a;
  always @(*) begin
   case (sel)
     1'b0: out_mux <= data_a;
     1'b1: out_mux <= 8'd0;
     default:out_mux<=data_a;
   endcase
  end
endmodule
