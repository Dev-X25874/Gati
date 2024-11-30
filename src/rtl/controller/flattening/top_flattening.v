/*
    Receives data from DDR, flatten it and stores it into BRAM array.
    Further, the data from BRAM is sent into a mux, which receives data 
    channel-wise, and send one byte at a time as output.
*/
module top_flattening#(
    parameter W_DATA = 8,
    parameter N_BRAM = 8,                                       //number of brams in one bank
    parameter N_BANK = 4,                                       //total number of bram banks
    parameter W_KERNAL_CNT = 16,
    parameter W_IMG_DIM = 20,
    parameter W_IMG_BRAM_ADDR = 10,
    parameter IMG_FF_DEPTH = 1024,
    parameter SHFT_REG_X = 4,
    parameter N_SA = 4,
    parameter DRAM_BW = 32
)(
    input clk,
    input rstn,
    input flatten,
    input start,                                                //trigger to start writting data into BRAM
    input i_acc_valid,                                          //data valid from accumulator
    input [W_IMG_BRAM_ADDR-1 : 0] i_addr_counter,               //comes from instructions indicating total addresses to be written in each BRAM
    input [W_KERNAL_CNT-1 : 0] i_kernal_counter,                //comes from instructions, indicates total counts for loading same image, but for different set of kernals
    input [(N_BANK * N_BRAM)-1 : 0] i_data_valid,               //data valid signal of data coming from DDR
    input i_weight_ff_array_empty,
    input i_weight_ff_array_almost_empty,    
    input [W_IMG_DIM-1 : 0] i_image_dimension,                  //comes from indtruction, as of now, it is 7x7
    input [((N_BANK * N_BRAM) * W_DATA)-1 : 0]  i_data,         //data from DDR
    output [W_DATA-1 : 0] o_data_mux,                           //output data byte
    output o_data_valid,                                        //output data's valid signal
    output weight_fifo_array_trigger,                           //trigger for loading weights into PE block in FC
    output o_done_rden_ctrl                                     //indicates done reading all the channels for all different set of kernals
);

localparam IMG_FF_ADDR = $clog2(IMG_FF_DEPTH) - 1;

wire flattened_data_valid;
wire [((N_BANK * N_BRAM) * W_DATA)-1 : 0] flattened_data;
/*
    Controller to reorder the convolution layer output
*/
conv_output_reorder#(
    .N_BRAM(N_BRAM),
    .N_BANK(N_BANK),
    .W_DATA(W_DATA),
    .SHFT_REG_X(SHFT_REG_X),
    .N_SA(N_SA),
    .DRAM_BW(DRAM_BW)
)data_flattening(
    .clk(clk),
    .rstn(rstn),
    .i_valid(i_data_valid),
    .flatten(flatten),
    .i_data(i_data),
    .o_data(flattened_data),
    .data_valid(flattened_data_valid)
);

wire [(N_BANK * (IMG_FF_ADDR + 1))-1 : 0] w_addr_we_ctrl_bram_array;
wire wren_done_bram_we_ctrl_bram_re_ctrl;
wire [(N_BANK * N_BRAM)-1 : 0] wren_ctrl_bram_array;
wire [((N_BANK * N_BRAM) * W_DATA)-1 : 0] data_we_ctrl_bram_array;
wire [W_KERNAL_CNT-1:0] kernal_cnt_rden_ctrl_wren_ctrl;
/*
    Controls write enable signal of BRAMs
*/
bram_wren_ctrl#(
    .N_BRAM(N_BRAM),
    .N_BANK(N_BANK),
    .W_DATA(W_DATA),
    .W_ADDR(IMG_FF_ADDR),
    .W_KERNAL_CNT(W_KERNAL_CNT),
    .W_IMG_BRAM_ADDR(W_IMG_BRAM_ADDR)
)bram_array_wren(
    .clk(clk),
    .rstn(rstn),
    .start(start),
    .kernal_counter(kernal_cnt_rden_ctrl_wren_ctrl),
    .i_kernal_counter(i_kernal_counter),
    .data_valid(flattened_data_valid),
    .i_data(flattened_data),
    .write_done(wren_done_bram_we_ctrl_bram_re_ctrl),
    .write_enable(wren_ctrl_bram_array),
    .o_data(data_we_ctrl_bram_array),
    .o_waddr(w_addr_we_ctrl_bram_array),
    .i_addr_counter(i_addr_counter)
);

