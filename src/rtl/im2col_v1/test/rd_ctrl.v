module rd_ctrl #(
parameter DATA_WIDTH = 8,
parameter STRIDE = 2)
(
input clk,
input rst,
input [DATA_WIDTH-1:0] fifo_data,
input empty,
input im2col_start,
input i_valid_buff,
output valid_mat_size,
output valid_data,
output [DATA_WIDTH-1:0] mat_size,
output [DATA_WIDTH-1:0] i_data,
output [3:0] zero_pad,
output [1:0] zero_padded,
output [$clog2(STRIDE):0] stride,
output rd_en,
output [1:0] ksize,
output reg i_im2col_start_index
 );
 
 reg [3:0] state = 0;
 reg r_valid_mat_size = 0;
 reg r_valid_data = 0;
 reg [2*DATA_WIDTH-1:0] counter = 1;
 reg [DATA_WIDTH-1:0] r_mat_size;
 reg [DATA_WIDTH-1:0] r_data;
 reg [DATA_WIDTH-1:0] pad_stride;
 reg r_rd_en = 0;
 
 always @ (posedge clk) begin
 if(!rst) begin
 r_rd_en <= 0;
 state <= 0;
 r_valid_data <= 0;
 r_valid_mat_size <= 0;
 r_mat_size <= 0;
 r_data <= 0;
 pad_stride <= 0;
 counter <= 1;
 i_im2col_start_index <= 0;
 end
 else if (!empty) begin
 case(state)
 0:begin
 if(im2col_start) begin
 r_rd_en <= 1;
 r_valid_data <= 0;
 r_valid_mat_size <= 0;
 state <= 1;
 end
 else begin
 r_rd_en <= 0;
 state <= 0;
 end
 end
 
 1:begin
 r_rd_en <= 0;
 r_valid_data <= 0;
 r_valid_mat_size <= 0;
 state <= 2;
 end
 
 2:begin
 r_mat_size <= fifo_data;
 r_valid_mat_size <= 1;
 r_valid_data <= 0;
 r_rd_en <= 1;
 state <= 3;
 end
 
 3:begin
 r_rd_en <= 0;
 r_valid_data <= 0;
 r_valid_mat_size <= r_valid_mat_size;
 state <= 4;
 end
 
 4:begin
 pad_stride <= fifo_data;
 r_rd_en <= 1;
 r_valid_data <= 0;
 r_valid_mat_size <= r_valid_mat_size;
 state <= 5;
 end
 
 5:begin
 r_rd_en <= 0;
 r_valid_data <= 0;
 r_valid_mat_size <= r_valid_mat_size;
 state <= 6;
 i_im2col_start_index <= 1;
 end
 
 6:begin
 if(counter == r_mat_size*r_mat_size) begin
 r_rd_en <= 0;
 r_data <= fifo_data;
 r_valid_data <= 1;
 counter <= 1;
 state <= 7;
 i_im2col_start_index <= 0;
 end
 
 else if (i_valid_buff) begin
 r_data <= fifo_data;
 r_rd_en <= 1;
 r_valid_data <= 1;
 counter <= counter + 1;
 state <= 6;
 i_im2col_start_index <= 0;
 end
 
 else begin
 r_rd_en <= 0;
 r_valid_data <= 0;
 state <= 6;
 i_im2col_start_index <= 0;
 end
 end
 
 7: begin
 r_rd_en <= 0;
 i_im2col_start_index <= 0;
 state <= 7;
 r_valid_data <= 0;
 end
 endcase
 end
 
 else begin
 r_rd_en <= 0;
 state <= 0;
 end
 end
 
 assign valid_mat_size = r_valid_mat_size;
 assign valid_data = r_valid_data;
 assign mat_size = r_mat_size[7:2];
 assign ksize = r_mat_size[1:0];
 assign i_data = r_data;
 assign zero_pad = pad_stride[7:4];
 assign zero_padded = pad_stride[3:2];
 assign stride = pad_stride[1:0];
 assign rd_en = r_rd_en;
 
 endmodule
 
 