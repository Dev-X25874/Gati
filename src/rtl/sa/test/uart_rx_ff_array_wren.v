/*
    Assert write enable of external north and west fifo array,
    if the data coming from uart receiver is valid and desired fifo is selected,
    then the data is written into that fifo. Select input is given externally here.
*/
module uart_rx_ff_array_wren#(
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

