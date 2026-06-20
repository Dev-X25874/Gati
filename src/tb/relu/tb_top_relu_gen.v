`timescale 1ns/1ps
`define GEN_LEAKY_RELU
`include "../../rtl/common/instructions.vh"
`include "../../rtl/relu/relu_w_gen.v"

// Testbench for top_relu_gen:
//  Phase 1 - drives two lanes with independently configured i_act_type
//            values (RELU on lane 0, CLIP on lane 1) to exercise the
//            per-lane top_i_acttype[i*ACT_TYPE_WIDTH +: ACT_TYPE_WIDTH]
//            part-select.
//  Phase 2 - steady-state Leaky ReLU on lane 0 (negative and positive
//            inputs), lane 1 continues independently on CLIP.
//  Phase 3 - lane 0 switches act_type from LEAKYRELU to RELU on the very
//            next cycle (back-to-back instructions with no idle cycle).
//            A posedge-clocked capture register models how a real
//            downstream consumer samples o_data whenever o_valid is
//            high, which is exactly where the act_type race would be
//            observed.
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

  // convenience views onto lane 0 / lane 1
  wire signed [DATA_WIDTH-1:0] lane0_o_data = top_o_data[0+:DATA_WIDTH];
  wire signed [DATA_WIDTH-1:0] lane1_o_data = top_o_data[DATA_WIDTH+:DATA_WIDTH];

  // Downstream-consumer model: captures lane0's output exactly the way a
  // real pipeline stage would - synchronously, whenever o_valid is high.
  reg signed [DATA_WIDTH-1:0] captured_lane0;
  always @(posedge top_clk) begin
    if (top_o_valid[0]) captured_lane0 <= lane0_o_data;
  end

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

    // ---- Phase 1: RELU (lane 0) / CLIP (lane 1) ----
    top_i_acttype = {4'(`ACT_CLIP), 4'(`ACT_RELU)};
    top_i_clip    = {8'd10, 8'd0};

    @(negedge top_clk);
    // Lane 0: negative input -> expect 0. Lane 1: 50 > clip(10) -> expect 10.
    top_i_data  = {32'sd50, -32'sd5};
    top_i_valid = 2'b11;

    @(negedge top_clk);
    $display("[Phase1] lane0(relu) o_data=%0d (expect 0)   lane1(clip10) o_data=%0d (expect 10)",
              lane0_o_data, lane1_o_data);
    // Lane 0: positive input -> expect passthrough. Lane 1: 4 < clip(10) -> expect 4.
    top_i_data  = {32'sd4, 32'sd20};
    top_i_valid = 2'b11;

    @(negedge top_clk);
    $display("[Phase1] lane0(relu) o_data=%0d (expect 20)  lane1(clip10) o_data=%0d (expect 4)",
              lane0_o_data, lane1_o_data);

    // ---- Phase 2: steady-state Leaky ReLU on lane 0, CLIP keeps running on lane 1 ----
    top_i_acttype     = {4'(`ACT_CLIP), 4'(`ACT_LEAKYRELU)};
    top_lr_neg_alpha  = {{(N-1){10'd0}}, 10'd26};   // lane0 neg alpha ~ 0.1 in Q8 (26/256)
    top_lr_pos_alpha  = {{(N-1){10'd0}}, 10'd256};  // lane0 pos alpha = 1.0 in Q8 (identity)
    top_i_data        = {32'sd4, -32'sd1000};
    top_i_valid       = 2'b11;

    @(negedge top_clk);
    $display("[Phase2] lane0(leaky,-1000) o_data=%0d (expect ~-102, steady-state)", lane0_o_data);
    top_i_data  = {32'sd4, 32'sd1000};
    top_i_valid = 2'b11;

    @(negedge top_clk);
    $display("[Phase2] lane0(leaky,+1000) o_data=%0d (expect 1000, identity alpha)", lane0_o_data);

    // ---- Phase 3: lane 0 commits a leaky result, then act_type flips to
    //      RELU for the very next cycle (no idle cycle in between). The
    //      capture register samples o_data at the posedge immediately
    //      following the act_type switch - exactly where the race bites.
    top_i_data  = {32'sd4, -32'sd2000};
    top_i_valid = 2'b11;

    @(negedge top_clk);
    // o_valid is high for the -2000 leaky result right now; act_type
    // switches to RELU for the *next* instruction in this same step.
    top_i_acttype = {4'(`ACT_CLIP), 4'(`ACT_RELU)};
    top_i_data    = {32'sd4, 32'sd77};
    top_i_valid   = 2'b11;

    @(negedge top_clk);
    $display("[Phase3] downstream capture of leaky(-2000) result = %0d (expect ~-204)", captured_lane0);
    $display("[Phase3] lane0(relu,77) committed o_data=%0d (expect 77)", lane0_o_data);

    top_i_valid = 2'b00;

    @(negedge top_clk);
    $finish;
  end

endmodule
