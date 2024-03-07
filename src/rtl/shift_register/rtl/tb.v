module tb #(parameter no_of_blocks = 4)();
    reg [31:0] intermediate_result;
    reg [7:0] quantized_result_in;
    reg sel;
    reg valid_intermediate_result;
    reg valid_quantized_result;
    reg clk;
    wire valid_out_final;
    wire [(no_of_blocks * 8) - 1 : 0] data_out;

top_gen top_gen(
    .intermediate_result(intermediate_result),
    .quantized_result_in(quantized_result_in),
    .sel(sel),
    .valid_intermediate_result(valid_intermediate_result),
    .valid_quantized_result(valid_quantized_result),
    .valid_out_final(valid_out_final),
    .clk(clk),
    .data_out(data_out)
);

initial begin
    intermediate_result = 0;
    quantized_result_in = 0;
    sel = 0;
    valid_intermediate_result = 0;
    valid_quantized_result = 0;
    clk = 0;
end

always #5 clk = ~clk;

initial begin
    $dumpfile("shift_reg_results.vcd");
    $dumpvars(0,tb);
    valid_quantized_result = 1'b1;
    sel = 1'b1;
    intermediate_result = 32'd4294967295; //32'd2147483647;
    quantized_result_in = 8'd187;
#10 quantized_result_in = 8'd189;    
#10 quantized_result_in = 8'd191;
#10 quantized_result_in = 8'd193;
#20 quantized_result_in = 8'd195;
#10 quantized_result_in = 8'd198;
#10 quantized_result_in = 8'd202;
#10 quantized_result_in = 8'd205;
    #50;
    $finish;
end

endmodule