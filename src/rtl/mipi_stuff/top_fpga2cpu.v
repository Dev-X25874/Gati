module top_fpga2cpu #(
parameter ADDR_W = 32,
parameter DATA_SIZE = 20,
parameter ID = 10,
parameter W_DATA = 8,
parameter W_ADDR = 8,
parameter BURST_LEN = 16,
parameter AXI_DATA_WIDTH = 256,
parameter CPU_DATA_WIDTH = 32,
parameter N_FIFO = 1)

(
input  clk,
input  rst,
input  [ADDR_W-1:0] i_addr,
input  [DATA_SIZE-1:0] i_data_size,
input  [ID-1:0] i_id,
input  dispatch_cpu,
input  layer_done,
input  i_start,
output read_write,
output o_valid,
output o_last,
output [W_ADDR-1:0] o_addr,
output [$clog2(BURST_LEN)-1:0] o_blen,
input  sel,
input  [AXI_DATA_WIDTH-1:0] i_data_in,
input  i_data_last,
input  i_data_valid,
input  config_done,
output o_mipi_ready
);

reg  mipi_fifo_status;
wire wr_en;
wire [(ADDR_W+DATA_SIZE+ID)-1:0] w_combined;
wire rd_en;
wire empty_flag;
wire fifo_valid;
wire [(ADDR_W+DATA_SIZE+ID)-1:0] combined;
wire w_ready;
wire mipi_ready;
wire request;
wire [ADDR_W-1:0] w_addr;
wire [DATA_SIZE-1:0] w_data_size;
wire [ID-1:0] w_id;
wire w_data_last;
wire dram_wr_en;
wire [AXI_DATA_WIDTH-1:0] fifo_in;
wire [AXI_DATA_WIDTH-1:0] fifo_out;
wire dram_rd_en;
wire dram_emptyflag;
wire dram_fifo_valid;
wire [CPU_DATA_WIDTH-1:0] mipi_fifo_in;
wire fullflag;
wire [W_ADDR:0] datacount;
wire mipi_wr_en;

assign o_mipi_ready = mipi_ready;

always @ (posedge clk) begin
if(!rst) begin
mipi_fifo_status <= 0;
end
else begin
if(datacount == 100) begin
mipi_fifo_status <= 1;
end
else begin
mipi_fifo_status <= 0;
end
end
end

dispatch_flag_check #(.ADDR_W(ADDR_W), .DATA_SIZE(DATA_SIZE), .ID(ID)) dut1(
.clk(clk),
.rst(rst),
.i_addr(i_addr),
.i_data_size(i_data_size),
.i_id(i_id),
.dispatch_cpu(dispatch_cpu),
.layer_done(layer_done),
.i_start(i_start),
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
.o_addr(w_addr),
.o_data_size(w_data_size),
.o_id(w_id),
.o_valid_req(request)
);

mem_req_ctrl #(.ADDR_W(ADDR_W), .DATA_SIZE(DATA_SIZE), .BURST_LEN(BURST_LEN)) dut4(
.clk(clk),
.rst(rst),
.i_addr(w_addr),
.i_data_size(w_data_size),
.i_data_last(w_data_last),
.i_valid_req(request),
.fifo_status(mipi_fifo_status),
.o_ready(w_ready),
.read_write(read_write),
.valid(o_valid),
.last(o_last),
.o_addr(o_addr),
.o_blen(o_blen)
);

data_rd_ctrl #(.AXI_DATA_WIDTH(AXI_DATA_WIDTH), .N_FIFO(N_FIFO)) dut5(
.clk(clk),
.rst(rst),
.select(sel),
.i_data_valid(i_data_valid),
.i_data_last(i_data_last),
.i_dram_data(i_data_in),
.o_dram_data(fifo_in),
.o_dram_fifo_wren(dram_wr_en),
.o_data_last(w_data_last)
);

sync_fifo #(.W_DATA(AXI_DATA_WIDTH), .W_ADDR(W_ADDR)) dram_fifo(
.a_rst_i(~rst),
.clk_i(clk),
.wdata(fifo_in),
.rdata(fifo_out),
.o_valid(dram_fifo_valid),
.wr_en_i(dram_wr_en),
.rd_en_i(dram_rd_en),
.empty_o(dram_emptyflag),
.full_o(),
.datacount_o()
);

mipi_formatter #(.AXI_DATA_WIDTH(AXI_DATA_WIDTH), .CPU_DATA_WIDTH(CPU_DATA_WIDTH), .DATA_SIZE(DATA_SIZE), .ID(ID)) dut6(
.clk(clk),
.rst(rst),
.valid_req(request),
.i_data_size(w_data_size),
.i_id(w_id),
.config_done(config_done),
.empty(dram_emptyflag),
.fifo_valid(dram_fifo_valid),
.data_in(fifo_out),
.data_out(mipi_fifo_in),
.ready(mipi_ready),
.full(fullflag),
.valid(mipi_wr_en),
.rd_en(dram_rd_en)
);

sync_fifo #(.W_DATA(CPU_DATA_WIDTH), .W_ADDR(W_ADDR)) mipi_fifo(
.a_rst_i(~rst),
.clk_i(clk),
.wdata(mipi_fifo_in),
.rdata(),
.o_valid(),
.wr_en_i(mipi_wr_en),
.rd_en_i(),
.empty_o(),
.full_o(fullflag),
.datacount_o(datacount)
);

endmodule