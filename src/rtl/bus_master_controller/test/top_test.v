module top_test #(parameter op_code_width = 4, 
            parameter data_in = 256) (
    input din,
    input start,
    input clk,
    input rst,
    output dout
);

wire [7:0] d_out;
wire dout_valid;
wire [(op_code_width)-1 : 0] opcode;
wire [(data_in)-1 : 0] dout_instruction_fifoin;
wire [(data_in)-1 : 0] dout_instruction_fifoout;
wire rd;
wire empty;
wire [179:0] dout_top_master_slave_fifoin;
wire valid_master_slave;
wire re;
wire valid_fifo_tx;
wire [179:0] dout_fifo_tx;
wire [7:0] tx_din;
wire dv;
wire empty_tx;
wire done_tx;

rx rx(
    .clk(clk),
    .din(din),
    .dout(d_out),
    .valid(rx_valid)
);

controller_rx controller_rx(
    .din(d_out),
    .clk(clk),
    .rx_valid(rx_valid),
    .opcode(opcode),
    .dout(dout_instruction_fifoin),
    .dout_valid(dout_valid)
);

fifo_valid #(.DATA_WIDTH(256), .ADDR_WIDTH(9)) fifo_rx(
    .clk(clk),
    .rst_n(rst),
    .data_in(dout_instruction_fifoin),
    .we(dout_valid),
    .re(rd),
    .data_out(dout_instruction_fifoout),
    .occupants(),
    .empty(empty),
    .full(),
    .data_valid()
);

top_master_slave top_master_slave(
    .din(dout_instruction_fifoout),
    .start(start),
    .clk(clk),
    .opcode(opcode),
    .dout_final(dout_top_master_slave_fifoin),
    .valid(valid_master_slave)
);

fifo_valid #(.DATA_WIDTH(180), .ADDR_WIDTH(9)) fifo_tx(
    .clk(clk),
    .rst_n(rst),
    .data_in(dout_top_master_slave_fifoin),
    .we(valid_master_slave),
    .re(re),
    .data_out(dout_fifo_tx),
    .occupants(),
    .empty(empty_tx),
    .full(),
    .data_valid(valid_fifo_tx)
);

controller_tx controller_tx(
    .clk(clk),
    .i_rst(rst),
    .i_fifo_data(dout_fifo_tx),
    .i_empty_flag(empty_tx),
    .o_data(tx_din),
    .rd_en(re),             
    .o_valid_tx2(dv),
    .i_trans_done_tx2(done_tx)
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

assign rd = (~empty);

endmodule