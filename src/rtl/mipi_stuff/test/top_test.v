module top_test #(
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
input clk_in,
input rstn,
input dispatch_cpu,
input config_done,
output o_mipi_ready
);

wire wen;
wire ren;
wire [(ADDR_W+DATA_SIZE+ID)-1:0] fifo_in;
wire [(ADDR_W+DATA_SIZE+ID)-1:0] fifo_out;
wire start;
wire valid_done;
wire mipi_ready;
wire w_data_last;
wire emptyflag;
wire [ADDR_W-1:0] w_addr;
wire [DATA_SIZE-1:0] w_data_size;
wire [ID-1:0] w_id;
wire [DATA_SIZE-1:0] mipi_data_size;
wire [ID-1:0] mipi_id;
wire ddr_last;
wire ddr_valid;
wire [$clog2(BURST_LEN)-1:0] ddr_blen;
wire mipi_req;
wire [W_ADDR-1:0] ddr_addr;
wire sel;
wire [AXI_DATA_WIDTH-1:0] dram_in;
wire fifo_status;
wire cpu_last;
wire cpu_valid;

assign o_mipi_ready = mipi_ready;

test_data_ctrl dut1(
.clk(clk_in),
.rst(rstn),
.valid(wen),
.dout(fifo_in)
);

sync_fifo #(.W_DATA(62), .W_ADDR(W_ADDR)) dut2(
.a_rst_i(~rstn),
.clk_i(clk_in),
.wdata(fifo_in),
.rdata(fifo_out),
.o_valid(start),
.wr_en_i(wen),
.rd_en_i(ren),
.empty_o(emptyflag),
.full_o(),
.datacount_o()
);

controller #(.ADDR_W(ADDR_W), .DATA_SIZE(DATA_SIZE), .ID(ID)) dut3(
.clk(clk_in),
.rst(rstn),
.din(fifo_out),
.empty(emptyflag),
.addr(w_addr),
.valid(valid_done),
.fifo_valid(start),
.id(w_id),
.data_size(w_data_size),
.rd_en(ren)
);

top_fpga_dram #(.ADDR_W(ADDR_W), .DATA_SIZE(DATA_SIZE), .ID(ID), .W_DATA(W_DATA), .W_ADDR(W_ADDR), .BURST_LEN(BURST_LEN)) dut4(
.clk(clk_in),
.rst(rstn),
.i_addr(w_addr),
.i_data_size(w_data_size),
.i_id(w_id),
.dispatch_cpu(dispatch_cpu),
.layer_done(valid_done),
.start(start),
.mipi_ready(mipi_ready),
.data_last(w_data_last),
.fifo_status(fifo_status),
.o_req(mipi_req),
.o_data_size(mipi_data_size),
.o_id(mipi_id),
.o_addr(ddr_addr),
.read_write(),
.o_last(ddr_last),
.o_valid(ddr_valid),
.o_blen(ddr_blen)
);

dram_logic #(.BURST_LEN(BURST_LEN), .AXI_DATA_WIDTH(AXI_DATA_WIDTH), .W_ADDR(W_ADDR)) dut5(
.clk(clk_in),
.rst(rstn),
.i_valid(ddr_valid),
.addr(ddr_addr),
.last(ddr_last),
.blen(ddr_blen),
.select(sel),
.data_last(cpu_last),
.o_valid(cpu_valid),
.data(dram_in)
);

top_dram_cpu #(.DATA_SIZE(DATA_SIZE), .ID(ID), .AXI_DATA_WIDTH(AXI_DATA_WIDTH), .CPU_DATA_WIDTH(CPU_DATA_WIDTH), .W_DATA(W_DATA), .W_ADDR(W_ADDR), .N_FIFO(N_FIFO)) dut6(
.clk(clk_in),
.rst(rstn),
.data_valid(cpu_valid),
.data_last(cpu_last),
.data_in(dram_in),
.config_done(config_done),
.sel(sel),
.valid_req(mipi_req),
.i_data_size(mipi_data_size),
.i_id(mipi_id),
.ready(mipi_ready),
.o_data_last(w_data_last),
.mipi_fifo_status(fifo_status)
);

endmodule