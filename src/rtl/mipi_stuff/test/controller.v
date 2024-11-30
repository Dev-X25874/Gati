module controller #(
parameter ADDR_W = 32,
parameter DATA_SIZE = 20,
parameter ID = 10)
(
input clk,
input rst,
input [(ADDR_W+DATA_SIZE+ID)-1:0] din,
input empty,
input fifo_valid,
output [ADDR_W-1:0] addr,
output [DATA_SIZE-1:0] data_size,
output [ID-1:0] id,
output reg valid,
output reg rd_en
);

reg [ADDR_W-1:0] r_addr = 0;
reg [DATA_SIZE-1:0] r_data_size = 0;
reg [ID-1:0] r_id = 0;
reg [2:0] state = 0;

assign addr = r_addr;
assign data_size = r_data_size;
assign id = r_id;

always @ (posedge clk) begin
if(!rst) begin
r_addr <= 0;
r_data_size <= 0;
r_id <= 0;
valid <= 0;
rd_en <= 0;
state <= 0;
end

else begin
case(state)
0:begin
valid <= 0;
if(!empty) begin
state <= 1;
rd_en <= 1;
end
else begin
state <= 0;
rd_en <= 0;
end
end

1: begin
rd_en <= 0;
valid <= 1;
if(fifo_valid) begin
r_addr <= din[61:30];
r_data_size <= din[29:10];
r_id <= din[9:0];
state <=0;
end
end
endcase
end
end

endmodule
