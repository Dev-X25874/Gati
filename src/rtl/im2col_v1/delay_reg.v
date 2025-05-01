module delay_reg_v1 #(
parameter ROW = 9,
parameter DATA_WIDTH = 8)
(
input clk,
input rst,
input  [ROW-1:0] i_valid_sq,
output reg [ROW-1:0] o_valid_sq,
input  [DATA_WIDTH-1:0] i_data,
output reg [DATA_WIDTH-1:0] o_data
);

genvar i;
generate
for(i=0; i<6; i=i+1) begin: delay

reg [ROW-1:0] r_valid_sq;
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
