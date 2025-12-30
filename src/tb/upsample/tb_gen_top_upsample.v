
`timescale 1ns/1ps
`include "../../rtl/up_sample/top_upsample_block.v"
`include "../../rtl/up_sample/gen_bram.v"
`include "../../rtl/up_sample/gen_top_upsample.v"
`include "../../rtl/up_sample/dram_fifo_resize.v"
`include "../../rtl/up_sample/bram_wr_ctrl.v"
`include "../../rtl/common/simple_dpram.v"
`include "../../rtl/up_sample/bram_rd_ctrl.v"

`timescale 1ns/1ps

module tb_gen_top_upsample;

  localparam AXI_DATA_BYTES = 32;
  localparam DATA_WIDTH     = 8;
  localparam N_SA           = 4;
  localparam MOD2           = 8;
  localparam W_ADDR         = 11;

  reg i_clk;
  reg i_rst;

  reg i_resize_start;
  reg [9:0] i_IW;
  reg [9:0] i_IH;

  reg [W_ADDR:0] i_fifo_occupants;
  reg [AXI_DATA_BYTES*DATA_WIDTH-1:0] i_fifo_data;
  reg [AXI_DATA_BYTES-1:0] i_fifo_data_valid;
  reg [AXI_DATA_BYTES-1:0] i_fifo_empty;

  wire [N_SA-1:0] o_valid;
  wire [N_SA*DATA_WIDTH-1:0] o_data_out;
  wire [N_SA-1:0] o_busy;
  wire [AXI_DATA_BYTES-1:0] o_fifo_rden;
  wire o_done;

  gen_top_upsample #(
    .AXI_DATA_BYTES(AXI_DATA_BYTES),
    .DATA_WIDTH(DATA_WIDTH),
    .N_SA(N_SA),
    .MOD2(MOD2),
    .W_ADDR(W_ADDR)
  ) dut (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_UPSample_IW(i_IW),
    .i_UPSample_IH(i_IH),
    .i_resize_start(i_resize_start),
    .i_fifo_occupants(i_fifo_occupants),
    .i_fifo_data(i_fifo_data),
    .i_fifo_data_valid(i_fifo_data_valid),
    .i_fifo_empty(i_fifo_empty),
    .o_valid(o_valid),
    .o_data_out(o_data_out),
    .o_busy(o_busy),
    .o_fifo_rden(o_fifo_rden),
    .o_done(o_done)
  );

  always #5 i_clk = ~i_clk;

  initial begin
     $dumpfile("gen_top_upsample.vcd");
    $dumpvars(0, tb_gen_top_upsample);

   i_clk = 0;
    i_rst = 0;
    i_resize_start = 0;

    i_IW = 8;
    i_IH = 8;

    i_fifo_occupants  = 16;
    i_fifo_data_valid = {AXI_DATA_BYTES{1'b1}};
    i_fifo_empty      = {AXI_DATA_BYTES{1'b0}};

i_fifo_data = {
  8'h1F, 8'h1E, 8'h1D, 8'h1C,
  8'h1B, 8'h1A, 8'h19, 8'h18,
  8'h17, 8'h16, 8'h15, 8'h14,
  8'h13, 8'h12, 8'h11, 8'h10,
  8'h0F, 8'h0E, 8'h0D, 8'h0C,
  8'h0B, 8'h0A, 8'h09, 8'h08,
  8'h07, 8'h06, 8'h05, 8'h04,
  8'h03, 8'h02, 8'h01, 8'h00
};
// #10 i_fifo_data_valid = 0;
    // i_fifo_data = {
    //   8'h44,8'h33,8'h22,8'h11,
    //   8'h44,8'h33,8'h22,8'h11,
    //   8'h44,8'h33,8'h22,8'h11,
    //   8'h44,8'h33,8'h22,8'h11,
    //   8'h44,8'h33,8'h22,8'h11,
    //   8'h44,8'h33,8'h22,8'h11,
    //   8'h44,8'h33,8'h22,8'h11,
    //   8'h44,8'h33,8'h22,8'h11
    // };

    #20;
    i_rst = 1;

    #20;
    i_resize_start = 1;
    
    #10;
    i_resize_start = 0;
    // i_fifo_data_valid = {AXI_DATA_BYTES{1'b1}};
    // #10;
    // i_fifo_data_valid = 0;
    // #100;
    // i_fifo_data_valid = 1;
    // #10;
    // i_fifo_data_valid = 0;
    # 5000;
    i_fifo_data_valid = 0;

    repeat (3000) @(posedge i_clk);
    $finish;
  end

endmodule
