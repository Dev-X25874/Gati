module top_board#(
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
    input user_start,
    output chunk_address,
    output chunk_valid,
    output last_sig
);

wire [79:0]occupants_connect;
wire [7:0]burst_length;
wire fifo_read;
wire image_done;
wire memory_request;
wire memory_acknowledgement;
wire [31:0]acc_address;
wire [31:0]op_address;
wire acc_valid;
wire op_valid;
wire pulse_signal;
wire last_wire;
wire image_done_2;
wire [7:0]burst_length_2;
wire [7:0]o_burst_len;
dram_controller #(.N(N),
.DEPTH(DEPTH),
.BURST_LENGTH(BURST_LENGTH),
.BURST_LENGTH_2(BURST_LENGTH_2),
.IMAG_DIM_ACC(IMAG_DIM_ACC),
.IMAG_DIM_OUTPUT(IMAG_DIM_OUTPUT),
.AXI_DATA_BYTES(AXI_DATA_BYTES))dram_ctrl(
    .clkin(clkin),
    //input [255:0]instruction_data,
    //input instruction_valid,
    .i_acc_address(32'h00001000),
    .i_op_start(32'h00F01000),
    .i_channel_itr(12'd6),
    .i_kernel_itr(12'd6),
    .i_imag_dim(16'd196),
    .i_imag_dim_2(16'd56),
    .slave_valid(pulse_signal),
    .occupants(occupants_connect),
    //.memory_acknowledgement(memory_acknowledgement),
    .last(last_wire),
    .acc_address(acc_address),
    .op_start_add1(op_address),
    .acc_address_valid(acc_valid),
    .op_valid_1(op_valid),
    .memory_request(memory_request),
    .o_burst_length(burst_length),
    .o_burst_length_2(burst_length_2),
    .o_image_done(image_done),//only for testing
    .o_image_done_2(image_done_2)
);

axi_addr_generator #(.ADDR_WIDTH(ADDR_WIDTH))chunk_out(
    .clkin(clkin),
    .acc_address(acc_address),
    .op_address(op_address),
    .acc_address_valid(acc_valid),
    .op_valid(op_valid),
    .burst_len(burst_length),
    .burst_len_2(burst_length_2),
    .o_burst_len(o_burst_len),
    .chunk_address(chunk_address),
    .chunk_valid(chunk_valid),
    .last(last_sig)
);

occupants_sim occ_sim(
    .clkin(clkin),
    .image_done(image_done),
    .image_done_2(image_done_2),
    .fifo_read(fifo_read),
    .burst_length(burst_length),
    .burst_length_2(burst_length_2),
    .occupants(occupants_connect)
);

memory_controller_fake mem_fake(
    .clkin(clkin),
    .memory_request(memory_request),
    .memory_acknowledgement(memory_acknowledgement)
);

one_pulse_generator one_pulse(
    .clkin(clkin),
    .signal(user_start),
    .pulse_signal(pulse_signal)
);

fifo_data_axi data_axi(
    .clkin(clkin),
    .burst_length(o_burst_len),
    .memory_acknowledgement(memory_acknowledgement),
    .last(last_wire),
    .read_enable(fifo_read)
);
endmodule