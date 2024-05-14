module test_top#(
    parameter N=8,
    parameter DEPTH=512,
    parameter BURST_LENGTH=15,
    parameter BURST_LENGTH_2 =15,
    parameter IMAG_DIM_OUTPUT =128,
    parameter IMAG_DIM_ACC=32,
    parameter AXI_DATA_BYTES=32 ,
    parameter ADDR_WIDTH=32
)(
    input clkin,
    input i_start,
    output [7:0] o_address,
    output o_valid,
    output o_last
);

wire [79:0]ff_occupants;
wire [7:0]burst_length_acc;
wire fifo_read;
wire image_done;
wire memory_request;
wire memory_acknowledgement;
wire [31:0]acc_address;
wire [31:0]op_address;
wire acc_valid;
wire op_valid;
wire dram_start;
wire dram_last;
wire image_done_op;
wire [7:0]burst_length_op;
wire [7:0]o_burst_len;

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
    .i_acc_address(32'h00001000),
    .i_op_start(32'h00F01000),
    .i_channel_itr(12'd3),
    .i_kernel_itr(12'd4),
    .i_imag_dim(16'd56),
    .i_imag_dim_2(16'd8),
    .slave_valid(dram_start),
    .occupants(ff_occupants),
    .last(dram_last),
    .acc_address(acc_address),
    .o_op_start_add(op_address),
    .acc_address_valid(acc_valid),
    .op_valid_1(op_valid),
    .memory_request(memory_request),
    .o_burst_length(burst_length_acc),
    .o_burst_length_2(burst_length_op),
    .o_image_done(image_done),
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
    .o_address(o_address),
    .o_valid(o_valid),
    .o_burst_len(o_burst_len),
    .last(o_last)
);

occupants_controller occupants_ctrl(
    .clkin(clkin),
    .image_done(image_done),
    .image_done_2(image_done_op),
    .fifo_read(fifo_read),
    .burst_length(burst_length_acc),
    .burst_length_2(burst_length_op),
    .occupants(ff_occupants)
);

memory_controller mem_controller(
    .clkin(clkin),
    .memory_request(memory_request),
    .memory_acknowledgement(memory_acknowledgement)
);

one_pulse_generator one_pulse(
    .clkin(clkin),
    .signal(i_start),
    .pulse_signal(dram_start)
);

fifo_data_axi data_axi(
    .clkin(clkin),
    .burst_length(o_burst_len),
    .memory_acknowledgement(memory_acknowledgement),
    .last(dram_last),
    .read_enable(fifo_read)
);
endmodule