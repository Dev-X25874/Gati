/*  This is a demux module with parameterized number of ports and data width. 
    Based on 'i_Sel' the input data is placed in the appropriate output slice part.
    Note that output data slice starts from MSB with 'i_sel=0'. For susbsequent 'i_sel' 
    values, the data slice is shifted to the right.
*/

module demux_param #(
    parameter N_PORT = 2,
    parameter DATA_WIDTH = 32
) (
    input [DATA_WIDTH-1:0] i_din,
    input [$clog2(N_PORT)-1:0] i_sel,
    output [N_PORT*DATA_WIDTH-1:0] o_dout
);

    reg [N_PORT*DATA_WIDTH-1:0] r_o_dout;

    always@(*) begin
        r_o_dout = 0;
        r_o_dout[(DATA_WIDTH*(N_PORT-i_sel)-1) -: DATA_WIDTH] = i_din;
    end

    assign o_dout = r_o_dout;
endmodule