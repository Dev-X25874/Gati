/*
    Generates fifo N_SA times.
*/
module mul_fifo#(
    parameter W_DATA = 8,
    parameter N_SA = 4,
    parameter W_ADDR = 8
)(
    input i_clk,
    input i_rst,
    input [N_SA-1 : 0] i_write_enable,
    input [N_SA-1 : 0] i_read_enable,
    input [(N_SA * W_DATA)-1 : 0] i_data,
    output [(N_SA * W_DATA)-1 : 0] o_data,
    output [(N_SA * (W_ADDR + 1))-1 : 0] o_occupants,
    output [N_SA-1 : 0] o_empty,
    output [N_SA-1 : 0] o_valid
);

genvar i;
generate
    for(i = 0; i < N_SA; i = i + 1)begin
        
        sync_fifo #(
            .W_DATA(W_DATA),
            .W_ADDR(W_ADDR)
        )fifo_inst(
            .full_o(),
            .empty_o(o_empty[i]),
            .clk_i(i_clk),
            .wr_en_i(i_write_enable[i]),
            .rd_en_i(i_read_enable[i]),
            .wdata(i_data[((W_DATA * (N_SA - i)) -1) -: W_DATA]),
            .datacount_o(o_occupants[((W_ADDR + 1) * (i + 1)) - 1 -: (W_ADDR + 1)]),
            .rst_busy(),
            .rdata(o_data[((W_DATA * (N_SA - i)) -1) -: W_DATA]),
            .a_rst_i(i_rst),
            .o_valid(o_valid[i])
            );
    end
endgenerate
    
endmodule