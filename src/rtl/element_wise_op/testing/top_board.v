module top_board#(
    parameter INPUT_WIDTH=16,
    parameter NUMBER_OP=3
)(
    input clkin,
    input user_start,
    output [31:0]value_out,
    output value_valid,
    output [3:0]value_strobe
);
wire burst_read_trigger;
wire [36:0]test_data;
element_wise_op #(
    .INPUT_WIDTH(INPUT_WIDTH),
    .NUMBER_OP(NUMBER_OP)
)calc_module(
    .clkin(clkin),
    .input_a(test_data[36:21]),
    .input_a_v(test_data[20]),
    .input_b(test_data[19:4]),
    .input_b_v(test_data[3]),
    .operation_in(test_data[2:1]),
    .operation_v(test_data[0]),
    .value_out(value_out),
    .value_valid(value_valid),
    .value_strobe(value_strobe)
);

memory_mod memory_module(
    .clkin(clkin),
    .burst_read_trigger(burst_read_trigger),
    .test_data(test_data)
    );

one_pulse_generator one_pulse(
    .clkin(clkin),
    .signal(user_start),
    .pulse_signal(burst_read_trigger)
);


endmodule