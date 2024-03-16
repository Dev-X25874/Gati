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
        assign o_wren[i] = i_rst ? 0 : (i_dv[i] & i_sel);
    end
endgenerate
    
endmodule