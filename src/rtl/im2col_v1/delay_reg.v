module delay_reg_v1 #(
parameter KERNEL_SIZE = 3,
parameter DATA_WIDTH = 8)
(
input clk,
input rst,
input  [KERNEL_SIZE*KERNEL_SIZE-1:0] i_valid_sq,
output reg [KERNEL_SIZE*KERNEL_SIZE-1:0] o_valid_sq,
input  [DATA_WIDTH-1:0] i_data,
output reg [DATA_WIDTH-1:0] o_data
);

genvar i;
generate
for(i=0; i<6; i=i+1) begin: delay

reg [KERNEL_SIZE*KERNEL_SIZE-1:0] r_valid_sq;
reg [DATA_WIDTH-1:0] r_data;

if(i == 0) begin
always @ (posedge clk) begin
r_valid_sq <= (!rst)? 0:i_valid_sq;
r_data <= (!rst)? 0:i_data;
end
end

else if (i == 5) begin
always @ (posedge clk) begin
o_valid_sq <= (!rst)? 0:delay[i-1].r_valid_sq;
o_data <= (!rst)? 0:delay[i-1].r_data;
end
end

else begin
always @ (posedge clk) begin
r_valid_sq <= (!rst)? 0:delay[i-1].r_valid_sq;
r_data <= (!rst)? 0:delay[i-1].r_data;
end
end

end
endgenerate

endmodule
