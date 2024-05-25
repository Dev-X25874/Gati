module debug_top#(
    parameter N_FIFO = 8,
    parameter W_DATA = 32,
    parameter BURST_LEN = 15,
    parameter W_BURST_LEN = 8,
    parameter W_ADDR = 8,
    parameter AXI_BYTES = 32
)(
    input i_clk,
    input i_rstn,
    input i_trigger,
    output [(W_DATA * N_FIFO)-1 : 0] o_fifo_data,  //comes from fifo array
    output o_data_last, //comes from dram wr ctrl
    output o_data_valid, //comes from dram wr ctrl
    output req_wr_req_ctrl,
    output [7:0] address_wr_req_ctrl,
    output [W_BURST_LEN-1 : 0] burst_len_wr_req_ctrl,
    output last_wr_req_ctrl,
    output valid_wr_req_ctrl
);
wire [31:0] fifo_data;
wire fifo_dv;
wire in_trigger;
assign in_trigger = ~i_trigger;

data_mem_ctrl mem_file_controller(
    .clk(i_clk),
    .rst(i_rstn),
    .i_trigger(w_trigger),
    .data(fifo_data),
    .valid(fifo_dv)
);

wire w_trigger;
pulse_gen one_pulse_generator(
    .a(in_trigger),
    .i_rstn(i_rstn),
    .clk(i_clk),
    .b(w_trigger)
);

test_top#(
    .N_FIFO(N_FIFO),
    .W_DATA(W_DATA),
    .BURST_LEN(BURST_LEN),
    .W_BURST_LEN(W_BURST_LEN),
    .W_ADDR(W_ADDR),
    .AXI_BYTES(AXI_BYTES)
)mipi_controller_top(
    .i_clk(i_clk),
    .i_trigger(w_trigger),
    .i_rstn(i_rstn),
    .i_data_valid(fifo_dv),
    .i_data(fifo_data),
    .o_fifo_data(o_fifo_data),  //comes from fifo array
    .o_data_last(o_data_last), //comes from dram wr ctrl
    .o_data_valid(o_data_valid), //comes from dram wr ctrl
    .req_wr_req_ctrl(req_wr_req_ctrl),
    .address_wr_req_ctrl(address_wr_req_ctrl),
    .burst_len_wr_req_ctrl(burst_len_wr_req_ctrl),
    .last_wr_req_ctrl(last_wr_req_ctrl),
    .valid_wr_req_ctrl(valid_wr_req_ctrl)
);
    
endmodule
