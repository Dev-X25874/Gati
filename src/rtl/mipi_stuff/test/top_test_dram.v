module top_test_dram #(
parameter ADDR_W = 32,
parameter DATA_SIZE = 20,
parameter ID = 10,
parameter W_DATA = 8,
parameter W_ADDR = 8,
parameter BURST_LEN = 16)

(
input  clk_in,
input  rstn,
input  dispatch_cpu,
input  mipi_ready,
output [ID-1:0] o_id,
output [$clog2(BURST_LEN)-1:0] o_blen,
output [W_ADDR-1:0] o_addr,
output read_write,
output o_valid,
output o_last,
output o_req,
output [DATA_SIZE-1:0] o_data_size
);

wire wr_en;
wire [(ADDR_W+DATA_SIZE+ID)-1:0] fifo_in;
wire [(ADDR_W+DATA_SIZE+ID)-1:0] fifo_out;
wire start;
wire rd_en;
wire emptyflag;
wire valid_done;
wire [ADDR_W-1:0] w_addr;
wire [DATA_SIZE-1:0] w_data_size;
wire [ID-1:0] w_id;
reg  [3:0] counter;
reg  data_last;
reg  fifo_status;

always @ (posedge clk_in) begin
if(!rstn) begin
data_last <= 0;
fifo_status <= 0;
end

else begin
if(o_last) begin
if(counter == 10) begin
data_last <= 1;
counter <= 0;
end
else begin
data_last <= 0;
counter <= counter + 1;
end
end

else begin
data_last <= 1;
counter <= 0;
end
end
end

test_data_ctrl dut1(
.clk(clk_in),
.rst(rstn),
.valid(wr_en),
.dout(fifo_in)
);

sync_fifo #(.W_DATA(62), .W_ADDR(W_ADDR)) dut2(
.a_rst_i(~rstn),
.clk_i(clk_in),
.wdata(fifo_in),
.rdata(fifo_out),
.o_valid(start),
.wr_en_i(wr_en),
.rd_en_i(rd_en),
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
.rd_en(rd_en)
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
.data_last(data_last),
.fifo_status(fifo_status),
.o_id(o_id),
.o_addr(o_addr),
.read_write(read_write),
.o_last(o_last),
.o_valid(o_valid),
.o_blen(o_blen),
.o_req(o_req),
.o_data_size(o_data_size)
);

endmodule