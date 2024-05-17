module TOP_TEST #(parameter FIFO_NO = 8, parameter ADDR_WIDTH = 9, parameter DATA_WIDTH = 20, parameter COL = 4, parameter UNIQUE_KERNELS = 4, parameter DESIGN_NO = 8, parameter DATA_OUT_WIDTH = 32, parameter N_FIFO = 16) (
    input clk,
    input rst,
    input din,
    output dout
);

wire [19:0] dout_concate;
wire valid_concate;
wire rx_valid;
wire [FIFO_NO-1:0] empty;
wire [((ADDR_WIDTH*FIFO_NO)-1):0] occupants;
wire [FIFO_NO-1 : 0] re_en;
wire [FIFO_NO-1 : 0] wr_en;
wire [FIFO_NO-1:0] datavalid;
wire [(DESIGN_NO * DATA_WIDTH)-1:0] fifo_data_out;
wire [(UNIQUE_KERNELS* DATA_OUT_WIDTH) -1 : 0] result_final;
wire [COL-1:0] valid_out;
wire [19:0] data_tx_con;
wire [N_FIFO-1:0] empty;
wire [7:0] data_tx;
wire re_tx;
wire empty_con_tx;
wire [7:0] dout_con;

rx rx(
    .clk(clk),
    .din(din),
    .dout(dout_con),
    .valid(rx_valid)
);

CONTROLLER_CONCATE controller_concate(
    .clk(clk),
    .din(dout_con),
    .rx_valid(rx_valid),
    .dout(dout_concate),
    .valid(valid_concate)
);

controller_rw controller_rw_inp1(
    .i_clk(clk),
    .i_rx_valid(valid_concate),
    .i_fifo_empty(empty),
    .i_fifo_occupants(occupants),
    .o_fifo_wren(wr_en),
    .o_fifo_rden(re_en)
);

top_fifo_gen fifo_gen_inp1(
    .clk(clk),
    .rst_n(rst),
    .we(wr_en),
    .re(re_en),
    .data_in(dout_concate),
    .occupants(occupants),
    .full(),
    .empty(empty),
    .data_out(fifo_data_out),
    .data_valid(datavalid)
);

top_adder_tree_gen top_adder_tree_gen(
    .clk(clk),
    .rst(rst),
    .o_psum_ff_array(fifo_data_out),
    .valid_out(valid_out),
    .valid_in(datavalid),
    .result_final(result_final)
);

fifo_valid #(.DATA_WIDTH(20), .ADDR_WIDTH(10)) fifo_tx(
    .clk(clk),
    .rst_n(rst),
    .data_in(result_final),
    .we(valid_out),
    .re(re_tx),
    .data_out(data_tx_con),
    .occupants(),
    .empty(empty_con_tx),
    .full(),
    .data_valid()
);

controller_fifo_tx #(.DATA_WIDTH(20)) fifo_tx_con(
    .clk(clk),
    .i_fifo_data(data_tx_con),
    .i_empty_flag(empty_con_tx),
    .o_data(data_tx),
    .rd_en(re_tx),
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