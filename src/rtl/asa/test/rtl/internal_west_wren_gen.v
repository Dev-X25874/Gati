module internal_west_wren_gen#(
    parameter ROW = 9,
    parameter N_SA = 1
)(
    input i_clk,
    input i_rst,
    input [N_SA-1 : 0] i_enb,
    output [(N_SA * ROW)-1 : 0] o_wren
);

genvar i;
generate
    for(i = 0; i < N_SA; i = i +1)begin
        internal_west_wren#(
            .ROW(ROW)
        )int_west_wren_ctrl(
            .i_clk(i_clk),
            .i_enable(i_enb[i]),
            .i_rst(i_rst),
            .o_data(o_wren[(ROW * (N_SA - i))-1 -: ROW]) 
        );
    end
endgenerate
    
endmodule