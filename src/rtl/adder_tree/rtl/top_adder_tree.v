module top_adder_tree_gen #(
    parameter W_PSUM = 20,
    parameter COL = 4,
    parameter N_SA = NSA_DSP + NSA_LUT,
    parameter NSA_DSP = 2,
    parameter NSA_LUT = 2,
    parameter DATA_WIDTH_OB = 32
)(
    input clk,
    input rst,
    input [(COL*W_PSUM)*N_SA-1:0] o_psum_ff_array,
    output [COL-1:0] valid_out,
    output [COL*N_SA-1:0] valid_in,
    output [(COL* DATA_WIDTH_OB) -1 : 0] result_final
);

genvar j;
  generate
    for (j = 0; j < N_SA / 2; j = j + 1) begin
      assign inp1[COL*W_PSUM*j +:COL*W_PSUM] = o_psum_ff_array[(COL*W_PSUM*(N_SA-2*j)) -1 -:COL*W_PSUM];
      assign inp2[COL*W_PSUM*j +:COL*W_PSUM] = o_psum_ff_array[(COL*W_PSUM*(N_SA-(2*j+1))) -1 -:COL*W_PSUM];
      assign valid_1[COL*j+:COL] = valid_in[(COL*(N_SA-(2*j)))-1-:COL];
      assign valid_2[COL*j+:COL] = valid_in[(COL*(N_SA-(2*j+1)))-1-:COL];
    end
  endgenerate

  wire [(N_SA/2)*W_PSUM*COL-1:0] inp1;
  wire [(N_SA/2)*W_PSUM*COL-1:0] inp2;
  wire [(N_SA/2)*COL-1:0] valid_1;
  wire [(N_SA/2)*COL-1:0] valid_2;

  adder_tree_gen #(
    .DATA_OUT_WIDTH(DATA_WIDTH_OB),
    .DATA_IN_WIDTH(W_PSUM),
    .UNIQUE_KERNELS(COL),
    .DESIGN_NO(N_SA)
) adder_tree_gen (
    .in1(inp1),
    .in2(inp2),
    .clk(clk),
    .rst(rst),
    .valid_in_1(valid_1),
    .valid_in_2(valid_2),
    .valid_out(valid_out),
    .result_final(result_final)
);
endmodule

module adder_tree_gen #(
    parameter DATA_OUT_WIDTH = 32,
    parameter DATA_IN_WIDTH = 20,
    parameter UNIQUE_KERNELS = 4,
    parameter DESIGN_NO = 4
) (
    input [(DATA_IN_WIDTH*UNIQUE_KERNELS*(DESIGN_NO/2)) -1 : 0] in1,
    input [(DATA_IN_WIDTH*UNIQUE_KERNELS*(DESIGN_NO/2)) -1 : 0] in2,
    input clk,
    input rst,
    input [UNIQUE_KERNELS*(DESIGN_NO/2) -1 : 0] valid_in_1,
    input [UNIQUE_KERNELS*(DESIGN_NO/2) -1 : 0] valid_in_2,
    output [UNIQUE_KERNELS-1 : 0] valid_out,
    output [(UNIQUE_KERNELS* DATA_OUT_WIDTH) -1 : 0] result_final
);

  wire [(DATA_IN_WIDTH*UNIQUE_KERNELS*(DESIGN_NO/2)) -1 : 0] temp;
  wire [(DATA_IN_WIDTH*UNIQUE_KERNELS*(DESIGN_NO/2)) -1 : 0] temp2;
  wire [UNIQUE_KERNELS*(DESIGN_NO/2) -1 : 0] valid_in_temp;

  wire [UNIQUE_KERNELS*(DESIGN_NO/2) -1 : 0] valid_in_temp2;

  genvar j, k;
  generate
    for (k = 0; k < UNIQUE_KERNELS; k = k + 1) begin
      for (j = 0; j < DESIGN_NO / 2; j = j + 1) begin
        assign temp[DATA_IN_WIDTH*j+((DESIGN_NO/2)*DATA_IN_WIDTH*k) +:DATA_IN_WIDTH]=in1[((DATA_IN_WIDTH*(UNIQUE_KERNELS*j))+(DATA_IN_WIDTH*k)) +:DATA_IN_WIDTH];
        assign temp2[DATA_IN_WIDTH*j + ((DESIGN_NO/2)*DATA_IN_WIDTH*k) +:DATA_IN_WIDTH]=in2[((DATA_IN_WIDTH*(UNIQUE_KERNELS*j))+(DATA_IN_WIDTH*k)) +:DATA_IN_WIDTH];
        assign valid_in_temp[j+((DESIGN_NO/2*k))+:1] = valid_in_1[((UNIQUE_KERNELS*j)+k)+:1];
        assign valid_in_temp2[j+((DESIGN_NO/2)*k)+:1] = valid_in_2[((UNIQUE_KERNELS*j)+k)+:1];
      end
    end
  endgenerate

  genvar i;
  generate
    for (i = 0; i < UNIQUE_KERNELS; i = i + 1) begin
      adder_tree #(
          .DATA_OUT_WIDTH(DATA_OUT_WIDTH),
          .DATA_IN_WIDTH(DATA_IN_WIDTH),
          .DESIGN_NO(DESIGN_NO),
          .UNIQUE_KERNELS(UNIQUE_KERNELS)
      )adder_tree (
          .clk(clk),
          .rst(rst),
          .valid_in_1(valid_in_temp[(UNIQUE_KERNELS/2)*i+:UNIQUE_KERNELS/2]),
          .valid_in_2(valid_in_temp2[(UNIQUE_KERNELS/2)*i+:UNIQUE_KERNELS/2]),
          .in2(temp2[(DATA_IN_WIDTH*UNIQUE_KERNELS/2)*i+:(DATA_IN_WIDTH*UNIQUE_KERNELS/2)]),
          .in1(temp[(DATA_IN_WIDTH*UNIQUE_KERNELS/2)*i+:(DATA_IN_WIDTH*UNIQUE_KERNELS/2)]),
          .adder_result(result_final[i*DATA_OUT_WIDTH+:DATA_OUT_WIDTH]),
          .valid_out(valid_out[i+:1])
      );
    end
  endgenerate
