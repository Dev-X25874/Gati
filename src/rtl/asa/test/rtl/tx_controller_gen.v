//generate tx controller N_SA times
module tx_controller_gen#(
    parameter N_SA = 4,
    parameter W_PSUM = 19,
    parameter W_DATA = 8
)(
    input i_clk,
    input i_rst,
    input [N_SA-1 : 0] i_fifo_empty,
    output [N_SA-1 : 0] o_fifo_rden,
    input [(N_SA * W_PSUM)-1 : 0] i_data,
    input [N_SA-1 : 0] i_tx_done,
    output [N_SA-1 : 0] o_tx_dv,
    output [(N_SA * W_DATA)-1 : 0] o_tx_data
);

genvar i;
generate
    for(i = 0; i < N_SA; i = i +1)begin
    controller_fifo_tx #(
    .DATA_WIDTH(W_PSUM),
    .UART_WIDTH(W_DATA)
    )tx_ctrl_gen(
        .clk(i_clk),
        .i_rst(i_rst),
        .i_fifo_data(i_data[(W_PSUM * (N_SA - i))-1 -: W_PSUM]),
        .i_empty_flag(i_fifo_empty[i]),
        .o_data(o_tx_data[(W_DATA * (N_SA - i))-1 -: W_DATA]),
        .rd_en(o_fifo_rden[i]),             
        .o_valid_tx2(o_tx_dv[i]),
        .i_trans_done_tx2(i_tx_done[i])
    );

    end
endgenerate
    
endmodule