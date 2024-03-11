module top_for_8_bit_shift #(parameter no_of_designs = 4, parameter N_FIFO = 4, parameter ADDR_WIDTH = 9) (
    input din,
    input clk,
    input rst,
    output dout
);

wire [7:0] d_out;
wire rx_valid;
wire [7:0] eight_result;
wire valid_con;
wire select_line;
wire [N_FIFO-1:0] empty;
wire [((ADDR_WIDTH*N_FIFO)-1):0] occupants;
wire [N_FIFO-1:0] wr;
wire [N_FIFO-1:0] rn;
wire [(no_of_designs * 8)-1 : 0] eight_result_fifo;
wire [(no_of_designs - 1) : 0] valid_con_fifo;
wire [(no_of_designs - 1) : 0] we_gen;
wire [(no_of_designs * 32)-1 : 0] fifo_in_gen;
wire [(no_of_designs - 1) : 0] empty_flag;
wire [(no_of_designs * 32)-1 :0] data_out_fifo_gen;
wire [7:0] data_in_final_fifo;
wire write_enable;
wire [(no_of_designs - 1) : 0] read_enable;
wire empty_con_tx;
wire done_tx;
wire re_tx;
wire dv;
wire [7:0] data_tx;

rx rx(
    .clk(clk),
    .din(din),
    .dout(d_out),
    .valid(rx_valid)
);

controller_8_bit con_rx(
    .clk(clk),
    .din(d_out),
    .valid_quantized_result(rx_valid),
    .quantized_result(eight_result),
    .valid_out(valid_con),
    .sel(select_line)
);

controller_gen_rd_wn con_rd_wn(
    .i_clk(clk),
    .i_rx_valid(valid_con),
    .i_fifo_empty(empty),
    .i_fifo_occupants(occupants),
    .o_fifo_wren(wr),
    .o_fifo_rden(rn)
);

top_fifo_gen_con top_fifo_gen_con(
    .clk(clk),
    .rst_n(rst),
    .we(wr),
    .re(rn),
    .data_in(eight_result),
    .occupants(occupants),
    .full(),
    .empty(empty),
    .data_out(eight_result_fifo),
    .data_valid(valid_con_fifo)
);

top_gen_main_des top_gen_main_des(
    .intermediate_result(thirty_two_result_fifo),
    .quantized_result_in(eight_result_fifo),
    .sel(select_line),
    .valid_intermediate_result(),
    .valid_quantized_result(valid_con_fifo),
    .clk(clk),
    .valid_out_final(we_gen),
    .data_out(fifo_in_gen)
);

top_fifo_gen top_fifo_gen_maindes(
    .clk(clk),
    .rst_n(rst),
    .we(we_gen),
    .re(read_enable),
    .data_in(fifo_in_gen),
    .occupants(),
    .full(),
    .empty(empty_flag),
    .data_out(data_out_fifo_gen),
    .data_valid()
);

controller_after_main_design_gen controller_after_main_design_gen(
    .i_clk(clk),
    .i_data(data_out_fifo_gen),
    .i_fifo_empty(empty_flag),
    .o_data(data_in_final_fifo),
    .wr_en_final_fifo(write_enable),
    .o_read_enable(read_enable)
);

fifo_valid #(.DATA_WIDTH(8), .ADDR_WIDTH(9)) fifo_tx(
    .clk(clk),
    .rst_n(rst),
    .data_in(data_in_final_fifo),
    .we(write_enable),
    .re(re_tx),
    .data_out(data_tx),
    .occupants(),
    .empty(empty_con_tx),
    .full(),
    .data_valid()
);

fifo_re_controller fifo_re_con(
    .i_clk(clk),
    .i_fifo_empty(empty_con_tx),
    .i_tx_done(done_tx),
    .o_fifo_read_enable(re_tx),
    .o_tx_data_valid(dv)
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