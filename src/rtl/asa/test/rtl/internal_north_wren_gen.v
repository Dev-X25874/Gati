module internal_north_wren_gen#(
    parameter COL = 4,
    parameter N_SA = 1
)(
    input i_clk,
    input i_rst,
    input [N_SA-1 : 0] i_enb,
    output [(N_SA * COL)-1 : 0] o_wren
);
genvar i;
generate
    for(i = 0; i < N_SA; i = i + 1)begin
        internal_north_wren#(
            .COL(COL),
            .N_SA(N_SA)
        )int_north_wren_ctrl(
            .i_clk(i_clk),
            .i_rst(i_rst),
            .i_enable(i_enb[i]),
            .o_data(o_wren[(COL * (N_SA - i))-1 -: COL]) 
        );
    end
endgenerate
endmodule