//assert write enable of external north and west fifo array
module wren#(
    parameter N_SA = 4
)(
    input [N_SA-1 : 0] i_dv,
    input i_sel,
    input i_rst,
    output [N_SA-1 : 0] o_wren
);

genvar i;
generate
    for(i = 0; i < N_SA; i = i + 1)begin
        dv_wren wren_controller(
            .i_dv(i_dv[i]),
            .i_rst(i_rst),
            .i_sel(i_sel),
            .wren_o(o_wren[i])
        );
    end
endgenerate
    
endmodule

//check uart rx data valid signal and select input to assert write enable
module dv_wren (
    input i_dv,
    input i_sel,
    input i_rst,
    output wren_o
);
assign wren_o = i_rst ? 0 : (i_dv & i_sel);
    
endmodule