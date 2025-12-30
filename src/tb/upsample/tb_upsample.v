`timescale 1ns/1ps
`include "../../rtl/up_sample/top_upsample_block.v"
`include "../../rtl/up_sample/gen_bram.v"
`include "../../rtl/up_sample/gen_top_upsample.v"
`include "../../rtl/up_sample/dram_fifo_resize.v"
`include "../../rtl/up_sample/bram_wr_ctrl.v"
`include "../../rtl/common/simple_dpram.v"


`timescale 1ns/1ps

module tb_top_upsample;

  localparam DATA_WIDTH = 8;
  localparam AXI_DATA_BYTES = 32;
  localparam N_SA = 4;
  localparam W_ADDR = 6;

  reg clk;
  reg rst;

  reg i_resize_start;
  reg i_data_valid;
  reg [9:0] i_IW;
  reg [9:0] i_IH;
  reg [(AXI_DATA_BYTES*DATA_WIDTH)/N_SA-1:0] i_data;

  wire o_busy;
  wire [DATA_WIDTH-1:0] o_data;
  wire o_valid;
  wire o_done;

  top_upsample_block #(
    .AXI_DATA_BYTES(AXI_DATA_BYTES),
    .DATA_WIDTH(DATA_WIDTH),
    .FIFO_NO(32),
    .N_SA(N_SA),
    .UPSAMPLE_IW_WIDTH(10),
    .UPSAMPLE_IH_WIDTH(10),
    .W_ADDR(W_ADDR)
  ) dut (
    .i_clk(clk),
    .i_rst(rst),
    .i_UPSample_IW(i_IW),
    .i_UPSample_IH(i_IH),
    .i_data_valid(i_data_valid),
    .i_data(i_data),
    .i_resize_start(i_resize_start),
    .o_busy(o_busy),
    .o_data(o_data),
    .o_valid(o_valid),
    .o_done(o_done)
  );

  always #5 clk = ~clk;

  initial begin
    clk = 0;
    $dumpfile("top_upsample.vcd");
    $dumpvars(0, tb_top_upsample);
    rst = 0;
    i_resize_start = 0;
    i_data_valid = 0;
    i_IW = 0;
    i_IH = 0;
    i_data = 0;

    #20;
    rst = 1;

    i_IW = 4;
    i_IH = 2;

    #10;
    i_resize_start = 1;
    #10;
    i_resize_start = 0;
    repeat (10) begin
    // Row 0: 01 02 03 04
    repeat (i_IW) begin
     @(posedge clk);
      i_data_valid = 1;
      i_data = {8'h04,8'h03,8'h02,8'h01,8'h00,8'h00,8'h00,8'h00};
    end
    end
    @(posedge clk);
    i_data_valid = 0;

    // Row 1: 11 12 13 14
    // repeat(10) @(posedge clk);
    // i_data_valid = 1;
    // i_data = {8'h14,8'h13,8'h12,8'h11,8'h00,8'h00,8'h00,8'h00};

    @(posedge clk);
    i_data_valid = 0;

    // wait(o_done);
    #2000;
    $finish;
  end

endmodule











// module tb_top_upsample_block;
//
//   localparam AXI_DATA_BYTES = 32;
//   localparam DATA_WIDTH     = 8;
//   localparam FIFO_NO        = 32;
//   localparam N_SA           = 4;
//   localparam W_ADDR         = 6;
//
//   reg clk;
//   reg rst;
//
//   reg i_data_valid;
//   reg i_resize_start;
//   reg [9:0] i_UPSample_IW;
//   reg [9:0] i_UPSample_IH;
//
//   reg [(AXI_DATA_BYTES*DATA_WIDTH)/N_SA - 1 : 0] i_data;
//
//   wire o_busy;
//   wire o_valid;
//   wire o_done;
//   wire [7:0] o_data;
//
//   /* clock */
//   always #5 clk = ~clk;
//
//   /* DUT */
//   top_upsample_block #(
//     .AXI_DATA_BYTES(AXI_DATA_BYTES),
//     .DATA_WIDTH(DATA_WIDTH),
//     .FIFO_NO(FIFO_NO),
//     .N_SA(N_SA),
//     .UPSAMPLE_IW_WIDTH(10),
//     .UPSAMPLE_IH_WIDTH(10),
//     .W_ADDR(W_ADDR)
//   ) dut (
//     .i_clk(clk),
//     .i_rst(rst),
//     .i_UPSample_IW(i_UPSample_IW),
//     .i_UPSample_IH(i_UPSample_IH),
//     .i_data_valid(i_data_valid),
//     .i_data(i_data),
//     .i_resize_start(i_resize_start),
//     .o_busy(o_busy),
//     .o_data(o_data),
//     .o_valid(o_valid),
//     .o_done(o_done)
//   );
//
//   /* stimulus */
//   initial begin
//     $dumpfile("top_upsample.vcd");
//     $dumpvars(0, tb_top_upsample_block);
//
//     clk = 0;
//     rst = 0;
//     i_data_valid = 0;
//     i_resize_start = 0;
//     i_data = 0;
//
//     i_UPSample_IW = 2;
//     i_UPSample_IH = 2;
//
//     /* reset */
//     #20;
//     rst = 1;
//     i_resize_start = 1;
//
//     /* ---- write row 0: E5 DD ---- */
//     // @(posedge clk);
//     i_data_valid = 1;
//     i_data = {8'hE5, 8'hDD, 48'h0};
//     #5;
//     i_data = {8'h61, 8'hf2, 48'h0};
//     #5;
//      i_data = {8'h61, 8'hf2, 48'h0};
//     #5;
//      i_data = {8'h61, 8'hf2, 48'h0};
//     #5;
//      i_data = {8'h61, 8'hf2, 48'h0};
//     #5;
//      i_data = {8'h61, 8'hf2, 48'h0};
//     #5;
//      i_data = {8'h61, 8'hf2, 48'h0};
//     #5;
//      i_data = {8'h61, 8'hf2, 48'h0};
//     #5;
//      i_data = {8'h61, 8'hf2, 48'h0};
//     #5;
//      i_data = {8'h61, 8'hf2, 48'h0};
//     #5;
//      i_data = {8'h61, 8'hf2, 48'h0};
//     #5;
//      i_data = {8'h61, 8'hf2, 48'h0};
//     #5;
//      i_data = {8'h61, 8'hf2, 48'h0};
//     #5;
//     i_data_valid = 0;
//
//     /* ---- observe output ---- */
//     repeat (40) begin
//       @(posedge clk);
//       if (o_valid)
//         $display("[%0t] OUT = %02X", $time, o_data);
//       if (o_done)
//         $display("[%0t] DONE", $time);
//     end
// #50;
//     $finish;
//   end
//
// endmodule
