module top_main_des_gen #(parameter DATA_OUT_WIDTH = 20, parameter DESIGN_NO = 8)(
    input [(DESIGN_NO * DATA_OUT_WIDTH)-1 :0] first_sa1_out,
    input [(DESIGN_NO * DATA_OUT_WIDTH)-1 :0] second_sa2_out,
    input [(DESIGN_NO * DATA_OUT_WIDTH)-1 :0] first_sa3_out,
    input [(DESIGN_NO * DATA_OUT_WIDTH)-1 :0] second_sa4_out,
    input [(DESIGN_NO * DATA_OUT_WIDTH)-1 :0] first_sa5_out,
    input [(DESIGN_NO * DATA_OUT_WIDTH)-1 :0] second_sa6_out,
    input [(DESIGN_NO * DATA_OUT_WIDTH)-1 :0] first_sa7_out,
    input [(DESIGN_NO * DATA_OUT_WIDTH)-1 :0] second_sa8_out,
    input [DESIGN_NO-1 : 0]valid,
    input clk,
    input rst,
    output[DESIGN_NO-1 : 0] empty,
    output[DESIGN_NO-1 : 0] re_en,
    output [(DESIGN_NO * DATA_OUT_WIDTH)-1 :0] dout
);

genvar i;
generate
  for(i = 0; i < DESIGN_NO; i = i+1) begin
    top_main_des #(.DATA_OUT_WIDTH(DATA_OUT_WIDTH)) top_main_des(
            .clk(clk),
            .rst(rst),
            .valid(valid[i]),
            .re_en(re_en[i]),
            .empty(empty[i]),
            .first_sa1_out(first_sa1_out[((DESIGN_NO-i)*DATA_OUT_WIDTH)-1 -: DATA_OUT_WIDTH]),
            .second_sa2_out(second_sa2_out[((DESIGN_NO-i)*DATA_OUT_WIDTH)-1 -: DATA_OUT_WIDTH]),
            .first_sa3_out(first_sa3_out[((DESIGN_NO-i)*DATA_OUT_WIDTH)-1 -: DATA_OUT_WIDTH]),
            .second_sa4_out(second_sa4_out[((DESIGN_NO-i)*DATA_OUT_WIDTH)-1 -: DATA_OUT_WIDTH]),
            .first_sa5_out(first_sa5_out[((DESIGN_NO-i)*DATA_OUT_WIDTH)-1 -: DATA_OUT_WIDTH]),
            .second_sa6_out(second_sa6_out[((DESIGN_NO-i)*DATA_OUT_WIDTH)-1 -: DATA_OUT_WIDTH]),
            .first_sa7_out(first_sa7_out[((DESIGN_NO-i)*DATA_OUT_WIDTH)-1 -: DATA_OUT_WIDTH]),
            .second_sa8_out(second_sa8_out[((DESIGN_NO-i)*DATA_OUT_WIDTH)-1 -: DATA_OUT_WIDTH])
    );
  end
endgenerate
endmodule


module top_main_des #(parameter DATA_OUT_WIDTH = 20, parameter DESIGN_NO = 8)(
    input [DATA_OUT_WIDTH-1 :0] first_sa1_out,
    input [DATA_OUT_WIDTH-1 :0] second_sa2_out,
    input [DATA_OUT_WIDTH-1 :0] first_sa3_out,
    input [DATA_OUT_WIDTH-1 :0] second_sa4_out,
    input [DATA_OUT_WIDTH-1 :0] first_sa5_out,
    input [DATA_OUT_WIDTH-1 :0] second_sa6_out,
    input [DATA_OUT_WIDTH-1 :0] first_sa7_out,
    input [DATA_OUT_WIDTH-1 :0] second_sa8_out,
    input valid,
    input clk,
    input rst,
    output empty,
    output re_en,
    output [DATA_OUT_WIDTH-1 :0] dout
  );

wire va1;
wire va2;
wire va3;
wire va4;
wire v_fi;
wire [DATA_OUT_WIDTH-1 :0] sa1_sa2;
wire [DATA_OUT_WIDTH-1 :0] sa3_sa4;
wire [DATA_OUT_WIDTH-1 :0] sa5_sa6;
wire [DATA_OUT_WIDTH-1 :0] sa7_sa8;
wire [DATA_OUT_WIDTH-1 :0] sub_add1;
wire [DATA_OUT_WIDTH-1 :0] sub_add2;
wire sub_va1;
wire sub_va2;
wire valid_tx;
wire [DATA_OUT_WIDTH-1 :0] result_final;


adder ad1(
    .clk(clk),
    .rst(rst),
    .first_k(first_sa1_out[17:0]),
    .second_k(second_sa2_out[17:0]),
    .result(sa1_sa2),
    .valid_in(va1)
);

adder ad2(
    .clk(clk),
    .rst(rst),
    .first_k(first_sa3_out[17:0]),
    .second_k(second_sa4_out[17:0]),
    .result(sa3_sa4),
    .valid_in(va2),
    .valid(sub_va1)
);

adder ad3(
    .clk(clk),
    .rst(rst),
    .first_k(first_sa5_out[17:0]),
    .second_k(second_sa6_out[17:0]),
    .result(sa5_sa6),
    .valid_in(va3)
);

adder ad4(
    .clk(clk),
    .rst(rst),
    .first_k(first_sa7_out[17:0]),
    .second_k(second_sa8_out[17:0]),
    .result(sa7_sa8),
    .valid_in(va4),
    .valid(sub_va2)
);

adder ad5(
    .clk(clk),
    .rst(rst),
    .first_k(sa1_sa2),
    .second_k(sa3_sa4),
    .result(sub_add1),
    .valid_in(sub_va1)
);

adder ad6(
    .clk(clk),
    .rst(rst),
    .first_k(sa5_sa6),
    .second_k(sa7_sa8),
    .result(sub_add2),
    .valid_in(sub_va2),
    .valid(v_fi)
);

adder ad7(
    .clk(clk),
    .rst(rst),
    .first_k(sub_add1),
    .second_k(sub_add2),
    .valid(valid_tx),
    .result(result_final),
    .valid_in(v_fi)
);

fifo_valid #(.DATA_WIDTH(20), .ADDR_WIDTH(10)) fifo(
    .clk(clk),
    .rst_n(rst),
    .we(valid_tx),
    .re(re_en),
    .data_in(result_final),
    .occupants(),
    .full(),
    .empty(empty),
    .data_out(dout),
    .data_valid()
);

endmodule