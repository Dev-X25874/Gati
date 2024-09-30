module top_test_cpu #(
parameter DATA_SIZE = 20,
parameter ID = 10,
parameter AXI_DATA_WIDTH = 256,
parameter CPU_DATA_WIDTH = 32,
parameter W_DATA = 8,
parameter W_ADDR = 8,
parameter N_FIFO = 1)

(
input clk_in,
input rstn,
input sel,
input data_last,
//input valid_req,
//input [DATA_SIZE-1:0] i_data_size,
//input [ID-1:0] i_id,
output ready,
output o_data_last,
output mipi_fifo_status
);

wire wen;
wire [AXI_DATA_WIDTH-1:0] dram_in;
reg  [DATA_SIZE-1:0] r_data_size;
reg  [ID-1:0] r_id;
reg  valid_req;
reg  [3:0] counter = 0;

always @ (posedge clk_in) begin
if(!rstn) begin
r_data_size <= 0;
r_id <= 0;
valid_req <= 0;
counter <= 0;
end
else begin
r_data_size <= 'd1000;
r_id <= 'd7;
if(counter == 7) begin 
valid_req <= 1'b1;
counter <= 0;
end
else begin
valid_req <= 0;
counter <= counter + 1;
end
end
end

mipi_data_ctrl dut1(
.clk(clk_in),
.rst(rstn),
.valid(wen),
.dout(dram_in)
);

top_dram_cpu #(.DATA_SIZE(DATA_SIZE), .ID(ID), .AXI_DATA_WIDTH(AXI_DATA_WIDTH), .CPU_DATA_WIDTH(CPU_DATA_WIDTH), .W_DATA(W_DATA), .W_ADDR(W_ADDR), .N_FIFO(N_FIFO)) dut2(
.clk(clk_in),
.rst(rstn),
.data_valid(wen),
.data_last(data_last),
.data_in(dram_in),
.sel(sel),
.valid_req(valid_req),
.i_data_size(r_data_size),
.i_id(r_id),
.ready(ready),
.o_data_last(o_data_last),
.mipi_fifo_status(mipi_fifo_status)
);

endmodule