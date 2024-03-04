//stores output os engine and controls the read enable signal of input south fifo array
module external_sa_output_ctrl#(
    parameter COL = 4,
    parameter W_PSUM = 19,
    parameter N_SA = 4
)(
    input i_clk,
    input i_rst,
    input  [((COL * W_PSUM) * N_SA)-1 : 0] i_data,
    input [(COL * N_SA)-1 : 0] i_fifo_empty,
    output [(COL * N_SA)-1 : 0] o_fifo_read_enable,
    output [N_SA-1 : 0] o_fifo_write_enable,
    output [(W_PSUM * N_SA)-1 : 0] o_data
);

genvar i;
generate
    for (i = 0; i < N_SA; i = i + 1) begin
        col_fifo_data#(
            .COL(COL),
            .W_PSUM(W_PSUM)
        ) last_ff_controller (
            .i_clk(i_clk),
            .i_rst(i_rst),
            .i_data(i_data[((COL * W_PSUM) * (N_SA - i))-1 -: (COL * W_PSUM)]),
            .i_fifo_empty(i_fifo_empty[(COL * (N_SA - i))-1 -: COL]),  
            .o_data(o_data[(W_PSUM * (N_SA - i))-1 -: W_PSUM]),
            .wr_en_final_fifo(o_fifo_write_enable[i]),
            .o_read_enable(o_fifo_read_enable[(COL * (N_SA - i))-1 -: COL])
        );
    end
endgenerate
    
endmodule