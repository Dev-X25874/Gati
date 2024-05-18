//////////////////////////////////////////////////////////////////////////////////
// Design Name: Config Block
// Module Name: Top Master
// Project Name: Gati
// Description: Bus master controller which sends instruction data to slave blocks in 8 bit chunks.
//////////////////////////////////////////////////////////////////////////////////
//
module top_master #(parameter OP_CODE_WIDTH = 4, 
            parameter CNT = (DATA_IN/DATA_OUT),
            parameter DATA_IN = 256,
            parameter DATA_OUT = 8) (
    input [(DATA_IN)-1 : 0] din,
    input start,
    input clk,
    input [(OP_CODE_WIDTH)-1 : 0] op_code,
    input [(1<<OP_CODE_WIDTH)-1 : 0] ready_in,
    output [(DATA_OUT)-1 : 0] dout,
    output [(1<<OP_CODE_WIDTH)-1 : 0] sel,
    output write,
    output done
);
wire r_in;

controller con(
    .din(din),
    .start(start),
    .ready(r_in),
    .dout(dout),
    .sel(sel),
    .write(write),
    .done(done),
    .clk(clk),
    .op_code(op_code)
);

assign r_in = ready_in[op_code];

endmodule