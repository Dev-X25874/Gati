`include "real_top.v"
`timescale 1ns/1ps


module real_top_tb();
  reg clkin=1'b0;
  reg user_start;
  reg [31:0]global_start;
  reg [31:0]global_stop;
  reg valid;
  reg sel;
  reg [255:0]instruction_data;
  wire memory_read_r;
  wire memory_valid;
  wire [7:0]mem_address;
  wire mem_last;
  wire [7:0]mem_burst_len;
  reg inst1;
  reg inst2;
  reg inst3;
  reg inst4;

  always #5 clkin=~clkin;
  real_top Pagman(
             .clkin(clkin),
             .user_start(user_start),
             .global_start(global_start),
             .global_stop(global_stop),
             .valid(valid),
             .sel(sel),
             .instruction_data(instruction_data),
             .memory_read_r(memory_read_r),
             .memory_valid(memory_valid),
             .mem_address(mem_address),
             .mem_last(mem_last),
             .mem_burst_len(mem_burst_len),
             .inst1(inst1),
             .inst2(inst2),
             .inst3(inst3),
             .inst4(inst4)
           );

  initial
  begin
    instruction_data=256'b1011111000011110000001;
    user_start=1'b0;
    sel=1'b0;
    valid=1'b0;
    global_start=32'd1234;
    global_stop=32'd4567;
    #10;
    user_start=1'b1;
    #10
    user_start=1'b0;
    #70;
    valid=1'b1;
    sel=1'b1;
    #10
    instruction_data=256'b1011111000011110000010;
    #10;
    instruction_data=256'b1010100101010101000011;
    #10;
    instruction_data=256'b1101010101010101101111;
    #10;
    valid=1'b0;
    sel=1'b0;
    
    #10000;
    $finish;
  end
  initial begin
    $dumpfile("real_top_tb.vcd");
    $dumpvars(0);
end
endmodule
