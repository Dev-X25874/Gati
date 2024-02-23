module top_design_for_8_ins #(parameter FIFO_NO = 8, parameter ADDR_WIDTH = 9, 
                              parameter DATA_WIDTH = 8, parameter DESIGN_NO = 8,
                              parameter DATA_OUT_WIDTH = 20) (
    input din,
    input clk,
    input rst,
    output dout
);

wire [DATA_WIDTH-1:0] fifo_in;
wire con_valid;
wire [FIFO_NO-1:0] empty;
wire [((ADDR_WIDTH*FIFO_NO)-1):0] occupants;
wire we_fsm;
wire [FIFO_NO-1 : 0] re_en;
wire [FIFO_NO-1 : 0] wr_en;
wire [(DESIGN_NO * DATA_WIDTH)-1:0] fifo_data_out;
wire [FIFO_NO-1:0] datavalid;
wire [DESIGN_NO-1:0] read_enable;
wire [DESIGN_NO-1:0] empty_flag;
wire write_enable;
wire [(DESIGN_NO * DATA_OUT_WIDTH)-1:0] data_out;
wire [DATA_OUT_WIDTH-1:0] data_out_final_fifo;
wire re_tx;
wire [DATA_OUT_WIDTH-1:0] data_tx_con;
wire empty_con_tx;
wire [DATA_WIDTH-1:0] data_tx;
wire dv;
wire done_tx;

rx rx(
    .clk(clk),
    .din(din),
    .dout(fifo_in),
    .valid(con_valid)
);

controller_gen controller_gen(
    .i_clk(clk),
    .i_rx_valid(con_valid),
    .i_fifo_empty(empty),
    .i_fifo_occupants(occupants),
    .o_fifo_wren(wr_en),
    .o_fifo_rden(re_en)
);

// fsm fsm(
//     .i_clk(clk),
//     .i_enable(we_fsm),
//     .o_fifo_wren(wr_en)
// );

top_fifo_gen fifo_gen(
    .clk(clk),
    .rst_n(rst),
    .we(wr_en),
    .re(re_en),
    .data_in(fifo_in),
    .occupants(occupants),
    .full(),
    .empty(empty),
    .data_out(fifo_data_out),
    .data_valid(datavalid)
    );

top_for_8_ins_gen main_design_gen(
    .clk(clk),
    .rst(rst),
    .valid(datavalid),
    .re_en(read_enable),
    .din(fifo_data_out),
    .dout(data_out),
    .empty(empty_flag)

);

controller_after_main_design_gen con_after_main_des(
    .i_clk(clk),
    .i_data(data_out),
    .i_fifo_empty(empty_flag),
    .o_data(data_out_final_fifo),
    .wr_en_final_fifo(write_enable),
    .o_read_enable(read_enable)
);

fifo_valid #(.DATA_WIDTH(20), .ADDR_WIDTH(10)) fifo_tx(
    .clk(clk),
    .rst_n(rst),
    .data_in(data_out_final_fifo),
    .we(write_enable),
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

