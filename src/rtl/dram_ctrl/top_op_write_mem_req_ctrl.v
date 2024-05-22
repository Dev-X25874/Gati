module top_op_write_mem_req_ctrl#(
    parameter N = 8,
    parameter DEPTH = 512 ,
    parameter BURST_LENGTH = 15,
    parameter BURST_LENGTH_2 = 7,
    parameter BURST_LEN_WIDTH = 8,
    parameter NUMBER_ACC = 2,
    parameter NUMBER_OP = 8,
    parameter AXI_DATA_BYTES = 32,
    parameter ADDR_WIDTH = 32,
    parameter W_KERNEL_CNT = 16,
    parameter IMAGE_DIM_WIDTH = 16
)(
    input clkin,
    input i_rstn,
    input i_start,      //dram controller start
    input i_data_last,  //comes from DDR memory controller
    input [ADDR_WIDTH-1:0]i_acc_address,
    input [ADDR_WIDTH-1:0]i_op_start,
    input [W_KERNEL_CNT-1:0]i_channel_itr,
    input [W_KERNEL_CNT-1:0]i_kernel_itr,
    input [IMAGE_DIM_WIDTH-1:0]i_imag_dim,
    input [IMAGE_DIM_WIDTH-1:0]i_imag_dim_2,
    input [N*($clog2(DEPTH)+1)-1:0]occupants,
    output mem_req,
    output o_last,
    output img_done_acc,
    output img_done_op,
    output o_valid,
    output [7:0]o_address,
    output [7:0]o_burst_len,
    output o_read_write_req
);

wire [ADDR_WIDTH-1:0] acc_address;
wire [ADDR_WIDTH-1:0] op_address;
wire acc_valid;
wire op_valid;
wire [BURST_LEN_WIDTH-1:0] burst_len_acc;
wire [BURST_LEN_WIDTH-1:0] burst_len_op;


dram_controller#(
  .N(N),
  .DEPTH(DEPTH) ,
  .BURST_LENGTH(BURST_LENGTH),
  .BURST_LENGTH_2(BURST_LENGTH_2),
  .BURST_LEN_WIDTH(BURST_LEN_WIDTH),
  .NUMBER_ACC(NUMBER_ACC),
  .NUMBER_OP(NUMBER_OP),
  .AXI_DATA_BYTES(AXI_DATA_BYTES),
  .ADDR_WIDTH(ADDR_WIDTH),
  .W_KERNEL_CNT(W_KERNEL_CNT),
  .IMAGE_DIM_WIDTH(IMAGE_DIM_WIDTH)
)dram_ctrl (
  .clkin(clkin),
  .i_rstn(i_rstn),
  .i_acc_address(i_acc_address),
  .i_op_start(i_op_start),
  .i_channel_itr(i_channel_itr),
  .i_kernel_itr(i_kernel_itr),
  .i_imag_dim(i_imag_dim),
  .i_imag_dim_2(i_imag_dim_2),
  .slave_valid(i_start),
  .occupants(occupants),
  .last(i_data_last),
  .acc_address(acc_address),
  .o_op_start_add(op_address),
  .acc_address_valid(acc_valid),
  .op_valid_1(op_valid),
  .memory_request(mem_req),
  .o_burst_length(burst_len_acc),
  .o_burst_length_2(burst_len_op),
  .o_image_done(img_done_acc),
  .o_image_done_2(img_done_op)
);

axi_addr_generator#(
  .ADDR_WIDTH(ADDR_WIDTH)
)outptu_address(
  .clkin(clkin),
  .i_rstn(i_rstn),
  .i_acc_address(acc_address),
  .i_op_address(op_address),
  .i_acc_address_valid(acc_valid),
  .i_op_address_valid(op_valid),
  .i_acc_burst_len(burst_len_acc),
  .i_op_burst_len(burst_len_op),
  .o_address(o_address),
  .o_valid(o_valid),
  .o_burst_len(o_burst_len),
  .last(o_last),
  .o_read_write_req(o_read_write_req)
);

    
endmodule