module top #(parameter DATA_OUT_WIDTH = 20, parameter DESIGN_NO = 8, parameter ADDR_WIDTH = 8)(
    input [(DESIGN_NO * DATA_OUT_WIDTH)-1 :0] first_sa1_out,
    input [(DESIGN_NO * DATA_OUT_WIDTH)-1 :0] second_sa2_out,
    input [(DESIGN_NO * DATA_OUT_WIDTH)-1 :0] first_sa3_out,
    input [(DESIGN_NO * DATA_OUT_WIDTH)-1 :0] second_sa4_out,
    input [(DESIGN_NO * DATA_OUT_WIDTH)-1 :0] first_sa5_out,
    input [(DESIGN_NO * DATA_OUT_WIDTH)-1 :0] second_sa6_out,
    input [(DESIGN_NO * DATA_OUT_WIDTH)-1 :0] first_sa7_out,
    input [(DESIGN_NO * DATA_OUT_WIDTH)-1 :0] second_sa8_out,
    input [DESIGN_NO-1 : 0]valid,
    input clk,
    input rst,
    output [DATA_OUT_WIDTH-1 :0] data_out_final,
    output re,
    output empty_out,
    output [ADDR_WIDTH:0] occupants_out
);

top_main_des_gen top1(
    .first_sa1_out(first_sa1_out),
    .second_sa2_out(second_sa2_out),
    .first_sa3_out(first_sa3_out),
    .second_sa4_out(second_sa4_out),
    .first_sa5_out(first_sa5_out),
    .second_sa6_out(second_sa6_out),
    .first_sa7_out(first_sa7_out),
    .second_sa8_out(second_sa8_out),
    .valid(valid),
    .clk(clk),
    .rst(rst),
    .empty(empty_flag),
    .re_en(read_enable),
    .dout(data_out) 
);

controller_after_main_design_gen con_after_main_des(
    .i_clk(clk),
    .i_data(data_out),
    .i_fifo_empty(empty_flag),
    .o_data(data_out_final_fifo),
    .wr_en_final_fifo(write_enable),
    .o_read_enable(read_enable)
);

fifo_valid #(.DATA_WIDTH(20), .ADDR_WIDTH(10)) fifo_tx(
    .clk(clk),
    .rst_n(rst),
    .data_in(data_out_final_fifo),
    .we(write_enable),
    .re(re),
    .data_out(data_out_final),
    .occupants(occupants_out),
    .empty(empty_out),
    .full(),
    .data_valid()
);


endmodule