module top_test(
    input din,
    input clk,
    input rst,
    output dout
);

wire [7:0] d_out;

rx rx(
    .clk(clk),
    .din(din),
    .dout(d_out),
    .valid(rx_valid)
);

controller_concate controller_concate(
    .din(d_out),
    .rx_valid(),
    .start_addr(),
    .stop_addr(),
    .kernelitr(),
    .config_start()
);

top_fifo_dram_mimic_con top_fifo_dram_mimic_con(
    .addr_out(),
    .clk(),
    .fifo_status()
);

request_controller_im2col request_controller_im2col(
    .start_addr(),
    .channelitr(),
    .kernelitr(),
    .stop_addr(),
    .config_start(),
    .fifo_status(), //occupancy check
    .clk(),
    .addr_out(),
    .wr_enable(),
    .valid(),
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