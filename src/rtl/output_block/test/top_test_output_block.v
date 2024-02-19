module top_test_output_block #(
    parameter               CLKS_PER_BIT = 868,
    parameter               N = 8,
    parameter               DATA_WIDTH = 20,
    parameter               UART_WIDTH = 8,
    parameter               FIFO_NO = 32,
    parameter               FIFO_DEPTH = 50,
    parameter               ADDR_WIDTH = 8,
    parameter               MUX_SEL_WIDTH = 2,
    parameter               OUT_DATA_WIDTH = 20
)(
    input                   clk,
    input                   i_bit_data_rx1,
    input                   i_bit_data_rx2,
    input                   i_trig_fifo_data,
    output                  o_bit_tx

);

    reg                     r1_trig_fifo;
    
    wire                    w_trig_fifo;
    

    always @(posedge clk) begin
        r1_trig_fifo <= i_trig_fifo_data;
    end
    
    assign w_trig_fifo = i_trig_fifo_data & ~r1_trig_fifo;





    wire [UART_WIDTH-1:0]       w_rx_data;
    wire                        w_valid_rx;
    wire [DATA_WIDTH-1:0]       w_data;
    wire                        w_we;
    wire [DATA_WIDTH-1:0]       w_fifo_data;
    wire                        w_fifo_empty_flag;
    wire                        w_rd_en;

    wire [UART_WIDTH-1:0]       w_rx2_data;
    wire                        w_valid2_rx;
    wire [DATA_WIDTH-1:0]       w_data2;
    wire                        w_we2;
    wire [DATA_WIDTH-1:0]       w_fifo_data2;
    wire                        w_fifo_empty_flag2;
    wire                        w_rd_en2;


    wire [FIFO_NO-1:0]          w_we_top;
    wire [DATA_WIDTH-1:0]       w_data_top;
    wire [N-1:0]                w_valid_top;
    wire [N*DATA_WIDTH-1:0]     w_data_adder_tree_top;
    wire [DATA_WIDTH*N-1:0]     w_data_out_top;
    wire [N-1:0]                w_data_valid;

    wire [N-1:0]                w_rd_en_tx;
    wire [N*DATA_WIDTH-1:0]     w_data_out;
    wire [N-1:0]                w_empty_flag;
    wire [DATA_WIDTH-1:0]       w_data_out_fifo;

    wire                        w_wr_en;
    wire                        w_read_en;
    wire                        w_empty_flag_tx;
    wire [DATA_WIDTH-1:0]       w_data_out_tx;
    wire [UART_WIDTH-1:0]       w_data_tx;
    wire                        w_o_valid_tx;
    wire                        w_o_trans_done;

    wire [11:0]                 w_occupants;
    wire [DATA_WIDTH-1:0]       w_data_rx_ctrl;
    wire                        w_flag_adder;

    wire                        w_done;


uart_rx #(
    .CLKS_PER_BIT       (CLKS_PER_BIT)
)rx1_mod
(
    .clk                (clk),
    .i_data             (i_bit_data_rx1),
    .o_data             (w_rx_data),
    .o_valid_data       (w_valid_rx),
    .rx_busy            ()

);

rx_controller #(
    .UART_WIDTH         (UART_WIDTH),
    .DATA_WIDTH         (DATA_WIDTH)
)
rx1_controller_8_to_20_mod(
    .rx_data_in         (w_rx_data),
    .rx_valid           (w_valid_rx),
    .fifo_out           (w_data),
    .we                 (w_we),
    .clk                (clk)
);




fifo #(
    .DATA_WIDTH         (DATA_WIDTH),
    .ADDR_WIDTH         (12)
)fifo1_mod
(
    .wr_clk             (clk),
    .rd_clk             (clk),
    .we                 (w_we),
    .re                 (w_rd_en),
    .data_in            (w_data),
    .data_out           (w_fifo_data),
    .full_flag          (),
    .empty_flag         (w_fifo_empty_flag),
    .occupants          ()

);


rx_controller_fifo_data #(
    .DATA_WIDTH         (DATA_WIDTH),
    .FIFO_NO            (FIFO_NO),
    .N                  (N),
    .FIFO_DEPTH         (FIFO_DEPTH) 
) rx1_controller_mod
(
    .i_trig_fifo        (w_trig_fifo),
    .clk                (clk), 
    .i_fifo_data        (w_fifo_data),
    .fifo_empty_flag    (w_fifo_empty_flag),
    .rd_en              (w_rd_en),
    .o_data             (w_data_rx_ctrl),
    .wr_en_ctrl         (w_we_top),
    .flag_adder         (w_flag_adder)

);

uart_rx #(
    .CLKS_PER_BIT       (CLKS_PER_BIT)
)rx2_mod
(
    .clk                (clk),
    .i_data             (i_bit_data_rx2),
    .o_data             (w_rx2_data),
    .o_valid_data       (w_valid2_rx),
    .rx_busy            ()

);

