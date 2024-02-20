module top_for_8_ins_gen #(parameter DATA_IN_WIDTH = 8, parameter DATA_OUT_WIDTH = 20, parameter DESIGN_NO = 8) (
    input clk,
    input rst,
    input [(DESIGN_NO-1) : 0] valid,
    input [DESIGN_NO-1:0] re_en
    input [(DESIGN_NO * DATA_IN_WIDTH)-1:0] din,
    output [(DESIGN_NO * DATA_OUT_WIDTH)-1:0] dout,
    output [(DESIGN_NO-1) :0] empty
);
genvar i;
generate 
    for(i = 0; i < DESIGN_NO; i = i + 1) begin
        top_for_8_ins #(.DATA_IN_WIDTH(DATA_IN_WIDTH), .DATA_OUT_WIDTH(DATA_OUT_WIDTH)) top_gen_8_ins(
            .clk(clk),
            .rst(rst),
            .valid(valid[i]),
            .re_en(re_en[i]),
            .empty(empty[i]),
            .din(din[((DESIGN_NO-i)*DATA_IN_WIDTH)-1 -: DATA_IN_WIDTH]),
            .dout(dout[((DESIGN_NO-i)*DATA_OUT_WIDTH)-1 -: DATA_OUT_WIDTH])
        );
    end
endgenerate
endmodule


module top_for_8_ins #(parameter DATA_IN_WIDTH = 8, parameter DATA_OUT_WIDTH = 20) (
    input clk,
    input rst,
    input [DATA_IN_WIDTH-1:0] din,
    input valid,
    input re_en,
    output [DATA_OUT_WIDTH-1:0] dout
    output empty
);

wire [7:0] con_in;
wire con_valid;
wire [23:0] first_sa1;
wire [23:0] second_sa2;
wire [23:0] first_sa3;
wire [23:0] second_sa4;
wire [23:0] first_sa5;
wire [23:0] second_sa6;
wire [23:0] first_sa7;
wire [23:0] second_sa8;
wire [23:0] first_sa1_out;
wire [23:0] second_sa2_out;
wire [23:0] first_sa3_out;
wire [23:0] second_sa4_out;
wire [23:0] first_sa5_out;
wire [23:0] second_sa6_out;
wire [23:0] first_sa7_out;
wire [23:0] second_sa8_out;
wire valid_tx;
wire [19:0] result_final;
wire [19:0] sa1_sa2;
wire [19:0] sa3_sa4;
wire [19:0] sa5_sa6;
wire [19:0] sa7_sa8;
wire [19:0] sub_add1;
wire [19:0] sub_add2;
wire va_f1;;
wire va_f2;
wire va_f3;
wire va_f4;
wire va_f5;
wire va_f6;
wire va_f7;
wire va_f8;
wire sub_va1;
wire sub_va2;
wire v_fi;
wire re_tx;
wire empty;
wire empty1;
wire empty2;
wire empty3;
wire empty4;
wire empty5;
wire empty6;
wire empty7;
wire empty8;
wire re;
wire va1;
wire va2;
wire va3;
wire va4;

controller con(
    .clk(clk),
    .d_in(din),
    .valid(valid),
    .dout_sa1(first_sa1),
    .dout_sa2(second_sa2),
    .dout_sa3(first_sa3),
    .dout_sa4(second_sa4),
    .dout_sa5(first_sa5),
    .dout_sa6(second_sa6),
    .dout_sa7(first_sa7),
    .dout_sa8(second_sa8),
    .valid_out_sa1(va_f1),
    .valid_out_sa2(va_f2),
    .valid_out_sa3(va_f3),
    .valid_out_sa4(va_f4),
    .valid_out_sa5(va_f5),
    .valid_out_sa6(va_f6),
    .valid_out_sa7(va_f7),
    .valid_out_sa8(va_f8)
);

fifo_valid #(.DATA_WIDTH(20), .ADDR_WIDTH(5)) f1(
    .clk(clk),
    .rst_n(rst),
    .we(va_f1),
    .re(re),
    .data_in(first_sa1),
    .occupants(),
    .full(),
    .empty(empty1),
    .data_out(first_sa1_out),
    .data_valid()
);

fifo_valid #(.DATA_WIDTH(20), .ADDR_WIDTH(5)) f2(
    .clk(clk),
    .rst_n(rst),
    .we(va_f2),
    .re(re),
    .data_in(second_sa2),
    .occupants(),
    .full(),
    .empty(empty2),
    .data_out(second_sa2_out),
    .data_valid(va1)
);

fifo_valid #(.DATA_WIDTH(20), .ADDR_WIDTH(5)) f3(
    .clk(clk),
    .rst_n(rst),
    .we(va_f3),
    .re(re),
    .data_in(first_sa3),
    .occupants(),
    .full(),
    .empty(empty3),
    .data_out(first_sa3_out),
    .data_valid()
);

fifo_valid #(.DATA_WIDTH(20), .ADDR_WIDTH(5)) f4(
    .clk(clk),
    .rst_n(rst),
    .we(va_f4),
    .re(re),
    .data_in(second_sa4),
    .occupants(),
    .full(),
    .empty(empty4),
    .data_out(second_sa4_out),
    .data_valid(va2)
);

fifo_valid #(.DATA_WIDTH(20), .ADDR_WIDTH(5)) f5(
    .clk(clk),
    .rst_n(rst),
    .we(va_f5),
    .re(re),
    .data_in(first_sa5),
    .occupants(),
    .full(),
    .empty(empty5),
    .data_out(first_sa5_out),
    .data_valid()
);

fifo_valid #(.DATA_WIDTH(20), .ADDR_WIDTH(5)) f6(
    .clk(clk),
    .rst_n(rst),
    .we(va_f6),
    .re(re),
    .data_in(second_sa6),
    .occupants(),
    .full(),
    .empty(empty6),
    .data_out(second_sa6_out),
    .data_valid(va3)
);

fifo_valid #(.DATA_WIDTH(20), .ADDR_WIDTH(5)) f7(
    .clk(clk),
    .rst_n(rst),
    .we(va_f7),
    .re(re),
    .data_in(first_sa7),
    .occupants(),
    .full(),
    .empty(empty7),
    .data_out(first_sa7_out),
    .data_valid()
);

fifo_valid #(.DATA_WIDTH(20), .ADDR_WIDTH(5)) f8(
    .clk(clk),
    .rst_n(rst),
    .we(va_f8),
    .re(re),
    .data_in(second_sa8),
    .occupants(),
    .full(),
    .empty(empty8),
    .data_out(second_sa8_out),
    .data_valid(va4)
);

assign re = ((~empty8));

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