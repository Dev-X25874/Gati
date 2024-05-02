module top_board(
    input clkin,
    input user_start,
    output chunk_address,
    output chunk_valid,
    output last_sig
);

wire [79:0]occupants_connect;
wire [10:0]burst_length;
wire fifo_read;
wire image_done;
wire memory_request;
wire memory_acknowledgement;
wire [31:0]acc_address;
wire [31:0]op_address;
wire acc_valid;
wire op_valid;
wire pulse_signal;

dram_controller dram_ctrl(
    .clkin(clkin),
    //input [255:0]instruction_data,
    //input instruction_valid,
    .i_acc_address(32'h00001000),
    .i_op_start(32'h00F01000),
    .i_channel_itr(12'd4),
    .i_kernel_itr(12'd3),
    .i_imag_dim(16'd128),
    .slave_valid(pulse_signal),
    .occupants(occupants_connect),
    .memory_acknowledgement(memory_acknowledgement),
    .acc_address(acc_address),
    .op_start_add1(op_address),
    .acc_address_valid(acc_valid),
    .op_valid_1(op_valid),
    .memory_request(memory_request),
    .o_burst_length(burst_length),
    .o_image_done(image_done),//only for testing
    .fifo_read(fifo_read)

);

chunk_generator chunk_out(
    .clkin(clkin),
    .acc_address(acc_address),
    .op_address(op_address),
    .acc_address_valid(acc_valid),
    .op_valid(op_valid),
    .chunk_address(chunk_address),
    .chunk_valid(chunk_valid),
    .last(last_sig)
);

occupants_sim occ_sim(
    .clkin(clkin),
    .image_done(image_done),
    .fifo_read(fifo_read),
    .burst_length(burst_length),
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
endmodule