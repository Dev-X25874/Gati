module test_top#(
    parameter W_DATA = 8,
    parameter W_ADDR = 9,
    parameter N_FIFO = 32,
    parameter N_BRAM = 8,             //number of brams in one bank
    parameter N_BANK = 4,             //total number of bram banks
    parameter W_KERNAL_CNT = 16,
    parameter W_IMG_DIM = 20,
    parameter W_IMG_BRAM_ADDR = 10
)(
    input clk,
    input i_rstn,
    input rx_serial,
    input i_flattening,               //trigger to start writting data into BRAM
    output [W_DATA-1 : 0] o_data_mux, //output data byte
    output o_data_valid,              //output data's valid signal
    output weight_fifo_array_trigger, //trigger for loading weights into PE block in FC
    output o_bram_rden_done           //indicates done reading all the channels for all different set of kernals
);

wire rst;
wire flatten;

assign rstn = ~i_rstn;
assign flatten = ~i_flattening;

wire rx_dv;
wire [W_DATA-1 : 0] rx_byte;

//uart receiver to serially receive image matrix
uart_rx#(
    .W_DATA(W_DATA),
    .N_SA(1)
)receiver(  
    .i_clk(clk),
    .i_rst(~rstn),
    .i_rx_serial(rx_serial),
    .o_rx_dv(rx_dv),
    .o_rx_byte(rx_byte)
);

wire rx_fifo_dv;
wire [W_DATA-1 : 0] rx_fifo_data;
wire rx_fifo_empty;
wire [W_ADDR : 0] rx_fifo_occ;
//stores images received through uart trx
sync_fifo#(
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR)
)rx_fifo(
    .full_o(),
    .empty_o(rx_fifo_empty),
    .clk_i(clk),
    .wr_en_i(rx_dv),
    .rd_en_i(rx_fifo_rden),
    .wdata(rx_byte),
    .datacount_o(rx_fifo_occ),
    .rst_busy(),
    .rdata(rx_fifo_data),
    .a_rst_i(~rstn),
    .o_valid(rx_fifo_dv)
);

wire rx_fifo_rden;
//handles read enable signal of fifo connected with uart rx
rx_fifo_rden_ctrl#(
    .N_FIFO(N_FIFO),
    .W_ADDR(W_ADDR)
)rx_fifo_read_enable(
    .clk(clk),
    .rstn(rstn),
    .i_fifo_empty(rx_fifo_empty),
    .i_fifo_occupants(rx_fifo_occ),
    .o_fifo_read_enable(rx_fifo_rden)
);

wire uart_ff_ctrl_enb;
wire [W_DATA-1 : 0] uart_ff_array_data_in;
//send data from single uart rx fifo to array of fifo
uart_fifo_array_data#(
    .W_DATA(W_DATA)
)uart_ff_array_data(
    .clk(clk),
    .rstn(rstn),
    .i_data_valid(rx_fifo_dv),
    .i_data(rx_fifo_data),
    .o_enable(uart_ff_ctrl_enb),
    .o_data(uart_ff_array_data_in)
);

wire [N_FIFO-1 : 0] uart_ff_array_wren;

//Asserts write enable signal of image fifo array
sa_fifo_array_wren_gen#(
    .DIMENSION(N_FIFO),
    .N_SA(1)
)uart_ff_array_wren_ctrl(
    .i_clk(clk),
    .i_rst(~rstn),
    .i_enb(uart_ff_ctrl_enb),
    .o_wren(uart_ff_array_wren)
);

wire [(N_FIFO * W_DATA)-1 : 0] uart_ff_array_data_out;
wire [N_FIFO-1 : 0] uart_ff_array_rden;
wire [N_FIFO-1 : 0] uart_ff_array_empty;
wire [(N_FIFO * (W_ADDR+1))-1 : 0] uart_ff_array_occ;
wire [(N_BANK * N_BRAM)-1 : 0] valid_uart_ff_array_flattening_ctrl;

//Each fifo in this array stores an element of each channel
image_fifo_array#(
    .DIMENSION(N_FIFO),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(1 << W_ADDR)
)uart_image_fifo_array(
    .i_clk(clk),
    .i_rstn(rstn),
    .i_data(uart_ff_array_data_in),
    .i_read_enable(uart_ff_array_rden),
    .i_write_enable(uart_ff_array_wren),
    .o_data(uart_ff_array_data_out),
    .o_fifo_empty(uart_ff_array_empty),
    .o_fifo_full(),
    .o_fifo_dv(valid_uart_ff_array_flattening_ctrl),
    .o_occupants(uart_ff_array_occ)
);

//Asserts read enable signal of image fifo array, which receives data from uart rx fifo
uart_fifo_array_rden#(
    .N_FIFO(N_FIFO),
    .W_ADDR(W_ADDR)
)uart_ff_array_rden_ctrl(
    .clk(clk),
    .rstn(rstn),
    .i_image_rows(i_image_rows),
    .i_fifo_empty(uart_ff_array_empty),
    .i_fifo_occupants(uart_ff_array_occ),
    .o_fifo_read_enable(uart_ff_array_rden)
);

/*
    Receives data from uart_rx_fifo_array, does the flattening,
    and store it into BRAM. Further, data from BRAM is sent into
    mux, which takes data from multiple BRAMs, and send one byte per clock cycle
*/
test_flattening#(
    .W_DATA(W_DATA),
    .W_ADDR(10),
    .N_BRAM(N_BRAM), //number of brams in one bank
    .N_BANK(N_BANK), //total number of bram banks
    .W_KERNAL_CNT(W_KERNAL_CNT),
    .W_IMG_DIM(W_IMG_DIM),
    .W_IMG_BRAM_ADDR(W_IMG_BRAM_ADDR)
)flattening_layer(
    .clk(clk),
    .rstn(rstn),
    .flatten(flatten),
    .i_addr_counter(10'd21),
    .i_acc_valid(1'b1),
    .i_kernal_counter(16'd128),
    .i_data_valid(valid_uart_ff_array_flattening_ctrl),
    .i_weight_ff_array_empty({(N_BANK * N_BRAM){1'b0}}),
    .i_image_dimension(20'd49),
    .i_data(uart_ff_array_data_out),
    .o_data_mux(o_data_mux),
    .o_data_valid(o_data_valid),
    .weight_fifo_array_trigger(weight_fifo_array_trigger),
    .o_done_rden_ctrl(o_bram_rden_done)
);

endmodule