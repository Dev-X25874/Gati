//generate N_SA times uart rx module
module mul_receiver#(
    parameter W_DATA = 8,
    parameter N_SA = 4
)(  
    input i_clk,
    input i_rst,
    input [N_SA-1 : 0] i_rx_serial,
    output [N_SA-1 : 0] o_rx_dv,
    output [(N_SA * W_DATA)-1 : 0] o_rx_byte
);
  
genvar i;
generate
    for (i = 0; i < N_SA; i = i + 1) begin
        uart_rx
		#(.CLOCKS_PER_BIT(50))receiver
		(
			.i_Clock(i_clk),
            .i_Rst(i_rst),
			.i_RX_Serial(i_rx_serial[i]),
			.o_RX_DV(o_rx_dv[i]),
			.o_RX_Byte(o_rx_byte[((W_DATA * (N_SA - i)) -1) -: W_DATA])
		);
    end
endgenerate
endmodule