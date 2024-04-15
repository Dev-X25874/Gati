module top_test #(parameter burst_length_out = 10, parameter occupancy_count = 40, parameter AXI_DATA_BYTES = 32) (
    input din,
    input clk,
    input rst,
    output dout
);

wire [7:0] d_out;
wire rx_valid;
wire [31:0] start_addr_fifo_in;
wire [31:0] start_addr_fifo_out;
wire [31:0] stop_addr_fifo_in;
wire [31:0] stop_addr_fifo_out;
wire [11:0] kernelitr_fifo_in;
wire [11:0] kernelitr_fifo_out;
wire config_start_con;
wire fifo_status_con;
wire [7:0] addr_out_con;
wire dv;
wire [$clog2(AXI_DATA_BYTES) : 0] burst_length_con;
wire valid_start_addr;
wire valid_stop_addr;
wire valid_kernelitr;
wire empty_start_addr;
wire empty_stp_addr;
wire empty_krnl_itr;
wire re_start_addr;
wire re_krnl_itr;
wire re_stp_addr;
wire valid;
wire re_rci;
wire [7:0] tx_din;

rx rx(
    .clk(clk),
    .din(din),
    .dout(d_out),
    .valid(rx_valid)
);

controller_concate controller_concate(
    .din(d_out),
    .rx_valid(rx_valid),
    .start_addr(start_addr_fifo_in),
    .stop_addr(stop_addr_fifo_in),
    .kernelitr(kernelitr_fifo_in),
    .clk(clk),
    .config_start(config_start_con),
    .valid_start_addr(valid_start_addr),
    .valid_stop_addr(valid_stop_addr),
    .valid_kernelitr(valid_kernelitr)
);

fifo_valid #(.DATA_WIDTH(32), .ADDR_WIDTH(5)) fifo_valid_start_addr(
    .clk(clk),
    .rst_n(rst),
    .data_in(start_addr_fifo_in),
    .we(valid_start_addr),
    .re(re_start_addr),
    .data_out(start_addr_fifo_out),
    .occupants(),
    .empty(empty_start_addr),
    .full(),
    .data_valid()
);

fifo_valid #(.DATA_WIDTH(12), .ADDR_WIDTH(5)) fifo_valid_kernelitr(
    .clk(clk),
    .rst_n(rst),
    .data_in(kernelitr_fifo_in),
    .we(valid_kernelitr),
    .re(re_krnl_itr),
    .data_out(kernelitr_fifo_out),
    .occupants(),
    .empty(empty_krnl_itr),
    .full(),
    .data_valid()
);

fifo_valid #(.DATA_WIDTH(32), .ADDR_WIDTH(5)) fifo_valid_stop_addr(
    .clk(clk),
    .rst_n(rst),
    .data_in(stop_addr_fifo_in),
    .we(valid_stop_addr),
    .re(re_stp_addr),
    .data_out(stop_addr_fifo_out),
    .occupants(),
    .empty(empty_stp_addr),
    .full(),
    .data_valid()
);

top_fifo_dram_mimic_con top_fifo_dram_mimic_con(
    .burst_length(burst_length_con),
    .clk(clk),
    .fifo_status(fifo_status_con)
);

request_controller_im2col request_controller_im2col(
    .start_addr(start_addr_fifo_out),
    .channelitr(),
    .kernelitr(kernelitr_fifo_out),
    .stop_addr(stop_addr_fifo_out),
    .config_start(config_start_con),
    .fifo_status(fifo_status_con), //occupancy check
    .clk(clk),
    .addr_out(addr_out_con),
    .wr_enable(),
    .valid(valid),
    .burst_length(burst_length_con)
);

fifo_valid #(.DATA_WIDTH(8), .ADDR_WIDTH(5)) fifo_valid_tx(
    .clk(clk),
    .rst_n(rst),
    .data_in(addr_out_con),
    .we(valid),
    .re(re_rci),
    .data_out(tx_din),
    .occupants(),
    .empty(empty_rci),
    .full(),
    .data_valid()
);

controller_fifo_tx controller_fifo_tx(
    .empty(empty_rci),
    .done(done_tx),
    .clk(clk),
    .dv_tx(dv),
    .re(re_rci) 
);
tx tx(
    .i_Rst_L(rst),
    .i_Clock(clk),
    .i_TX_DV(dv),
    .i_TX_Byte(tx_din), 
    .o_TX_Active(),
    .o_TX_Serial(dout),
    .o_TX_Done(done_tx)
);


assign re_start_addr = ~empty_start_addr;
assign re_stp_addr = ~empty_stp_addr;
assign re_krnl_itr = ~empty_krnl_itr;

endmodule