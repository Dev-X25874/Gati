module top_test_im2col #(
                    parameter UPPER_BOUND = 28,
                    parameter DATA_WIDTH = 8,
                    parameter LOWER_BOUND = 1,
                    parameter MAX_VALID_SQ = 9,
                    parameter UART_WIDTH = 8)
(
    input  i_bit_data, 
    output o_bit_tx1,
    output o_bit_tx2,
    input  clk,
    input  zero_pad,
    input  rst,
    input  i_start_im2col,
    output o_valid,
    output o_valid_2

);
    wire [UART_WIDTH-1:0]           w_byte;
    wire                            w_valid;
    wire                            w_rd_en1;
    wire [DATA_WIDTH-1:0]           w_data_fifo1;
    wire                            w_empty_flag1;
    wire [$clog2(UPPER_BOUND)-1:0]  w_mat_size;
    wire [DATA_WIDTH-1:0]           w_data_ctrl1;
    wire                            w_valid_im2col;
    wire                            w_valid_buff;  
    wire [MAX_VALID_SQ-1:0]         w_valid_sq; 
    wire [DATA_WIDTH-1:0]           w_data_im2col; 
    wire                            w_valid_fifo;                        
    wire [UART_WIDTH-1:0]           w_data_ctrl_tx1;                     
    wire [UART_WIDTH-1:0]           w_data_ctrl_tx2;
    wire                            w_rd_en2;
    wire [MAX_VALID_SQ-1:0]         w_data_fifo2;
    wire                            w_empty_flag2;
    wire [UART_WIDTH-1:0]           w_data_tx1;
    wire                            w_trans_done_tx1;
    wire                            w_trans_done_tx2;
    wire                            w_valid_tx1;
    wire                            w_rd_en3;
    wire [UART_WIDTH-1:0]           w_data_tx2;
    wire [8:0]                      w_data_fifo3;
    wire                            w_empty_flag3;
    wire                            w_valid_tx2;
    
    wire                            w_start_im2col;


    wire [8:0]                      w_o_data_valid;

/*    reg                             r_start_im2col;
    reg                             r2_start_im2col;
    wire                            w_start_im2col;
always @(posedge clk) begin
    r_start_im2col <= !i_start_im2col;
    r2_start_im2col <= r_start_im2col;
end

assign w_start_im2col = i_start_im2col & ~r2_start_im2col;
*/
assign o_valid_2 = w_trans_done_tx2;
assign o_valid = w_trans_done_tx1;
wire [7:0] trigg;
wire trigg_dv;
wire w_o_valid_mat_size;

uart_rx
trigg_mod(
    .clk (clk),
    .i_data (i_start_im2col),
    .o_data (trigg),
    .o_valid_data (trigg_dv),
    .rx_busy ()
);

uart_rx
rx_mod(
    .clk (clk),
    .i_data (i_bit_data),
    .o_data (w_byte),
    .o_valid_data (w_valid),
    .rx_busy ()
);

fifo #(.DATA_WIDTH(DATA_WIDTH),
       .ADDR_WIDTH(10))
fifo_rx_mod(
    .wr_clk (clk),
    .rd_clk (clk),
    .we (w_valid),
    .re (w_rd_en1),
 //   .re (w_valid_buff),
    .data_in (w_byte),
    .data_out (w_data_fifo1),
    .full_flag (),
    .empty_flag (w_empty_flag1),
    .occupants () 
);

controller_rx_fifo #(.DATA_WIDTH(DATA_WIDTH),
                     .UPPER_BOUND(UPPER_BOUND))
controller_rx_fifo_mod(
    .i_start_im2col_ctrl(trigg_dv),
    .clk (clk),
    .i_fifo_data (w_data_fifo1),
    .fifo_empty_flag (w_empty_flag1),
    .o_mat_size (w_mat_size),
    .o_data (w_data_ctrl1),
    .rd_en (w_rd_en1),
    .o_valid_im2col (w_valid_im2col),
    .i_valid_buff (w_valid_buff),
    .o_valid_mat_size(w_o_valid_mat_size) 
);