rx_controller #(
    .UART_WIDTH         (UART_WIDTH),
    .DATA_WIDTH         (DATA_WIDTH)
)
rx2_controller_8_to_20_mod(
    .rx_data_in         (w_rx2_data),
    .rx_valid           (w_valid2_rx),
    .fifo_out           (w_data2),
    .we                 (w_we2),
    .clk                (clk)
);


fifo #(
    .DATA_WIDTH         (DATA_WIDTH),
    .ADDR_WIDTH         (12)  // clog2 of (32*256)
)fifo2_mod
(
    .wr_clk             (clk),
    .rd_clk             (clk),
    .we                 (w_we2),
    .re                 (w_rd_en2),
    .data_in            (w_data2),
    .data_out           (w_fifo_data2),
    .full_flag          (),
    .empty_flag         (w_fifo_empty_flag2),
    .occupants          (w_occupants)

);


rx_controller_adder_tree #(
    .ADDR_WIDTH (12),
    .N (N),
    .DATA_WIDTH         (DATA_WIDTH),
    .UART_WIDTH         (UART_WIDTH),
    .FIFO_NO            (FIFO_NO),
    .FIFO_DEPTH         (200) // Because (32*256/8)

) rx2_controller_mod
(
    .fifo_empty_flag    (w_fifo_empty_flag2),
    .occupants          (w_occupants),
    .i_fifo_data        (w_fifo_data2),
    .rd_en              (w_rd_en2),
    .clk                (clk),
    .i_trig_adder       (w_trig_fifo),
    .wr_en              (w_valid_top),
    .o_adder_tree_data  (w_data_adder_tree_top),
    .flag_ctrl_adder    (w_flag_adder),
    .done (w_done)


);






top_output_block #(
    .DATA_WIDTH         (DATA_WIDTH),
    .ADDR_WIDTH         (8),
    .N                  (N),
    .FIFO_NO            (FIFO_NO),
    .MUX_SEL_WIDTH      (MUX_SEL_WIDTH),
    .OUT_DATA_WIDTH     (OUT_DATA_WIDTH)
) top_output_block_mod
(
    .top_clk                (clk),
    .top_wr_en              (w_we_top),
    .top_data_in            (w_fifo_data),
    .top_data_out           (w_data_out_top),
    .top_data_in_adder_tree (w_data_adder_tree_top),
    .top_in_data_valid      (w_valid_top),
    .top_out_data_valid     (w_data_valid),
    .top_flag_adder         (w_flag_adder),
    .top_done               (w_done)
);

fifo_gen_adder #(
    .DATA_WIDTH         (DATA_WIDTH),
    .ADDR_WIDTH         (12),
    .FIFO_NO            (N)
) fifo_gen8_output
(
    .gen_wr_clk         (clk),
    .gen_rd_clk         (clk),
    .gen_we             (w_data_valid),
    .gen_re             (w_rd_en_tx),
    .gen_data_in        (w_data_out_top),
    .gen_data_out       (w_data_out),
    .gen_full_flag      (),
    .gen_empty_flag     (w_empty_flag),
    .gen_occupants      ()
);


tx_controller_adder_tree #(
    .N                  (N),
    .DATA_WIDTH         (DATA_WIDTH),
    .UART_WIDTH         (UART_WIDTH),
    .FIFO_NO            (N),
    .FIFO_DEPTH         (200)
) tx_controller
(
    .clk                (clk),
    .rd_en              (w_rd_en_tx),
    .data_in            (w_data_out),
    .empty_flag         (w_empty_flag),
    .data_out_fifo      (w_data_out_fifo),
    .wr_en              (w_wr_en)

);

fifo #(
    .DATA_WIDTH         (DATA_WIDTH),
    .ADDR_WIDTH         (12)
)fifo_mod_output
(
    .wr_clk             (clk),
    .rd_clk             (clk),
    .we                 (w_wr_en),
    .re                 (w_read_en),
    .data_in            (w_data_out_fifo),
    .data_out           (w_data_out_tx),
    .full_flag          (),
    .empty_flag         (w_empty_flag_tx),
    .occupants          ()

);



tx_controller_fifo #(
    .DATA_WIDTH         (DATA_WIDTH),
    .UART_WIDTH         (UART_WIDTH)
)
tx_controller_20_to_8_mod (
    .clk                (clk),
    .i_fifo_data        (w_data_out_tx),
    .i_empty_flag       (w_empty_flag_tx),
    .o_data             (w_data_tx),
    .rd_en              (w_read_en),
    .o_valid_tx         (w_o_valid_tx),
    .i_trans_done_tx    (w_o_trans_done)


);





uart_tx #(
    .CLKS_PER_BITS      (CLKS_PER_BIT)
)
tx_mod(
    .i_data_byte        (w_data_tx),
    .o_data_bit         (o_bit_tx),
    .clk                (clk),
    .o_done             (w_o_trans_done),
    .i_valid            (w_o_valid_tx),
    .tx_busy            ()
);





endmodule 