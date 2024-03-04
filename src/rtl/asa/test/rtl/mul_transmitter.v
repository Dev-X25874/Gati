/*
    Generate uart transmitter N_SA times,
    output of each engine receives into each tranmsitter
*/
module mul_transmitter#(
    parameter W_DATA = 8,
    parameter N_SA = 4
)(  
    input i_clk,
    input i_rst,
    input [N_SA-1 : 0] i_tx_dv,
    input [(N_SA * W_DATA)-1 : 0] i_tx_byte,
    output [N_SA-1 : 0] o_tx_done,
    output [N_SA-1 : 0] o_tx_serial
);
  
genvar i;
generate
    for (i = 0; i < N_SA; i = i + 1) begin
        uart_tx#(
            .CLKS_PER_BIT(50)
        )transmitter(
            .i_Rst(i_rst),
            .i_Clock(i_clk),
            .i_TX_DV(i_tx_dv[i]),
            .i_TX_Byte(i_tx_byte[((W_DATA * (N_SA - i)) -1) -: W_DATA]),
            .o_TX_Active(),
            .o_TX_Serial(o_tx_serial[i]),
            .o_TX_Done(o_tx_done[i])
		);
    end
endgenerate
endmodule