top_im2col #(.UPPER_BOUND(UPPER_BOUND),
            .DATA_WIDTH(DATA_WIDTH),
            .LOWER_BOUND(LOWER_BOUND),
            .MAX_VALID_SQ(MAX_VALID_SQ))
top_im2col_mod(
    .i_valid_mat_size (w_o_valid_mat_size),
//    .o_start_im2col (w_start_im2col),
    .i_start_im2col_top   (trigg_dv),
    .i_im2col_data    (w_data_ctrl1),
    .i_clk            (clk),
    .i_rstn           (rst), 
    .o_im2col_data    (w_data_im2col),
    .o_valid_squares  (w_valid_sq),
    .o_row1           (),
    .o_row2           (),
    .o_row3           (),
    .o_row4           (),
    .o_row5           (),
    .o_row6           (),
    .o_row7           (),
    .o_row8           (),
    .o_row9           (),
    .i_mat_size       (w_mat_size),
    .i_zero_pad       (zero_pad),
    .o_valid_data     (w_valid_fifo),
    .o_valid_buff     (w_valid_buff),
    .i_valid_data     (w_valid_im2col)                
);
 

fifo #(.DATA_WIDTH(9),
       .ADDR_WIDTH(10))
fifo_tx1_mod(
    .wr_clk (clk),
    .rd_clk (clk),
    .we (w_valid_fifo),
    .re (w_rd_en2),
    .data_in (w_valid_sq),
    .data_out (w_data_fifo2),
    .full_flag (),
    .empty_flag (w_empty_flag2),
    .occupants () 
);

controller_tx1 #(.DATA_WIDTH (DATA_WIDTH),
                 .UART_WIDTH (UART_WIDTH),
                 .MAX_VALID_SQ (MAX_VALID_SQ)
)
controller_tx1_mod(
    .clk (clk),
    .i_fifo_data_valid_sq (w_data_fifo2),
    .i_empty_flag (w_empty_flag2),
    .o_data_valid_sq (w_data_tx1),
    .rd_en (w_rd_en2),
    .o_valid_tx1 (w_valid_tx1),
    .i_trans_done_tx1 (w_trans_done_tx1)

);
wire         w_done ; 
assign w_done = w_trans_done_tx1 ? 1 : 0;

uart_tx
tx1_mod(
    .i_data_byte (w_data_tx1),
    .o_data_bit (o_bit_tx1),
    .clk (clk),
    .o_done (w_trans_done_tx1),
    .i_valid (w_valid_tx1),
    .tx_busy ()
);


assign w_o_data_valid = {w_valid_fifo,w_data_im2col}; //9 bits output to fifo

fifo #(.DATA_WIDTH(9),
       .ADDR_WIDTH(10))
fifo_tx2_mod(
    .wr_clk (clk),
    .rd_clk (clk),
    .we (w_valid_fifo),
    .re (w_rd_en3),
    .data_in (w_o_data_valid),
    .data_out (w_data_fifo3),
    .full_flag (),
    .empty_flag (w_empty_flag3),
    .occupants () 
);

controller_tx2 #(.DATA_WIDTH(9),
                 .UART_WIDTH(UART_WIDTH))
controller_tx2_mod(
    .clk (clk),
    .i_fifo_data (w_data_fifo3),
    .i_empty_flag (w_empty_flag3),
    .o_data (w_data_tx2),
    .rd_en (w_rd_en3),
    .o_valid_tx2 (w_valid_tx2),
    .i_trans_done_tx2 (w_trans_done_tx2)
);


uart_tx
tx2_mod(
    .i_data_byte (w_data_tx2),
    .o_data_bit (o_bit_tx2),
    .clk (clk),
    .o_done (w_trans_done_tx2),
    .i_valid (w_valid_tx2),
    .tx_busy ()
);


endmodule 