endmodule

module adder_tree #(
    parameter DATA_OUT_WIDTH = 21,
    parameter DATA_IN_WIDTH = 20,
    parameter HEIGHT = $clog2(DESIGN_NO),
    parameter DESIGN_NO = 8,
    parameter UNIQUE_KERNELS = 8
) (
    input [((DESIGN_NO/2)*DATA_IN_WIDTH) -1 : 0] in1,
    input [((DESIGN_NO/2)*DATA_IN_WIDTH)-1 : 0] in2,
    input [(DESIGN_NO/2)-1:0] valid_in_1,
    input [(DESIGN_NO/2) -1:0] valid_in_2,
    input clk,
    input rst,
    output valid_out,
    output [DATA_OUT_WIDTH -1 : 0] adder_result
);
parameter F_ENG = DESIGN_NO / 2;
parameter [4:0] CONS = 5'b00001;
parameter EXT = DATA_OUT_WIDTH - DATA_IN_WIDTH;
parameter LIMIT = $clog2(DESIGN_NO) - 1;
reg [$clog2(DESIGN_NO)-1:0] n = $clog2(DESIGN_NO);
wire [DATA_IN_WIDTH-1:0] result_final;
genvar i, j;

generate
    for (i = 0; i < HEIGHT; i = i + 1) begin : DEPTH
    for (j = 0; j < (F_ENG / (CONS << i)); j = j + 1) begin : LAYER
        wire valid_gen;
        wire [DATA_IN_WIDTH-1 : 0] result;
        if (i == 0) begin
            adder #(
              .WIDTH  (DATA_IN_WIDTH),
              .O_WIDTH(DATA_IN_WIDTH)
              ) dd1 (
              .clk(clk),
              .rst(rst),
              .first_k(in1[DATA_IN_WIDTH*j+:DATA_IN_WIDTH]),
              .second_k(in2[DATA_IN_WIDTH*j+:DATA_IN_WIDTH]),
              .valid_in_1(valid_in_1[j]),
              .valid_in_2(valid_in_2[j]),
              .result(result),
              .valid(valid_gen)
              );
        end 
        else begin
            if (i == LIMIT) begin
              adder #(
                .WIDTH  (DATA_IN_WIDTH),
                .O_WIDTH(DATA_IN_WIDTH)
                ) add1OUT (
                .clk(clk),
                .rst(rst),
                .second_k(DEPTH[i-1].LAYER[j*2].result),
                .first_k(DEPTH[i-1].LAYER[j*2+1].result),
                .valid_in_1(DEPTH[i-1].LAYER[j*2].valid_gen),
                .valid_in_2(DEPTH[i-1].LAYER[j*2+1].valid_gen),
                .result(result_final),
                .valid(valid_out)
                );
            end 
            else begin
              adder #(
                .WIDTH  (DATA_IN_WIDTH),
                .O_WIDTH(DATA_IN_WIDTH)
                ) add1d2 (
                .clk(clk),
                .rst(rst),
                .second_k(DEPTH[i-1].LAYER[j*2].result),
                .first_k(DEPTH[i-1].LAYER[j*2+1].result),
                .valid_in_1(DEPTH[i-1].LAYER[j*2].valid_gen),
                .valid_in_2(DEPelseTH[i-1].LAYER[j*2+1].valid_gen),
                .result(result),
                .valid(valid_gen)
                );
            end
        end
    end
    end
endgenerate

assign adder_result = {{EXT{result_final[DATA_IN_WIDTH-1]}}, result_final};

endmodule