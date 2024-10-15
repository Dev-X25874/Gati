module top_fpga2cpu #(
parameter ADDR_W = 32, //AXI Address width
parameter DATA_SIZE = 20, //Input data_size width
parameter ID = 10, //Dispatch ID Width
parameter W_DATA = 8, //
parameter W_ADDR = 8,
parameter BURST_LEN = 16, //Default burst length
parameter BURST_LENGTH_WIDTH = 8,
parameter AXI_DATA_WIDTH = 256,
parameter CPU_DATA_WIDTH = 32,
parameter N_FIFO = 1, //Number of DRAM FIFOs
parameter MIPI_FIFO_DEPTH = 512,
parameter REQ_FIFO_DEPTH = 8
)

(
input  clk,
input  clk_81mhz,
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
output [7:0] o_addr,
output [BURST_LENGTH_WIDTH-1:0] o_blen,
input  sel,
input  [AXI_DATA_WIDTH-1:0] i_data_in,
input  i_data_last,
input  i_data_valid,
output dispatcher_busy,
// input  config_done,

input  mipi_rd_en,
output o_mipi_ready,
output [CPU_DATA_WIDTH-1:0] mipi_fifo_data_out,
output mipi_fifo_empty,
output mipi_fifo_almost_empty,
output [$clog2(MIPI_FIFO_DEPTH):0] mipi_rd_fifo_occupants,

output [DATA_SIZE-1:0] o_data_size_rah, // These two signals are for rah module
output o_valid_data_size_rah
);

localparam REQ_WIDTH = ADDR_W+DATA_SIZE+ID;

reg  mipi_fifo_status;
wire wr_en;
wire [REQ_WIDTH-1:0] w_combined;
wire rd_en;
wire empty_flag;
wire fifo_valid;
wire [REQ_WIDTH-1:0] combined;
wire w_ready;
wire mipi_ready;
wire request;
wire [ADDR_W-1:0] w_addr;
wire [DATA_SIZE-1:0] w_data_size;
wire [ID-1:0] w_id;
wire w_data_last;
wire [N_FIFO-1:0] dram_wr_en;
wire [AXI_DATA_WIDTH-1:0] fifo_in;
wire [AXI_DATA_WIDTH-1:0] fifo_out;
wire dram_rd_en;
wire dram_emptyflag;
wire dram_fifo_valid;
wire mipi_wr_en;
wire mipi_fifo_full;
wire [$clog2(MIPI_FIFO_DEPTH):0] mipi_fifo_occupants;
wire [CPU_DATA_WIDTH-1:0] mipi_fifo_data;
wire done;

assign o_mipi_ready = mipi_ready;
// Data size and valid for cvt32248 module to send data to rah
// Here, data size to rah = data size read from DRAM + SOP + EOP (24 bytes extra)
assign o_data_size_rah = w_data_size + 24;
assign o_valid_data_size_rah = request;

always @ (posedge clk) begin
if(!rst) begin
    mipi_fifo_status <= 0;
end
else begin
    if(mipi_fifo_occupants == 100) begin
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
.done(done),
.dispatcher_busy(dispatcher_busy),
.i_start(i_start),
.o_combined(w_combined),
.r_valid(wr_en)
);

sync_fifo #(.W_ADDR($clog2(REQ_FIFO_DEPTH)), .W_DATA(REQ_WIDTH)) dut2(
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

mem_req_ctrl #(.ADDR_W(ADDR_W), 
               .DATA_SIZE(DATA_SIZE), 
               .BURST_LEN(BURST_LEN),
               .AXI_BYTES(AXI_DATA_WIDTH/8),
               .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH)
               ) 
dut4(
.clk(clk),
.rst(rst),
.i_addr(w_addr),
.i_data_size(w_data_size),
.i_data_last(w_data_last),
.i_valid_req(request),
.fifo_status(mipi_fifo_status),
.o_ready(w_ready),
.done(done),
.read_write(read_write),
.valid(o_valid),
.last(o_last),
.o_addr(o_addr),
.o_blen(o_blen)
);

Mem_read_ctrl #(.AXI_DATA_WIDTH(AXI_DATA_WIDTH), .N_FIFO(N_FIFO)) dut5(
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
// .config_done(config_done),
.empty(dram_emptyflag),
.fifo_valid(dram_fifo_valid),
.data_in(fifo_out),
.data_out(mipi_fifo_data),
.ready(mipi_ready),
.full(mipi_fifo_full),
.valid(mipi_wr_en),
.rd_en(dram_rd_en)
);

async_81#(
    .W_DATA(CPU_DATA_WIDTH),
    .W_ADDR($clog2(MIPI_FIFO_DEPTH)),
    .OUTPUT_REG(0)
) fifo_inst (
    .full_o(mipi_fifo_full),
    .empty_o(mipi_fifo_empty),
    .almost_empty_o(mipi_fifo_almost_empty),
    .wr_clk_i(clk),
	.rd_clk_i(clk_81mhz),	
    .wr_en_i(mipi_wr_en),
    .rd_en_i(mipi_rd_en),
    .wdata(mipi_fifo_data),
    .wr_datacount_o(mipi_fifo_occupants),
    .rd_datacount_o(mipi_rd_fifo_occupants),
    .rst_busy(),
    .rdata(mipi_fifo_data_out),
    .a_rst_i(~rst),
    .o_valid()
);

endmodule