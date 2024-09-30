module top_dram_cpu #(
parameter DATA_SIZE = 20,
parameter ID = 10,
parameter AXI_DATA_WIDTH = 256,
parameter CPU_DATA_WIDTH = 32,
parameter W_DATA = 8,
parameter W_ADDR = 8,
parameter N_FIFO = 1)
(
input  clk,
input  rst,
input  sel,
input  data_valid,
input  [AXI_DATA_WIDTH-1:0] data_in,
input  data_last,
input  valid_req,
input  [DATA_SIZE-1:0] i_data_size,
input  [ID-1:0] i_id,
input  config_done,
output ready,
output o_data_last,
output reg mipi_fifo_status
);

wire [AXI_DATA_WIDTH-1:0] fifo_in;
wire [AXI_DATA_WIDTH-1:0] fifo_out;
wire wr_en;
wire rd_en;
wire emptyflag;
wire fullflag;
wire fifo_valid;
wire [CPU_DATA_WIDTH-1:0] mipi_fifo_in;
wire mipi_wr_en;
wire [W_ADDR:0] datacount;

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


data_rd_ctrl #(.AXI_DATA_WIDTH(AXI_DATA_WIDTH), .N_FIFO(N_FIFO)) dut1(
.clk(clk),
.rst(rst),
.select(sel),
.i_data_valid(data_valid),
.i_data_last(data_last),
.i_dram_data(data_in),
.o_dram_data(fifo_in),
.o_dram_fifo_wren(wr_en),
.o_data_last(o_data_last)
);

sync_fifo #(.W_DATA(AXI_DATA_WIDTH), .W_ADDR(W_ADDR)) dram_fifo(
.a_rst_i(~rst),
.clk_i(clk),
.wdata(fifo_in),
.rdata(fifo_out),
.o_valid(fifo_valid),
.wr_en_i(wr_en),
.rd_en_i(rd_en),
.empty_o(emptyflag),
.full_o(),
.datacount_o()
);

mipi_formatter #(.AXI_DATA_WIDTH(AXI_DATA_WIDTH), .CPU_DATA_WIDTH(CPU_DATA_WIDTH), .DATA_SIZE(DATA_SIZE), .ID(ID)) dut2(
.clk(clk),
.rst(rst),
.valid_req(valid_req),
.i_data_size(i_data_size),
.i_id(i_id),
.config_done(config_done),
.empty(emptyflag),
.fifo_valid(fifo_valid),
.data_in(fifo_out),
.data_out(mipi_fifo_in),
.ready(ready),
.full(fullflag),
.valid(mipi_wr_en),
.rd_en(rd_en)
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