module top_for_shift_reg_gen #(parameter no_of_designs = 4, parameter N_FIFO = 4, parameter ADDR_WIDTH = 9) (
    input din,
    input clk,
    input rst,
    input select_line,
    output dout
);

wire [7:0] d_out;
wire rx_valid;
wire [(32)-1 : 0] thirty_two_result;
wire [(no_of_designs * 32)-1 : 0] thirty_two_result_fifo;
wire [(8)-1 : 0] eight_result;
wire valid_con;
wire [(no_of_designs - 1) : 0] valid_con_fifo_int;
wire [(no_of_designs - 1) : 0] valid_con_fifo_quan;
//wire select_line;
wire [(no_of_designs - 1) : 0] we_gen;
wire [(no_of_designs * 32)-1 : 0] fifo_in_gen;
wire [(no_of_designs - 1) : 0] read_enable;
wire write_enable;
wire [(no_of_designs - 1) : 0] empty_flag;
wire [(no_of_designs * 32)-1 :0] data_out_fifo_gen;
wire [31:0] data_in_final_fifo;
wire re_tx;
wire [31:0] data_out_final_fifo;
wire empty_con_tx;
wire [7:0] data_tx;
wire dv;
wire done_tx;
wire [N_FIFO-1:0] empty;
wire [N_FIFO-1:0] empty_1;
wire [N_FIFO-1:0] empty_2;
wire [((ADDR_WIDTH*N_FIFO)-1):0] occupants;
wire [((ADDR_WIDTH*N_FIFO)-1):0] occupants_1;
wire [((ADDR_WIDTH*N_FIFO)-1):0] occupants_2;
wire [N_FIFO-1:0] wr;
wire [N_FIFO-1:0] wr1;
wire [N_FIFO-1:0] wr2;
wire [N_FIFO-1:0] rn;
wire [N_FIFO-1:0] rn1;
wire [N_FIFO-1:0] rn2;
wire [(no_of_designs * 8)-1 : 0] eight_result_fifo;

rx rx(
    .clk(clk),
    .din(din),
    .dout(d_out),
    .valid(rx_valid)
);

/*controller controller_rx(
    .clk(clk),
    .din(d_out),
    .valid_intermediate_result(rx_valid),
    .intermediate_result(thirty_two_result),
    .quantized_result(eight_result),
    .valid_out(valid_con),
    .sel(select_line)
);*/

/*controller_common controller_common(
    .clk(clk),
    .din(d_out),
    .rx_valid(rx_valid),
    .sel(select_line),
    .intermediate_result(thirty_two_result),
    .quantized_result(eight_result),
    .valid_out(valid_con)
);*/

controller_common_data controller_common_data(
    .clk(clk),
    .din(d_out),
    .rx_valid(rx_valid),
    .sel(select_line),
    .intermediate_result(thirty_two_result),
    .quantized_result(eight_result),
    .valid_out(valid_con)
);

controller_gen_rd_wn con_rd_wn(
    .i_clk(clk),
    .i_rx_valid(valid_con),
    .i_fifo_empty(empty),
    .i_fifo_occupants(occupants),
    .o_fifo_wren(wr),
    .o_fifo_rden(rn)
);

top_fifo_gen_con top_fifo_gen_con_int(
    .clk(clk),
    .rst_n(rst),
    .we(wr1),
    .re(rn1),
    .data_in(thirty_two_result),
    .occupants(occupants_1),
    .full(),
    .empty(empty_1),
    .data_out(thirty_two_result_fifo),
    .data_valid(valid_con_fifo_int)
);

top_fifo_gen_con #(.DATA_WIDTH(8)) top_fifo_gen_con_quan(
    .clk(clk),
    .rst_n(rst),
    .we(wr1),
    .re(rn1),
    .data_in(eight_result),
    .occupants(occupants_2),
    .full(),
    .empty(empty_2),
    .data_out(eight_result_fifo),
    .data_valid(valid_con_fifo_quan)
);

top_gen_main_des top_gen_main_des(
    .intermediate_result(thirty_two_result_fifo),
    .quantized_result_in(eight_result_fifo),
    .sel(select_line),
    .valid_intermediate_result(valid_con_fifo_int),
    .valid_quantized_result(valid_con_fifo_quan),
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

fifo_valid #(.DATA_WIDTH(32), .ADDR_WIDTH(9)) fifo_tx(
    .clk(clk),
    .rst_n(rst),
    .data_in(data_in_final_fifo),
    .we(write_enable),
    .re(re_tx),
    .data_out(data_out_final_fifo),
    .occupants(),
    .empty(empty_con_tx),
    .full(),
    .data_valid()
);

controller_fifo_tx #(.DATA_WIDTH(32)) fifo_tx_con(
    .clk(clk),
    .i_fifo_data(data_out_final_fifo),
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




assign occupants = select_line? occupants_2 : occupants_1;

assign empty = select_line? empty_2 : empty_1;

assign {wr1 , wr2} = select_line? {0 , wr} : {wr , 0};
assign {rn1 , rn2} = select_line? {0 , rn} : {rn , 0};

endmodule