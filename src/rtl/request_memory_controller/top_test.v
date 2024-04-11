module top_test(
    input din,
    input clk,
    input rst,
    output dout
);

wire [7:0] d_out;
wire rx_valid;
wire [31:0] start_addr_con;
wire [31:0] stop_addr_con;
wire [11:0] kernelitr_con;
wire config_start_con;
wire fifo_status_con;
wire [7:0] addr_out_con;
wire dv;

rx rx(
    .clk(clk),
    .din(din),
    .dout(d_out),
    .valid(rx_valid)
);

controller_concate controller_concate(
    .din(d_out),
    .rx_valid(rx_valid),
    .start_addr(start_addr_con),
    .stop_addr(stop_addr_con),
    .kernelitr(kernelitr_con),
    .clk(clk),
    .config_start(config_start_con)
);

top_fifo_dram_mimic_con top_fifo_dram_mimic_con(
    .addr_out(addr_out_con),
    .clk(clk),
    .fifo_status(fifo_status_con)
);

request_controller_im2col request_controller_im2col(
    .start_addr(start_addr_con),
    .channelitr(),
    .kernelitr(kernelitr_con),
    .stop_addr(stop_addr_con),
    .config_start(config_start_con),
    .fifo_status(fifo_status_con), //occupancy check
    .clk(clk),
    .addr_out(addr_out_con),
    .wr_enable(),
    .valid(dv),
    .burst_length()
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

endmodule