module top_design #(
    parameter ROW = 9,
    parameter COL = 1,
    parameter W_DATA = 8,
    parameter W_ADDR = (ROW * COL),
    parameter RAM_DEPTH = (1 << W_ADDR),
    parameter TOTAL_BYTES = (ROW * COL)
)(
    input i_clk,
    input i_sel_1,
    input i_sel_2,
    input i_trigger_1,
    input i_trigger_2,
    input i_rx_serial,
    output o_tx_serial_column,
    output o_tx_serial_row
);

wire w_RX_DV;
wire [W_DATA-1 : 0] w_RX_Byte;

//clk = 100MHz, baud rate = 115200
uart_rx#(
    .CLOCKS_PER_BIT(50)
) uart_receiver (
    .i_Clock(i_clk),
    .i_RX_Serial(i_rx_serial),
    .o_RX_DV(w_RX_DV),
    .o_RX_Byte(w_RX_Byte)
);
wire select1;
wire select2;
assign select1 = ~i_sel_1;
assign select2 = ~i_sel_2;
wire [(COL * 32)-1:0] out_south_data;
wire [(ROW * 9)-1:0] out_east_data;

//data valid signal of last row's input into the systolic array used as write enable signal
//for fifo array which stores systolic array's 32 bit output
wire col_wren_dv;

wire select;
wire [(COL * 32)-1 :0] sa_weights;
wire [(ROW * 9)-1 :0] sa_data;

//input fifo array design
i_fifo_design#(
    .ROW(ROW),
    .COL(COL),
    .W_DATA(W_DATA),
    .TOTAL_BYTES(TOTAL_BYTES),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH (RAM_DEPTH)
) input_data_design (
    .i_clk (i_clk),
    .rx_data_valid(w_RX_DV),
    .in_data (w_RX_Byte),
    .i_sel_1 (select1),
    .i_sel_2 (select2),
    .i_trigger_1 (~i_trigger_1),
    .i_trigger_2 (~i_trigger_2),
    .sa_select (select),
    .north_data (sa_weights),
    .west_data (sa_data)
);

wire [(COL*32)-1:0] o_south_data;
wire [(ROW*9)-1:0] o_east_data;
wire [COL-1:0] sel_out;

wire [(COL * 32)-1 : 0] i_sa_north_data;

reg [(COL * 32)-1 : 0] north_w_p_sum= 0;

always @(posedge i_clk)begin
    north_w_p_sum <= sa_weights;
end

assign i_sa_north_data = north_w_p_sum;
//systolic array design
systolic_array #(
    .ROW(ROW), 
    .COL(COL), 
    .TOTAL_BYTES(TOTAL_BYTES)
) systolic_array_design (
    .in_clk (i_clk), 
    .in_sel (select), 
    .in_north (i_sa_north_data), 
    .in_west (sa_data), 
    .out_sel (sel_out), 
    .out_east (o_east_data), 
    .out_south (o_south_data),
    .last_row_i_data_valid(col_wren_dv)
);


wire column_dv;
wire row_dv;
wire [W_DATA-1:0] col_data_out;
wire [W_DATA-1:0] row_data_out;   

//fifo design for storing systolic array's outputs
o_fifo_design#(
    .ROW(ROW),
    .COL(COL),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(RAM_DEPTH)
) output_data_design (
    .i_clk(i_clk),
    .i_data_32(o_south_data),
    .i_data_8(o_east_data),
    .o_col_data(col_data_out),
    .o_row_data(row_data_out),
    .i_last_row_dv(col_wren_dv),
    .row_fifo_valid(row_dv),
    .column_fifo_valid(column_dv)
);

uart_tx #(
.CLKS_PER_BIT(50)
  ) uart_column_transmitter (
   .i_Rst_L(1'b1),
   .i_Clock(i_clk),
   .i_TX_DV(column_dv),
   .i_TX_Byte(col_data_out), 
   .o_TX_Active(),
   .o_TX_Serial(o_tx_serial_column),
   .o_TX_Done()
   );
   
   uart_tx #(
.CLKS_PER_BIT(50)
  ) uart_row_transmitter (
   .i_Rst_L(1'b1),
   .i_Clock(i_clk),
   .i_TX_DV(row_dv),
   .i_TX_Byte(row_data_out), 
   .o_TX_Active(),
   .o_TX_Serial(o_tx_serial_row),
   .o_TX_Done()
   );

endmodule
