`timescale 1ns/1ps
`include "../../rtl/common/instructions.vh"
`include "../../rtl/relu/relu_w_gen.v"

// Testbench for top_relu_gen: drives two lanes with independently
// configured i_act_type values (RELU on lane 0, CLIP on lane 1) to
// exercise the per-lane top_i_acttype[i*ACT_TYPE_WIDTH +: ACT_TYPE_WIDTH]
// part-select.
module tb_top_relu_gen;

  localparam N              = 2;
  localparam DATA_WIDTH     = 32;
  localparam ACT_TYPE_WIDTH = 4;
  localparam CLIP_WIDTH     = 8;
  localparam LR_WIDTH       = 10;

  reg                          top_clk;
  reg  [N*DATA_WIDTH-1:0]      top_i_data;
  reg  [N-1:0]                 top_i_valid;
  reg                          relu_enable;
  reg  signed [N*LR_WIDTH-1:0] top_lr_neg_alpha;
  reg  signed [N*LR_WIDTH-1:0] top_lr_pos_alpha;
  wire [N*DATA_WIDTH-1:0]      top_o_data;
  wire [N-1:0]                 top_o_valid;
  reg  [N*CLIP_WIDTH-1:0]      top_i_clip;
  reg  [N*ACT_TYPE_WIDTH-1:0]  top_i_acttype;

  top_relu_gen #(
    .N(N),
    .DATA_WIDTH(DATA_WIDTH),
    .ACT_TYPE_WIDTH(ACT_TYPE_WIDTH),
    .CLIP_WIDTH(CLIP_WIDTH),
    .LR_NEG_ALPHA_WIDTH(LR_WIDTH),
    .LR_POS_ALPHA_WIDTH(LR_WIDTH)
  ) dut (
    .top_clk(top_clk),
    .top_i_data(top_i_data),
    .top_i_valid(top_i_valid),
    .relu_enable(relu_enable),
    .top_lr_neg_alpha(top_lr_neg_alpha),
    .top_lr_pos_alpha(top_lr_pos_alpha),
    .top_o_data(top_o_data),
    .top_o_valid(top_o_valid),
    .top_i_clip(top_i_clip),
    .top_i_acttype(top_i_acttype)
  );

  always #5 top_clk = ~top_clk;

  initial begin
    top_clk          = 0;
    $dumpfile("top_relu_gen.vcd");
    $dumpvars(0, tb_top_relu_gen);

    relu_enable      = 1;
    top_lr_neg_alpha = 0;
    top_lr_pos_alpha = 0;
    top_i_valid      = 0;
    top_i_data       = 0;

    // Lane 0 -> ACT_RELU, Lane 1 -> ACT_CLIP with clip = 10
    top_i_acttype = {4'(`ACT_CLIP), 4'(`ACT_RELU)};
    top_i_clip    = {8'd10, 8'd0};

    @(posedge top_clk);
    // Lane 0: negative input -> expect 0. Lane 1: 50 > clip(10) -> expect 10.
    top_i_data  = {32'sd50, -32'sd5};
    top_i_valid = 2'b11;

    @(posedge top_clk);
    // Lane 0: positive input -> expect passthrough. Lane 1: 4 < clip(10) -> expect 4.
    top_i_data  = {32'sd4, 32'sd20};
    top_i_valid = 2'b11;

    @(posedge top_clk);
    top_i_valid = 2'b00;

    #20;
    $finish;
  end

endmodule
