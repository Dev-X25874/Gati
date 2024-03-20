`include "top_mod.v"
`timescale 1ns/1ps

module top_mod_tb();
reg clkin=1'b0;
reg user_start;
reg ctrl_q_valid;
reg ctrl_q_sel;
reg bus_start;
reg [5:0]total_layer_1;
reg [31:0]global_start;
reg [31:0]global_stop;
reg [255:0]instruction_data;
wire memory_read_r;
wire memory_valid;
wire [7:0]mem_address;
wire mem_last;
wire [7:0]mem_burst_len;
wire [3:0]ack_sig;
wire [7:0]next_out;

always #5 clkin=~clkin;
top_mod AAAAAAAAAAAAH(.clkin(clkin),
.user_start(user_start),
.ctrl_q_valid(ctrl_q_valid),
.ctrl_q_sel(ctrl_q_sel),
.global_start(global_start),
.global_stop(global_stop),
.instruction_data(instruction_data),
.memory_read_r(memory_read_r),
.memory_valid(memory_valid),
.mem_address(mem_address),
.mem_last(mem_last),
.mem_burst_len(mem_burst_len)
);
initial begin
instruction_data=256'd123456;
user_start=1'b0;
ctrl_q_sel=1'b0;
ctrl_q_valid=1'b0;
global_start=32'd1234;
global_stop=32'd4567;
total_layer_1=6'd10;
#10;
user_start=1'b1;
#10;
user_start=1'b0;
#40;
ctrl_q_sel=1'b1;
ctrl_q_valid=1'b1;
#30;
ctrl_q_sel=1'b0;
ctrl_q_valid=1'b0;
#820;
instruction_data=256'd234567;
ctrl_q_sel=1'b1;
ctrl_q_valid=1'b1;
#30;
ctrl_q_sel=1'b0;
ctrl_q_valid=1'b0;
#820;
ctrl_q_sel=1'b1;
ctrl_q_valid=1'b1;
instruction_data=256'd111111;
#30;
ctrl_q_sel=1'b0;
ctrl_q_valid=1'b0;
#10000;
$finish;
end
initial begin
    $dumpfile("top_mod_tb.vcd");
    $dumpvars(0);
end
endmodule