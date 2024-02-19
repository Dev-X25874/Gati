//`include "fifo.v"
//`include "mux.v"
//`include "adder.v"
//`include "controller_fifo.v"

module top_output_block # (
    parameter           DATA_WIDTH = 8,
    parameter           ADDR_WIDTH = 8,
    parameter           N = 8,
    parameter           FIFO_NO = 32,
    parameter           MUX_SEL_WIDTH = 2,
    parameter           OUT_DATA_WIDTH = 8

)(
    input                               top_clk,
    input [FIFO_NO-1:0]                 top_wr_en,
    input [DATA_WIDTH-1:0]              top_data_in,
    output [OUT_DATA_WIDTH*N-1:0]       top_data_out,
    input [DATA_WIDTH*N-1:0]            top_data_in_adder_tree,
    input [N-1:0]                       top_in_data_valid,
    output [N-1:0]                      top_out_data_valid,
    input                               top_flag_adder,
    input                               top_done

);





    wire [DATA_WIDTH*FIFO_NO-1:0]       w_data_out;
    wire [MUX_SEL_WIDTH*N-1:0]          w_mux_sel;
    wire [DATA_WIDTH*N-1:0]             w_data_in_fifo;
    wire [FIFO_NO-1:0]                  w_rd_en;
    wire [FIFO_NO-1:0]                  w_empty_flag;
    wire [N-1:0]                        w_valid_fifo;



fifo_gen #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .FIFO_NO(FIFO_NO)
)
fifo_gen_mod(
    .gen_wr_clk(top_clk),
    .gen_rd_clk(top_clk),
    .gen_we(top_wr_en),
    .gen_re(w_rd_en),
    .gen_data_in(top_data_in),
    .gen_data_out(w_data_out),
    .gen_full_flag(),
    .gen_empty_flag(w_empty_flag),
    .gen_occupants()

);




mux_gen #(
    .DATA_WIDTH(DATA_WIDTH),
    .MUX_SEL_WIDTH(MUX_SEL_WIDTH),
    .N(N)

)
mux_gen_mod(
    .gen_fifo_data1(w_data_out[(N*DATA_WIDTH)-1:0]),
    .gen_fifo_data2(w_data_out[(2*N*DATA_WIDTH)-1:N*DATA_WIDTH]),
    .gen_fifo_data3(w_data_out[(3*N*DATA_WIDTH)-1:2*N*DATA_WIDTH]),
    .gen_fifo_data4(w_data_out[(4*N*DATA_WIDTH)-1:3*N*DATA_WIDTH]),
    .gen_mux_sel(w_mux_sel),
    .gen_data_o_fifo(w_data_in_fifo)


);

controller_fifo_des #(
    .DATA_WIDTH(DATA_WIDTH),
    .N(N),
    .FIFO_NO(FIFO_NO),
    .MUX_SEL_WIDTH(MUX_SEL_WIDTH)

)
controller_fifo_des_mod(
    .valid_rd_en(w_rd_en),
    .empty_flag(w_empty_flag),
    .clk(top_clk),
    .mux_sel(w_mux_sel),
    .valid_fifo(w_valid_fifo),
    .flag_adder_ctrl_des (top_flag_adder),
    .acc_done (top_done)
);

adder_gen #(
    .DATA_WIDTH(DATA_WIDTH),
    .OUT_DATA_WIDTH(OUT_DATA_WIDTH),
    .N(N)
)
adder_gen_mod(
    .gen_data_in_adder_tree(top_data_in_adder_tree),
    .gen_data_in_fifo(w_data_in_fifo),
    .gen_clk(top_clk),
    .gen_data_valid_fifo(w_valid_fifo),
    .gen_data_in_valid(top_in_data_valid),
    .gen_data_out_valid(top_out_data_valid),
    .gen_data_out_adder(top_data_out)
);



endmodule