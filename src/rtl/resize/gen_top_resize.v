module gen_top_resize#(
    parameter AXI_DATA_BYTES = 32,
    parameter DATA_WIDTH = 8,
    parameter FIFO_NO = 32,
    parameter N_SA = 4,
    parameter RESIZE_IW_WIDTH = 10,
    parameter RESIZE_IH_WIDTH = 10,
    parameter RESIZE_IC_WIDTH = 12,
    parameter START_ADDRESS_W = 32,
    parameter END_ADDRESS_W = 32,
    parameter W_ADDR = 6,
    parameter MOD2 = 8
) (
  input                                 i_clk,
  input                                 i_rst,
  input [RESIZE_IW_WIDTH - 1 : 0]       i_resize_IW,
  input [RESIZE_IH_WIDTH - 1 : 0]       i_resize_IH,
  input                                 i_resize_start,
  input [(W_ADDR):0]                    i_fifo_occupants,
  input [AXI_DATA_BYTES*DATA_WIDTH-1:0] i_fifo_data,
  input [AXI_DATA_BYTES-1:0]            i_fifo_data_valid,
  input [AXI_DATA_BYTES-1:0]            i_fifo_empty,
   
  output [N_SA-1:0]                     o_valid,
  output [N_SA*DATA_WIDTH-1:0]          o_data_out,
  output [N_SA-1:0]                     o_busy,
  output [AXI_DATA_BYTES-1:0]           o_fifo_rden,
  output                                o_done
);

// Data width per channel = AXI_DATA_BYTES * DATA_WIDTH/N_SA
localparam SA_DATA_W = MOD2 * DATA_WIDTH;

wire [N_SA-1:0] w_done;
wire [N_SA-1:0] w_send_read;

assign o_done = & w_done;
dram_fifo_resize#(
    .AXI_DATA_BYTES(AXI_DATA_BYTES),
    .W_ADDR(W_ADDR),
    .N_SA(N_SA),
    .MOD2(MOD2),
    .RESIZE_IW_WIDTH(RESIZE_IW_WIDTH)
) inst_resize_fifo_ctrl (
    .i_fifo_occupants(i_fifo_occupants),
    .i_fifo_empty(i_fifo_empty),
    .i_resize_IW(i_resize_IW),
    .i_busy(o_busy),
    .o_fifo_rden(o_fifo_rden),
    .rst(i_rst),
    .clk(i_clk),
    .i_resize_start(i_resize_start),
    .i_resize_done(o_done),
    .i_send_read(&w_send_read)
);
// Generates N_SA resize blocks for channel-wise upsampling. 
genvar i;
generate
  for (i = 0; i < N_SA; i = i + 1) begin : GEN_RESIZE
    top_resize_block#(
      .AXI_DATA_BYTES(AXI_DATA_BYTES),
      .DATA_WIDTH(DATA_WIDTH),
      .FIFO_NO(FIFO_NO),
      .N_SA(N_SA),
      .RESIZE_IW_WIDTH(RESIZE_IW_WIDTH),
      .RESIZE_IH_WIDTH(RESIZE_IH_WIDTH),
      .RESIZE_IC_WIDTH(RESIZE_IC_WIDTH),
      .W_ADDR(W_ADDR),
      .MOD2(MOD2)
    ) resize_inst (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .i_resize_IW(i_resize_IW),
      .i_resize_IH(i_resize_IH),
      .i_data_valid(|i_fifo_data_valid),
      .i_data(i_fifo_data[((N_SA-i)*SA_DATA_W)-1 -: SA_DATA_W]),
      .i_resize_start(i_resize_start),
      .o_busy(o_busy[i]),
      .o_data(o_data_out[((N_SA-i)*DATA_WIDTH)-1 -: DATA_WIDTH]),
      .o_valid(o_valid[i]),
      .o_done(w_done[i]),
      .o_send_read(w_send_read[i])
    );
  end
endgenerate
endmodule
