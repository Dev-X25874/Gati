module top_resize_block#(
    parameter AXI_DATA_BYTES = 32,
    parameter DATA_WIDTH = 8,
    parameter FIFO_NO = 32,
    parameter N_SA = 4,
    parameter RESIZE_IW_WIDTH = 10,
    parameter RESIZE_IH_WIDTH = 10,
    parameter RESIZE_IC_WIDTH = 12,
    // parameter START_ADDRESS_W     = 32,
    // parameter END_ADDRESS_W       = 32,
    parameter W_ADDR = 9,
    parameter MOD2 = 8
)(
    input                                             i_clk,
    input                                             i_rst,
    input [RESIZE_IW_WIDTH-1:0]                       i_resize_IW,
    input [RESIZE_IH_WIDTH-1:0]                       i_resize_IH,
    input                                             i_data_valid,
    input [(AXI_DATA_BYTES*DATA_WIDTH)/N_SA - 1 : 0]  i_data,
    input                                             i_resize_start,

    output                                            o_busy,
    output [DATA_WIDTH-1:0]                           o_data,
    output                                            o_valid,
    output                                            o_done,
    output                                            o_send_read,
    output                                            o_wr_done
);

    wire                  w_wr_en;
    wire [W_ADDR-1:0]     w_wr_addr;
    wire [DATA_WIDTH-1:0] w_wr_data;
    wire                  w_rd_en;
    wire [W_ADDR-1:0]     w_rd_addr;
    wire [DATA_WIDTH-1:0] bram_rd_data;
    wire                  w_done;

    gen_bram_resize #(
        .W_DATA(DATA_WIDTH),
        .W_ADDR(W_ADDR)
    ) gen_bram_resize_inst (
        .clk(i_clk),
        .wr_en(w_wr_en),
        .wr_addr(w_wr_addr),
        .wr_data(w_wr_data),
        .rd_en(w_rd_en),
        .rd_addr(w_rd_addr),
        .rd_data(bram_rd_data)
    );
    wire w_start_rd;
    bram_wr_ctrl_resize #(
        .FIFO_NO(FIFO_NO),
        .DATA_WIDTH(DATA_WIDTH),
        .N_SA(N_SA),
        .RESIZE_IW_WIDTH(RESIZE_IW_WIDTH),
        .RESIZE_IH_WIDTH(RESIZE_IH_WIDTH),
        .W_ADDR(W_ADDR),
        .MOD2(MOD2)
    ) bram_wr_ctrl_resize_inst (
        .clk(i_clk),
        .rst(i_rst),
        .i_data_valid(i_data_valid),
        .i_data(i_data),
        .i_image_width(i_resize_IW),
        .i_image_height(i_resize_IH),
        .o_wr_en(w_wr_en),
        .o_wr_addr(w_wr_addr),
        .o_wr_data(w_wr_data),
        .o_done(o_wr_done),
        .o_busy(o_busy),
        .i_resize_start(i_resize_start),
        .o_send_read(o_send_read),
        .o_start_rd(w_start_rd)
    );

    bram_rd_ctrl_resize #(
        .FIFO_NO(FIFO_NO),
        .DATA_WIDTH(DATA_WIDTH),
        .N_SA(N_SA),
        .RESIZE_IW_WIDTH(RESIZE_IW_WIDTH),
        .RESIZE_IH_WIDTH(RESIZE_IH_WIDTH),
        .W_ADDR(W_ADDR),
        .MOD2(MOD2)
    ) bram_rd_ctrl_resize_inst(
        .clk(i_clk),
        .rst(i_rst),
        .i_image_width(i_resize_IW),
        .i_image_height(i_resize_IH),
        .i_resize_start(w_start_rd),
        .o_rd_en(w_rd_en),
        .o_rd_addr(w_rd_addr),
        // .o_busy(),
        .o_done(w_done)
    );
    
    // Delaying valid and done signals to match bram latency. 
    
    reg rd_en_d1, rd_en_d2;
    reg r_done1, r_done2;
    always @(posedge i_clk) begin
        if (!i_rst) begin
            rd_en_d1  <= 1'b0;
            rd_en_d2  <= 1'b0;
            r_done1   <= 1'b0;
            r_done2   <= 1'b0;
        end 
        else begin
            rd_en_d1  <= w_rd_en;
            rd_en_d2  <= rd_en_d1;
            r_done1   <= w_done;
            r_done2   <= r_done1;
        end
    end

    assign o_valid  = rd_en_d2;
    assign o_data   = bram_rd_data;
    assign o_done   = r_done2;

endmodule
