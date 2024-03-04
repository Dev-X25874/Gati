module top_con(
    input din,
    input clk,
    input rst,
    output dout
);

wire [7:0] d_out;
wire rx_valid;
wire [31:0] result_tw;
wire [7:0] result_eight;
wire valid_con;
wire select_line;
wire valid_fifo;
wire [31:0] data_fifo;
wire re;
wire [31:0] data_tx_con;
wire empty_con_tx;
wire [7:0] data_tx;
wire dv;
wire done_tx;

rx rx(
    .clk(clk),
    .din(din),
    .dout(d_out),
    .valid(rx_valid)
);

controller con(
    .clk(clk),
    .din(d_out),
    .valid(rx_valid),
    .intermediate_result(result_tw),
    .quantized_result(result_eight),
    .valid_out(valid_con),
    .sel(select_line)
);

top_gen main_des_top(
    .intermediate_result(result_tw),
    .quantized_result_in(result_eight),
    .sel(select_line),
    .valid_intermediate_result(valid_con),
    .clk(clk),
    .valid_out_final(valid_fifo),
    .data_out(data_fifo)
);

fifo_valid #(.DATA_WIDTH(32), .ADDR_WIDTH(5)) fifo_tx(
    .clk(clk),
    .rst_n(rst),
    .data_in(data_fifo),
    .we(valid_fifo),
    .re(re),
    .data_out(data_tx_con),
    .occupants(),
    .empty(empty_con_tx),
    .full(),
    .data_valid()
);

controller_fifo_tx #(.DATA_WIDTH(32)) fifo_tx_con(
    .clk(clk),
    .i_fifo_data(data_tx_con),
    .i_empty_flag(empty_con_tx),
    .o_data(data_tx),
    .rd_en(re),
    .o_valid_tx2(dv),
    .i_trans_done_tx2(done_tx)
);

tx tx(
    .i_Rst_L(rst),
    .i_Clock(clk),
    .i_TX_DV(dv),
    .i_TX_Byte(data_tx), 
    .o_TX_Active(),
    .o_TX_Serial(dout),
    .o_TX_Done(done_tx)
);

endmodule