module rden#(
    parameter W_KERNAL_CNT = 16,
    parameter W_IMG_DIM = 20,
    parameter W_IMG_ROWS = 16,
    parameter N_BRAM = 8,
    parameter N_BANK = 4,
    parameter W_ADDR = 9
)(
    input clk,
    input rst,
    input w_done,
    input accumulator_valid,
    input flatten,
    input [(N_BANK * N_BRAM)-1 : 0] weight_ff_array_empty,  //common weight fifo array for sa and fc
    output [(N_BANK * N_BRAM)-1 : 0] o_read_enable,
    output o_done,
    output [(N_BANK * (W_ADDR + 1))-1 : 0] o_bank_address
);

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
    .w_done(w_done),
    .accumulator_valid(accumulator_valid),
    .flatten(flatten),
    .kernal_count(16'd87), //4096
    .weight_ff_array_empty(weight_ff_array_empty),  //common weight fifo array for sa and fc
    .image_dimension(image_dimension),   //7
    .image_rows(16'd23), //7x7x16
    .o_read_enable(o_read_enable),
    .o_done(o_done),
    .o_bank_address(o_bank_address)
);
endmodule