//bus master controller which sends instruction data to slave blocks
//`include "controller.v"
module top_master #(parameter op_code_width = 4, 
            parameter CNT = (data_in/data_out),
            parameter data_in = 256,
            parameter data_out = 8) (
    input [(data_in)-1 : 0] din,
    input start,
    input clk,
    input [(op_code_width)-1 : 0] op_code,
    input [(1<<op_code_width)-1 : 0] ready_in,
    output [(data_out)-1 : 0] dout,
    output [(1<<op_code_width)-1 : 0] sel,
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