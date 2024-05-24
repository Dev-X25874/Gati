/*
    Important:
    ********* 
    The test files in this folder got outdated, Refer to the src/rtl/quantization 
    folder for updated design files.

    This test folder will be updated in due course of time.
*/
module top_test_quant #(
    parameter     DATA_WIDTH = 18,
    parameter     N = 3,
    parameter     SHIFT_WIDTH = 18,
    parameter     UART_WIDTH = 8,
    parameter     OUT_DATA_WIDTH = 8)(
    input       clk,
    input       i_bit,
    output      o_bit
);


wire [UART_WIDTH-1:0]                  w_byte;
wire                        w_valid;
wire [(N*DATA_WIDTH)-1:0]       w_data_ctrl;
wire [(N*DATA_WIDTH)-1:0]       w_bias_ctrl;
wire [(N*DATA_WIDTH)-1:0]       w_scale_ctrl;
wire [(N*SHIFT_WIDTH)-1:0]       w_shift_ctrl;
wire [N-1:0]                w_valid_ctrl;

wire [(N*OUT_DATA_WIDTH)-1:0] w_data_ctrl_tx;
wire [N-1:0] w_valid_ctrl_tx;

wire [UART_WIDTH-1:0]   w_data_tx;
wire         w_trans_done;
wire         w_valid_tx;





uart_rx
rx_mod_data_1(
    .clk (clk),
    .i_data (i_bit),
    .o_data (w_byte),
    .o_valid_data (w_valid),
    .rx_busy ()
);


controller_rx #(.N(N),.DATA_WIDTH(DATA_WIDTH),.SHIFT_WIDTH(SHIFT_WIDTH),.UART_WIDTH(UART_WIDTH))
controller_rx_mod (
    .clk(clk),
    .data_in(w_byte),
    .i_valid(w_valid),
    .o_data(w_data_ctrl),
    .o_data_bias(w_bias_ctrl),
    .o_data_scale(w_scale_ctrl),
    .o_valid    (w_valid_ctrl),
    .o_bit_shift(w_shift_ctrl)

);





top_quant_bias_gen #(.DATA_WIDTH(DATA_WIDTH),.SHIFT_WIDTH(SHIFT_WIDTH),.OUT_DATA_WIDTH(OUT_DATA_WIDTH),.N(N))
top_quant_bias_gen_mod(
    .top_i_clk       (clk),
    .top_i_data_quant(w_data_ctrl),
    .top_i_data_scale(w_scale_ctrl),
    .top_o_data      (w_data_ctrl_tx), 
    .top_i_data_valid(w_valid_ctrl),
    .top_o_data_valid(w_valid_ctrl_tx),
    .top_i_bit_shift (w_shift_ctrl),
    .top_i_data_bias (w_bias_ctrl)
);

controller_tx #(.N(N),.UART_WIDTH(UART_WIDTH),.OUT_DATA_WIDTH(OUT_DATA_WIDTH))
controller_tx_mod(
    .clk(clk),
    .data_in(w_data_ctrl_tx),
    .i_valid(w_valid_ctrl_tx),
    .data_out(w_data_tx),
    .o_valid(w_valid_tx),
    .trans_done(w_trans_done)
);



uart_tx
tx_mod(
    .i_data_byte (w_data_tx),
    .o_data_bit (o_bit),
    .clk (clk),
    .o_done (w_trans_done),
    .i_valid (w_valid_tx),
    .tx_busy ()
);

endmodule 

/*top_mul_shift_des2
top_mul_shift_des2_mod (
.i_clk (clk),
.i_dina(w_byte),
.i_dinb(w_valid),
.o_dout(w_data),
.i_data_valid(w_valid),
.o_valid_data(w_valid_tx)
);*/
