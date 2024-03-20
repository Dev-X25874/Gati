module tb #(parameter op_code_width = 4, 
            parameter CNT = (data_in/data_out),
            parameter data_in = 256,
            parameter data_out = 8) ();
reg [(data_in)-1 : 0] din;
reg start;
reg clk;
reg [(op_code_width)-1 : 0] op_code;
reg [(1<<op_code_width)-1 : 0] ready;
wire [(data_out)-1 : 0] dout;
wire [(1<<op_code_width)-1 : 0] sel;
wire write;
wire done;

top top(
.din(din),
.start(start),
.ready_in(ready),
.dout(dout),
.sel(sel),
.write(write),
.done(done),
.clk(clk),
.op_code(op_code)
);

initial begin
    din = 0;
    start = 0;
    ready = 0;
    clk = 0;
end

always #5 clk = ~clk;

initial begin
    $dumpfile("bus_master.vcd");
    $dumpvars(0,tb);
    start = 1'b1;
    op_code = 0;
    ready = 16'd1;
#10 din = 256'd132821740927842102801075689470070844189411282848698288817893419585226892924273;
    #500;
    $finish;
end

endmodule