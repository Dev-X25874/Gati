module onehot_tb();

parameter W_ONEHOT = 4;
onehot_to_bin#(
    .ONEHOT_WIDTH(W_ONEHOT)
)dut(
    .onehot(a),
    .bin(b)
);

reg [3:0] a;
wire [2:0] b;

initial begin
    $dumpfile("result.vcd");
    $dumpvars;
    #10 a <= 4'b0000;
    #10 a <= 4'b0001;
    #10 a <= 4'b0010;
    #10 a <= 4'b0100;
    #10 a <= 4'b1000;
    #10;
    $finish();
end

endmodule