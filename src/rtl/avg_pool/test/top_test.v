module top_test(
    input clk,
    input din,
    input rst_n,
    input ENABLE,
    output dout
);

wire rx_valid;
wire [7:0] data_in;
wire [7:0] data_in_fifo;
wire datavalid_in;
wire dv;
wire [7:0] data_out;
wire [7:0] data_out_tx;
wire empty_tx;
wire re_tx;
wire dv_pool;
wire datavalid_tx;
wire done;
wire [7:0] data_tx;

rx rx(
  .clk(clk),
  .din(din),
  .dout(data_in),
  .valid(rx_valid)
);

controller controller(
  .clk(clk),
  .rx_valid(rx_valid),
  .din(data_in),
  .dout(data_in_fifo),
  .datavalid(datavalid_in),
  .pooling_type(pooling_type),
  .pool_width(pool_width),
  .pool_height(pool_height),
  .OH(OH),
  .OW(OW)
);

fifo_valid #(.DATA_WIDTH(8), .ADDR_WIDTH(9)) fifo_top (
    .clk(clk),
    .rst_n(rst_n),
    .we(datavalid_in),
    .re(re),
    .data_in(data_in_fifo),
    .occupants(),
    .full(),
    .empty(empty),
    .data_out(data_out),
    .data_valid(dv)
);

top top(
    .clk(clk),
    .rst_n(rst_n),
    .ENABLE(ENABLE),
    .din(data_out),
    .datavalid_in(dv),
    .pooling_type(pooling_type),
    .pool_width(pool_width),
    .pool_height(pool_height),
    .OH(OH),
    .OW(OW),
    .dout(data_out_tx),
    .datavalid_out(dv_pool)
);

fifo_valid #(.DATA_WIDTH(8), .ADDR_WIDTH(9)) fifo_tx (
    .clk(clk),
    .rst_n(rst_n),
    .we(dv_pool),
    .re(re_tx),
    .data_in(data_out_tx),
    .occupants(),
    .full(),
    .empty(empty_tx),
    .data_out(data_tx),
    .data_valid()
);

controller_fifo_tx controller_fifo_tx(
    .empty(empty_tx),
    .done(done),
    .clk(clk),
    .dv_tx(datavalid_tx),
    .re(re_tx) 
);

tx tx(
  .i_Rst_L(rst_n),
  .i_Clock(clk),
  .i_TX_DV(datavalid_tx),
  .i_TX_Byte(data_tx), 
  .o_TX_Active(),
  .o_TX_Serial(dout),
  .o_TX_Done(done)
);

assign re = ~empty;

endmodule