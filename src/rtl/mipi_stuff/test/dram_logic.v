//dummy DDR logic just for testing purpose
module dram_logic #(
parameter BURST_LEN = 16,
parameter AXI_DATA_WIDTH = 256,
parameter W_ADDR = 8)

(
input  clk,
input  rst,
input  i_valid,
input  [W_ADDR-1:0] addr,
input  last,
input  [$clog2(BURST_LEN)-1:0] blen,
output reg select,
output reg data_last,
output reg o_valid,
output [AXI_DATA_WIDTH-1:0] data
);

reg [AXI_DATA_WIDTH-1:0] mem [31:0];
reg [AXI_DATA_WIDTH-1:0] r_data = 0;
reg [W_ADDR-1:0] r_addr = 0;
reg [$clog2(BURST_LEN)-1:0] r_blen = 0;
reg [3:0] state = 0;
reg [4:0] blen_counter = 0;
reg [3:0] count = 0;

initial begin
    $readmemh("mipi.mem", mem);
end

assign data = r_data;

always @ (posedge clk) begin
if(!rst) begin
r_data <= 0;
r_addr <= 0;
r_blen <= 0;
select <= 0;
data_last <= 0;
o_valid <= 0;
blen_counter <= 0;
count <= 0;
state <= 0;
end

else begin
case(state)
0:begin
if(i_valid) begin
if(last) begin
r_addr <= r_addr;
r_blen <= r_blen;
state <= 1;
end
else begin
r_addr <= addr;
r_blen <= blen;
state <= 0;
end
end
else begin
r_addr <= 0;
r_blen <= 0;
state <= 0;
end
end

1:begin
if(count == 7) begin
state <= 2;
count<= 0;
end
else begin
state <= 1;
count<= count + 1;
end
end

2:begin //sending data from mem file according to th burst length received from memory request controller
if(blen_counter < (r_blen + 1)) begin
select <= 1;
o_valid <= 1;
r_data <= mem[blen_counter];
blen_counter <= blen_counter + 1;
state <= 2;
end
else if (blen_counter == (r_blen + 1)) begin
select <= 1;
o_valid <= 1;
r_data <= mem[blen_counter];
blen_counter <= blen_counter + 1;
state <= 2;
data_last <= 1;
end
else begin
select <= 0;
o_valid <= 0;
data_last <= 0;
blen_counter <= 0;
state <= 0;
end
end
endcase
end
end

endmodule