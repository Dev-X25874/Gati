module top_board(
    input clkin,
    input user_start,
    output random
);

wire read_1_3;
wire [7:0] address_1_2;
wire [255:0]instruct_2_1;
wire valid_3_6;
wire pulse_4_1;;
wire pulse_6_1;
wire pulse_5_2;
wire inst1_7_1;
wire inst2_7_1;
wire inst3_7_1;
wire inst4_7_1;
wire pulse_9_8;
wire [3:0]start_cmd_1_7;
wire [255:0]instruct_8_1;
wire read_1_9;
wire valid_8_1;
real_top box_1(
    .clkin(clkin),
    .user_start(pulse_4_1),
    .global_start(32'h00001000),
    .global_stop(32'h00001800),
    .valid(valid_8_1),
    .sel(1'b1),
    .instruction_data(instruct_8_1),
    .memory_read_r(read_1_3),
    .memory_valid(),
    .mem_address(address_1_2),
    .mem_last(random),
    .mem_burst_len(),
    .inst1(inst1_6_1),
    .inst2(inst2_6_1),
    .inst3(inst3_6_1),
    .inst4(inst4_6_1),
    .start_command(start_cmd_1_7)
);

/* what box_2(
    .re(pulse_5_2),
    .addr(address_1_2),
    .clk(clkin),
    .rdata_a(instruct_2_1)
); */

burst_mem_module box8(
    .clkin(clkin),
    .burst_read_trigger(pulse_9_8),
    .mem_instruction(instruct_8_1),
    .valid_signal(valid_8_1)
); 
/* one_clock_delay box_3(
    .clkin(clkin),
    .i_data(read_1_3),
    .o_data(valid_3_6)
);

one_pulse_generator box_6(
    .clkin(clkin),
    .signal(valid_3_6),
    .pulse_signal(pulse_6_1)
); */

one_pulse_generator box_4(
    .clkin(clkin),
    .signal(user_start),
    .pulse_signal(pulse_4_1)
);
//one_pulse_generator box_5(
//    .clkin(clkin),
//    .signal(read_1_3),
//    .pulse_signal(pulse_5_2)
//);

counter_ack_block box_7(
    .clkin(clkin),
    .trigger_start(start_cmd_1_7),
    .ack_conv(inst1_7_1),
    .ack_fc(inst2_7_1),
    .ack_tail(inst3_7_1),
    .ack_op(inst4_7_1)
);

one_pulse_generator box_9(
    .clkin(clkin),
    .signal(read_1_3),
    .pulse_signal(pulse_9_8)
);
endmodule