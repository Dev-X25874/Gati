module block#(
    parameter W_DATA = 8,
    parameter W_ADDR = 9,
    parameter N_FIFO = 32
    parameter BRAM_BANK_FF = 8, //number of brams in one bank
    parameter N_BANK = 4        //total number of bram banks
)(
    input clk,
    input rst,
    input flatten,
    input start,
    input [(N_FIFO * W_DATA)-1 : 0]  i_data,
    input [N_FIFO-1 : 0] bram_array_rden,
    output [(N_FIFO * W_DATA)-1 : 0] bram_array_data_out
);

wire flattened_data_valid;
wire [(N_FIFO * W_DATA)-1 : 0] flattened_data;
//Flattening data coming from DDR
flattening_controller#(
    .N_FIFO(N_FIFO),
    .W_DATA(W_DATA)
)data_flattening(
    .clk(clk),
    .rst(rst),
    .flatten(flatten),
    .i_data(i_data),
    .o_data(flattened_data),
    .data_valid(flattened_data_valid)
);

wire [(N_FIFO * (W_ADDR + 1))-1 : 0] addr_we_ctrl_bram_array;
wire wren_done_bram_we_ctrl_bram_re_ctrl;
wire [N_FIFO-1 : 0] wren_ctrl_bram_array;
wire [(N_FIFO * W_DATA)-1 : 0] data_we_ctrl_bram_array;
//bram array write enable controller
bram_wren_ctrl#(
    .N_FIFO(N_FIFO),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR)
)bram_array_wren(
    .clk(clk),
    .rst(rst),
    .start(start),
    .data_valid(flattened_data_valid),
    .image_dim(15'd896),
    .i_data(flattened_data),
    .write_done(wren_done_bram_we_ctrl_bram_re_ctrl),
    .write_enable(wren_ctrl_bram_array),
    .o_data(data_we_ctrl_bram_array),
    .o_addr(addr_we_ctrl_bram_array)
);

//Array of brams to store flattened data
bram_bank_array#(
    .N_BANK(N_BANK),                //number of banks of bram
    .BRAM_BANK_FF(BRAM_BANK_FF),    //total brams in one bank
    .W_ADDR(W_ADDR),                //bram address width
    .W_DATA(W_DATA)                 //bram data width
)bram_array(
    .clk(clk),
    .we(wren_ctrl_bram_array),
    .re(bram_array_rden),
    .i_data(data_we_ctrl_bram_array),
    .i_address(addr_we_ctrl_bram_array),
    .o_data(bram_array_data_out)
);

endmodule