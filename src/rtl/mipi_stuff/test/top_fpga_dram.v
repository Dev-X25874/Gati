module top_fpga_dram #(
parameter W_DATA = 8,
parameter W_ADDR = 8,
parameter ADDR_W = 32,
parameter DATA_SIZE = 20,
parameter BURST_LEN = 16,
parameter ID = 10)
(
input  clk,
input  rst,
input  [ADDR_W-1:0] i_addr,
input  [DATA_SIZE-1:0] i_data_size,
input  [ID-1:0] i_id,
input  dispatch_cpu,
input  layer_done,
input  start,
input  mipi_ready,
input  fifo_status,
input  data_last,
output [ID-1:0] o_id,
output read_write,
output o_valid,
output o_last,
output [$clog2(BURST_LEN)-1:0] o_blen,
output [W_ADDR-1:0] o_addr,
output [DATA_SIZE-1:0] o_data_size,
output o_req
);

wire [(ADDR_W+DATA_SIZE+ID)-1:0] w_combined;
wire [(ADDR_W+DATA_SIZE+ID)-1:0] combined;
wire wr_en;
wire rd_en;
wire empty_flag;
wire fifo_valid;
wire w_ready;
wire [ADDR_W-1:0] addr;
wire [DATA_SIZE-1:0] data_size;
wire request;

assign o_req = request;
assign o_data_size = data_size;


dispatch_flag_check #(.ADDR_W(ADDR_W), .DATA_SIZE(DATA_SIZE), .ID(ID)) dut1(
.clk(clk),
.rst(rst),
.i_addr(i_addr),
.i_data_size(i_data_size),
.i_id(i_id),
.dispatch_cpu(dispatch_cpu),
.layer_done(layer_done),
.i_start(start),
.o_combined(w_combined),
.r_valid(wr_en)
);

sync_fifo #(.W_ADDR(W_ADDR), .W_DATA(62)) dut2(
.clk_i(clk),
.a_rst_i(~rst),
.wr_en_i(wr_en),
.rd_en_i(rd_en),
.wdata(w_combined),
.rdata(combined),
.full_o(),
.empty_o(empty_flag),
.datacount_o(),
.o_valid(fifo_valid)
);

request_generator #(.ADDR_W(ADDR_W), .DATA_SIZE(DATA_SIZE), .ID(ID)) dut3(
.clk(clk),
.rst(rst),
.i_combined(combined),
.req_ready(w_ready),
.mipi_ready(mipi_ready),
.empty(empty_flag),
.fifo_valid(fifo_valid),
.o_rd_en(rd_en),
.o_addr(addr),
.o_data_size(data_size),
.o_id(o_id),
.o_valid_req(request)
);

mem_req_ctrl #(.ADDR_W(ADDR_W), .DATA_SIZE(DATA_SIZE), .BURST_LEN(BURST_LEN)) dut4(
.clk(clk),
.rst(rst),
.i_addr(addr),
.i_data_size(data_size),
.i_data_last(data_last),
.i_valid_req(request),
.fifo_status(fifo_status),
.o_ready(w_ready),
.read_write(read_write),
.valid(o_valid),
.last(o_last),
.o_addr(o_addr),
.o_blen(o_blen)
);

endmodule