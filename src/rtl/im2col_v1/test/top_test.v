module top_test #(
parameter KERNEL_SIZE = 4,
parameter LOWER_BOUND = 1,
parameter UPPER_BOUND = 224,
parameter STRIDE = 3,
parameter W_ADDR = 8,
parameter W_DATA = 8,
parameter DATA_WIDTH = 8)
//parameter CLKS_PER_BIT = 868)

(
input  clk_in,
input  rstn,
//input  i_RX_Serial,
//output o_TX_Serial
input i_im2col_start,
output o_valid,
output [DATA_WIDTH-1:0] o_data,
output [(KERNEL_SIZE*KERNEL_SIZE)-1:0] valid_sq
);

wire dv;
wire [DATA_WIDTH-1:0] byte;
wire ren;
wire [DATA_WIDTH-1:0] rx_data;
wire valid_buff;
wire [DATA_WIDTH-1:0] mat_size;
wire mat_valid;
wire datavalid;
wire [3:0] zero_pad;
wire [1:0] zero_padded;
wire [DATA_WIDTH-1:0] data;
wire [$clog2(STRIDE):0]stride;
wire emptyflag;
wire i_im2col_start_index;
wire [2:0] w_ksize;


test_data_ctrl data_dut(
.clk(clk_in),
.rst(rstn),
.valid(dv),
.dout(byte)
);


sync_fifo #(.W_ADDR(W_ADDR), .W_DATA(W_DATA)) fifo_dut(
.clk_i(clk_in),
.a_rst_i(~rstn),
.wr_en_i(dv),
.rd_en_i(ren),
.full_o(),
.empty_o(emptyflag),
.wdata(byte),
.rdata(rx_data),
.datacount_o()
);

rd_ctrl #(.DATA_WIDTH(DATA_WIDTH), .STRIDE(STRIDE)) ctrl_dut(
.clk(clk_in),
.rst(rstn),
.fifo_data(rx_data),
.empty(emptyflag),
.im2col_start(i_im2col_start),
.i_valid_buff(valid_buff),
.valid_mat_size(mat_valid),
.valid_data(datavalid),
.mat_size(mat_size),
.zero_pad(zero_pad),
.zero_padded(zero_padded),
.rd_en(ren),
.i_data(data),
.ksize(w_ksize),
.stride(stride),
.i_im2col_start_index(i_im2col_start_index)
);

top_im2col #(.KERNEL_SIZE(KERNEL_SIZE), .DATA_WIDTH(DATA_WIDTH), .LOWER_BOUND(LOWER_BOUND), .UPPER_BOUND(UPPER_BOUND), .STRIDE(STRIDE)) top_dut(
.i_clk(clk_in),
.rstn(rstn),
.valid_mat_size(mat_valid),
.i_start_im2col_index(i_im2col_start_index),
.i_valid_data(datavalid),
.i_data(data),
.zero_pad(zero_pad),
.zero_padded(zero_padded),
.i_mat_size(mat_size),
.valid_sq(valid_sq),
.ksize(w_ksize),
.o_valid(o_valid),
.stride(stride),
.valid_sq_data_o(o_data),
.o_valid_buff(valid_buff)
);


endmodule