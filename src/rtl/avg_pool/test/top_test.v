module top_test#(parameter DATA_WIDTH = 8, 
                 parameter POOL_HEIGHT = 4,
                 parameter POOL_WIDTH = 4,
                 parameter POOLING_TYPE_WIDTH = 3,
                 parameter OH_WIDTH = 10,
                 parameter OW_WIDTH = 10
                )
(
    input clk,
    input din,
    input rst_n,
    input ENABLE,
    output done_pool,
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
wire [2:0] pooling_type;
wire [3:0] pool_width;
wire [3:0] pool_height;
wire [9:0] OH;
wire [9:0] OW;
wire re;
wire empty;
wire [8:0] occupants;

assign re = ~empty;
assign pooling_type = 3'd0;
assign pool_width = 4'd2;
assign pool_height = 4'd2;
assign OH = 10'd12;
assign OW = 10'd12;

rx rx(
  .clk(clk),
  .din(din),
  .dout(data_in),
  .valid(rx_valid)
);

// controller controller(
//   .clk(clk),
//   .rx_valid(rx_valid),
//   .din(data_in),
//   .dout(data_in_fifo),
//   .datavalid(datavalid_in),
//   .pooling_type(pooling_type),
//   .pool_width(pool_width),
//   .pool_height(pool_height),
//   .OH(OH),
//   .OW(OW)
// );

fifo_valid #(.DATA_WIDTH(8), .ADDR_WIDTH(9)) fifo_pool (
    .clk(clk),
    .rst_n(rst_n),
    .we(rx_valid),
    .re(re),
    .data_in(data_in),
    .occupants(),
    .full(),
    .empty(empty),
    .data_out(data_out),
    .data_valid(dv)
);

top #(.DATA_WIDTH(DATA_WIDTH), 
      .POOL_HEIGHT(POOL_HEIGHT),
      .POOL_WIDTH(POOL_WIDTH),
      .POOLING_TYPE_WIDTH(POOLING_TYPE_WIDTH),
      .OH_WIDTH(OH_WIDTH),
      .OW_WIDTH(OW_WIDTH)
    )
top_pool(
    .clk(clk),
    .rst_n(rst_n),
    .ENABLE(ENABLE),
    .din(data_out),
    .datavalid_in(dv),
    .pooling_type(pooling_type),
    .pool_width(pool_width),
    .pool_height(pool_height),
    .rx_valid(rx_valid),
    .OH(OH),
    .OW(OW),
    .dout(data_out_tx),
    .done(done_pool),
    .datavalid_out(dv_pool)
);

fifo_valid #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(9)) fifo_tx (
    .clk(clk),
    .rst_n(rst_n),
    .we(dv_pool),
    .re(re_tx),
    .data_in(data_out_tx),
    .occupants(occupants),
    .full(),
    .empty(empty_tx),
    .data_out(data_tx),
    .data_valid()
);

controller_fifo_tx controller_fifo_tx(
    .empty(empty_tx),
    .done(done),
    .occupants(occupants),
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

endmodule