wire [N_BRAM-1 : 0] read_valid;
wire [(N_BANK * (IMG_FF_ADDR + 1))-1 : 0] r_addr_rd_ctrl_bram_array;
wire [((N_BANK * N_BRAM) * W_DATA)-1 : 0] bram_array_data_out;
/*
    Array of BRAM to store flattened data
*/
wire [N_BRAM-1 : 0] rden_ctrl_bram_bank;
wire [N_BANK-1 : 0] bank_enable_rden_ctrl_bram_bank;

bram_bank_array#(
    .N_BANK(N_BANK),                //number of banks of bram
    .N_BRAM(N_BRAM),                //total brams in one bank
    .W_ADDR(IMG_FF_ADDR),                //bram address width
    .W_DATA(W_DATA)                 //bram data width
)bram_array(
    .clk(clk),
    .i_bank_en(bank_enable_rden_ctrl_bram_bank),
    .we(wren_ctrl_bram_array),
    .re(rden_ctrl_bram_bank),
    .i_data(data_we_ctrl_bram_array),
    .w_addr(w_addr_we_ctrl_bram_array),
    .r_addr(r_addr_rd_ctrl_bram_array),
    .o_data(bram_array_data_out),
    .read_valid(read_valid)
);

reg [N_BRAM-1 : 0] mux_rden;
reg [N_BANK-1 : 0] mux_bank_en;
always @(posedge clk) begin
    mux_rden <= read_valid;
    mux_bank_en <= bank_enable_rden_ctrl_bram_bank;
end

wire rd_flag;
/*
    Controls read enable signal of BRAMs
*/
bram_rden_controller#(
    .W_KERNAL_CNT(W_KERNAL_CNT),
    .W_IMG_DIM(W_IMG_DIM),
    .N_BRAM(N_BRAM),
    .N_BANK(N_BANK),
    .W_ADDR(IMG_FF_ADDR),
    .W_IMG_BRAM_ADDR(W_IMG_BRAM_ADDR)
)bram_read_controller(
    .clk(clk),
    .rstn(rstn),
    .w_done(wren_done_bram_we_ctrl_bram_re_ctrl),
    .accumulator_valid(i_acc_valid),
    .flatten(flatten),
    .i_addr_counter(i_addr_counter),
    .kernal_count(i_kernal_counter),
    .weight_ff_array_empty(i_weight_ff_array_empty),
    .weight_ff_array_almost_empty(i_weight_ff_array_almost_empty),
    .image_dimension(i_image_dimension),
    .o_read_enable(rden_ctrl_bram_bank),
    .rd_flag(),
    .o_done(o_done_rden_ctrl),
    .o_bank_address(r_addr_rd_ctrl_bram_array),
    .o_bank_enable(bank_enable_rden_ctrl_bram_bank),
    .r_kernal_counter(kernal_cnt_rden_ctrl_wren_ctrl),
    .weight_ff_trigger()
);

assign weight_fifo_array_trigger = wren_done_bram_we_ctrl_bram_re_ctrl;

/*
    Mux to determine which of the two incoming read enable signals, 
    one from SA and the other from FC, should feed into the weight fifo array
*/
output_mux#(
    .N_BANK(N_BANK),
    .N_BRAM(N_BRAM),
    .W_DATA(W_DATA)
) output_data_mux (
    .clk(clk),
    .rstn(rstn),
    .rd_flag(),
    .i_weight_ff_array_empty(i_weight_ff_array_empty),
    .i_rden(mux_rden),
    .i_bank_en(mux_bank_en),
    .i_data(bram_array_data_out),
    .o_data(o_data_mux),
    .data_valid(o_data_valid)
);

endmodule
