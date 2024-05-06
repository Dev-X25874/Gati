/*
    Receives data from DDR, flatten it and stores it into BRAM array.
    Further, the data from BRAM is sent into a mux, which receives data 
    channel-wise, and send one byte at a time as output.
*/
module test_flattening#(
    parameter W_DATA = 8,
    parameter W_ADDR = 9,
    parameter N_BRAM = 8,                                      
    parameter N_BANK = 4,                                    
    parameter W_KERNAL_CNT = 16,
    parameter W_IMG_DIM = 20,
    parameter W_IMG_BRAM_ADDR = 10
)(
    input clk,
    input rst,
    input flatten,                                             
    input i_acc_valid,                                         
    input [W_IMG_BRAM_ADDR-1 : 0] i_addr_counter,              
    input [W_KERNAL_CNT-1 : 0] i_kernal_counter,               
    input [(N_BANK * N_BRAM)-1 : 0] i_data_valid,              
    input [(N_BANK * N_BRAM)-1 : 0] i_weight_ff_array_empty,    
    input [W_IMG_DIM-1 : 0] i_image_dimension,                 
    input [((N_BANK * N_BRAM) * W_DATA)-1 : 0]  i_data,         
    output [W_DATA-1 : 0] o_data_mux,                          
    output o_data_valid,                                        
    output weight_fifo_array_trigger,                           
    output o_done_rden_ctrl                                    
);

wire flattened_data_valid;
wire [((N_BANK * N_BRAM) * W_DATA)-1 : 0] flattened_data;
/*
    Controller to rewire the incoming data from DDR,
    in order to flatten it
*/
flattening_controller#(
    .N_BRAM(N_BRAM),
    .N_BANK(N_BANK),
    .W_DATA(W_DATA)
)data_flattening(
    .clk(clk),
    .rst(rst),
    .i_valid(i_data_valid),
    .flatten(flatten),
    .i_data(i_data),
    .o_data(flattened_data),
    .data_valid(flattened_data_valid)
);

wire [(N_BANK * (W_ADDR + 1))-1 : 0] w_addr_we_ctrl_bram_array;
wire wren_done_bram_we_ctrl_bram_re_ctrl;
wire [(N_BANK * N_BRAM)-1 : 0] wren_ctrl_bram_array;
wire [((N_BANK * N_BRAM) * W_DATA)-1 : 0] data_we_ctrl_bram_array;
wire [W_KERNAL_CNT-1:0] kernal_cnt_rden_ctrl_wren_ctrl;
/*
    Controls write enable signal of BRAMs
*/
test_bram_wren_ctrl#(
    .N_BRAM(N_BRAM),
    .N_BANK(N_BANK),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .W_KERNAL_CNT(W_KERNAL_CNT),
    .W_IMG_BRAM_ADDR(W_IMG_BRAM_ADDR)
)bram_array_wren(
    .clk(clk),
    .rst(rst),
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
wire [(N_BANK * (W_ADDR + 1))-1 : 0] r_addr_rd_ctrl_bram_array;
wire [((N_BANK * N_BRAM) * W_DATA)-1 : 0] bram_array_data_out;
/*
    Array of BRAM to store flattened data
*/
bram_bank_array#(
    .N_BANK(N_BANK),                //number of banks of bram
    .N_BRAM(N_BRAM),                //total brams in one bank
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

reg [N_BRAM-1 : 0] mux_rden;
reg [N_BANK-1 : 0] mux_bank_en;
always @(posedge clk) begin
    mux_rden <= read_valid;
    mux_bank_en <= bank_enable_rden_ctrl_bram_bank;
end

wire [N_BRAM-1 : 0] rden_ctrl_bram_bank;
wire [N_BANK-1 : 0] bank_enable_rden_ctrl_bram_bank;

/*
    Controls read enable signal of BRAMs
*/
bram_rden_controller#(
    .W_KERNAL_CNT(W_KERNAL_CNT),
    .W_IMG_DIM(W_IMG_DIM),
    .N_BRAM(N_BRAM),
    .N_BANK(N_BANK),
    .W_ADDR(W_ADDR),
    .W_IMG_BRAM_ADDR(W_IMG_BRAM_ADDR)
)bram_read_controller(
    .clk(clk),
    .rst(rst),
    .w_done(wren_done_bram_we_ctrl_bram_re_ctrl),
    .accumulator_valid(i_acc_valid),
    .flatten(flatten),
    .i_addr_counter(i_addr_counter),
    .kernal_count(i_kernal_counter),
    .weight_ff_array_empty(i_weight_ff_array_empty),
    .image_dimension(i_image_dimension),
    .o_read_enable(rden_ctrl_bram_bank),
    .o_done(o_done_rden_ctrl),
    .o_bank_address(r_addr_rd_ctrl_bram_array),
    .o_bank_enable(bank_enable_rden_ctrl_bram_bank),
    .kernal_counter(kernal_cnt_rden_ctrl_wren_ctrl),
    .weight_ff_trigger(weight_fifo_array_trigger)
);

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
    .rst(rst),
    .i_rden(mux_rden),
    .i_bank_en(mux_bank_en),
    .i_data(bram_array_data_out),
    .o_data(o_data_mux),
    .data_valid(o_data_valid)
);

endmodule