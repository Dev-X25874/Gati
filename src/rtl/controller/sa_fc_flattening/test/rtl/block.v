module block#(
    parameter W_DATA = 8,
    parameter W_ADDR = 9,
    parameter N_BRAM = 8, //number of brams in one bank
    parameter N_BANK = 4, //total number of bram banks
    parameter W_KERNAL_CNT = 16,
    parameter W_IMG_DIM = 20,
    parameter W_IMG_ROWS = 16
)(
    input clk,
    input rst,
    input flatten,
    input start,
    input i_acc_valid,
    input [(N_BANK * N_BRAM)-1 : 0] i_valid,
    input [(N_BANK * N_BRAM)-1 : 0] i_weight_ff_array_empty,
    input [W_IMG_DIM-1 : 0] i_img_dim,
    input [((N_BANK * N_BRAM) * W_DATA)-1 : 0]  i_data,
    output o_done_rden_ctrl,
    output [W_DATA-1 : 0] o_data_mux,
    output o_data_valid
);

wire flattened_data_valid;
wire [((N_BANK * N_BRAM) * W_DATA)-1 : 0] flattened_data;
//Flattening data coming from DDR
flattening_controller#(
    .N_BRAM(N_BRAM),
    .N_BANK(N_BANK),
    .W_DATA(W_DATA)
)data_flattening(
    .clk(clk),
    .rst(rst),
    .i_valid(i_valid),
    .flatten(flatten),
    .i_data(i_data),
    .o_data(flattened_data),
    .data_valid(flattened_data_valid)
);

wire [((N_BANK * N_BRAM) * (W_ADDR + 1))-1 : 0] w_addr_we_ctrl_bram_array;
wire wren_done_bram_we_ctrl_bram_re_ctrl;
wire [(N_BANK * N_BRAM)-1 : 0] wren_ctrl_bram_array;
wire [((N_BANK * N_BRAM) * W_DATA)-1 : 0] data_we_ctrl_bram_array;
//bram array write enable controller
bram_wren_ctrl#(
    .N_BRAM(N_BRAM),
    .N_BANK(N_BANK),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR)
)bram_array_wren(
    .clk(clk),
    .rst(rst),
    .start(start),
    .data_valid(flattened_data_valid),
    .image_dim(20'd784),
    .i_data(flattened_data),
    .write_done(wren_done_bram_we_ctrl_bram_re_ctrl),
    .write_enable(wren_ctrl_bram_array),
    .o_data(data_we_ctrl_bram_array),
    .o_addr(w_addr_we_ctrl_bram_array)
);
wire [(N_BANK * N_BRAM)-1 : 0] read_valid;
wire [((N_BANK * N_BRAM) * (W_ADDR + 1))-1 : 0] r_addr_rd_ctrl_bram_array;
wire [((N_BANK * N_BRAM) * W_DATA)-1 : 0] bram_array_data_out;
//Array of brams to store flattened data
bram_bank_array#(
    .N_BANK(N_BANK),                //number of banks of bram
    .N_BRAM(N_BRAM),    //total brams in one bank
    .W_ADDR(W_ADDR),                //bram address width
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

wire [N_BRAM-1 : 0] rden_ctrl_bram_bank;
wire [N_BANK-1 : 0] bank_enable_rden_ctrl_bram_bank;
//Bram array read enable controller
bram_rden_controller#(
    .W_KERNAL_CNT(W_KERNAL_CNT),
    .W_IMG_DIM(W_IMG_DIM),
    .W_IMG_ROWS(W_IMG_ROWS),
    .N_BRAM(N_BRAM),
    .N_BANK(N_BANK),
    .W_ADDR(W_ADDR)
)bram_read_controller(
    .clk(clk),
    .rst(rst),
    .w_done(wren_done_bram_we_ctrl_bram_re_ctrl),
    .accumulator_valid(i_acc_valid),
    .flatten(flatten),
    .kernal_count(16'd87), //4096
    .weight_ff_array_empty(i_weight_ff_array_empty),  //common weight fifo array for sa and fc
    .image_dimension(i_img_dim),   //7
    .image_rows(16'd23), //7x7x16
    .o_read_enable(rden_ctrl_bram_bank),
    .o_done(o_done_rden_ctrl),
    .o_bank_address(r_addr_rd_ctrl_bram_array),
    .o_bank_enable(bank_enable_rden_ctrl_bram_bank)
);

output_mux#(
    .N_BANK(N_BANK),
    .N_BRAM(N_BRAM),
    .W_DATA(W_DATA)
) output_data_mux (
    .clk(clk),
    .rst(rst),
    .i_data(bram_array_data_out),
    .i_rden(read_valid),
    .o_data(o_data_mux),
    .data_valid(o_data_valid)
);
endmodule