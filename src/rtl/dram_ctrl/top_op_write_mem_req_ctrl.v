module top_op_write_mem_req_ctrl#(
    parameter N = 8,
    parameter DEPTH = 512,
    parameter BURST_LENGTH = 15,
    parameter BURST_LENGTH_2 = 15,
    parameter IMAG_DIM_OUTPUT = 128,
    parameter IMAG_DIM_ACC = 32,
    parameter AXI_DATA_BYTES = 32,
    parameter ADDR_WIDTH = 32
)(
    input clkin,
    input i_start,
    input i_dram_last,
    input [31:0] i_acc_address,
    input [31:0] i_op_address,
    input [11:0] i_channel_iteration,
    input [11:0] i_kernel_iteration,
    input [15:0] i_image_dim_acc,
    input [15:0] i_image_dim_op,
    input [N*($clog2(DEPTH)+1)-1:0]ff_occupants,
    output memory_request,
    output image_done_acc,
    output image_done_op
);

wire [31:0] acc_address;
wire [31:0] op_address;
wire acc_valid;
wire op_valid;
wire [7:0] burst_length_acc;
wire [7:0] burst_length_op;

dram_controller#(
    .N(N),
    .DEPTH(DEPTH),
    .BURST_LENGTH(BURST_LENGTH),
    .BURST_LENGTH_2(BURST_LENGTH_2),
    .IMAG_DIM_ACC(IMAG_DIM_ACC),
    .IMAG_DIM_OUTPUT(IMAG_DIM_OUTPUT),
    .AXI_DATA_BYTES(AXI_DATA_BYTES)
)dram_ctrl(
    .clkin(clkin),
    .i_acc_address(i_acc_address),
    .i_op_start(i_op_address),
    .i_channel_itr(i_channel_iteration),
    .i_kernel_itr(i_kernel_iteration),
    .i_imag_dim(i_image_dim_acc),
    .i_imag_dim_2(i_image_dim_op),
    .slave_valid(i_start),
    .occupants(ff_occupants),
    .last(i_dram_last),
    .acc_address(acc_address),
    .o_op_start_add(op_address),
    .acc_address_valid(acc_valid),
    .op_valid_1(op_valid),
    .memory_request(memory_request),
    .o_burst_length(burst_length_acc),
    .o_burst_length_2(burst_length_op),
    .o_image_done(image_done_acc),
    .o_image_done_2(image_done_op)
);

axi_addr_generator#(
    .ADDR_WIDTH(ADDR_WIDTH)
)address_out(
    .clkin(clkin),
    .i_acc_address(acc_address),
    .i_op_address(op_address),
    .i_acc_address_valid(acc_valid),
    .i_op_address_valid(op_valid),
    .i_acc_burst_len(burst_length_acc),
    .i_op_burst_len(burst_length_op),
    .o_burst_len(o_burst_len),
    .o_address(o_address),
    .o_valid(o_valid),
    .last(o_last)
);
    
endmodule