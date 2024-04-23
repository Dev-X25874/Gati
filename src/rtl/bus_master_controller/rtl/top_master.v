module top_master #(parameter OP_CODE_WIDTH = 4, 
            parameter CNT = (INPUT_WIDTH/OUTPUT_WIDTH),
            parameter INPUT_WIDTH = 256,
            parameter OUTPUT_WIDTH = 8) (
    input [(INPUT_WIDTH)-1 : 0] din,
    input start,
    input clk,
    input [(OP_CODE_WIDTH)-1 : 0] op_code,
    input [(OP_CODE_WIDTH)-1 : 0] ready_in,
    output [(OUTPUT_WIDTH)-1 : 0] dout,
    output [(OP_CODE_WIDTH)-1 : 0] sel,
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