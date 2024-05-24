module top_relu #(parameter N = 3,
                  parameter DATA_WIDTH = 32,
                  parameter CLIP_WIDTH = 8)(
    input clk,
    input i_bit,
    output o_bit
); 
wire [7:0]   w_byte;
wire [(N*DATA_WIDTH)-1:0]  w_data_relu;
wire                w_valid_cont;
wire [N-1:0]               w_valid_relu;
wire [(N*DATA_WIDTH)-1:0]   w_out;
wire [N-1:0]               w_valid_out;
wire [7:0]             w_data_tx;
wire                w_valid_tx;
wire                w_tx_done;
wire [(N*CLIP_WIDTH)-1:0]    w_clip;
uart_rx 
rx_mod(
.clk (clk),
.i_data (i_bit),
.o_data (w_byte),
.o_valid_data (w_valid_cont),
.rx_busy ()
);

controller_datain #(.N(N),.DATA_WIDTH(DATA_WIDTH),.CLIP_WIDTH(CLIP_WIDTH))
controller_mod (
.clk (clk),
.data_in (w_byte),
.i_valid (w_valid_cont),
.data_out (w_data_relu),
.o_valid (w_valid_relu),
.o_clip (w_clip)

);

top_relu_gen #(.N(N),.DATA_WIDTH(DATA_WIDTH),.CLIP_WIDTH(CLIP_WIDTH))
relu_mod(
.top_clk (clk),
.top_i_data (w_data_relu),
.top_i_valid (w_valid_relu),
.top_o_data (w_out),
.top_o_valid (w_valid_out),
.top_i_clip (w_clip)
);

// relu #(.DATA_WIDTH(DATA_WIDTH)) relu_mod 
// (
// .clk (clk),
// .i_data (w_out),
// .i_valid (w_valid_out),
// .o_data (w_out),
// .o_valid (w_valid_out)
// );

 
controller_data_out #(.N(N), .DATA_WIDTH(DATA_WIDTH))
controller_mod_out (
.clk (clk),
.data_in (w_out),
.i_valid (w_valid_out),
.data_out (w_data_tx),
.o_valid (w_valid_tx),
.trans_done (w_tx_done)

);

uart_tx
tx_mod(
.i_data_byte (w_data_tx),
.o_data_bit (o_bit),
.clk (clk),
.o_done (w_tx_done),
.i_valid (w_valid_tx),
.tx_busy ()
);

endmodule 