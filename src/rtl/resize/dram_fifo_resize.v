module dram_fifo_resize #(
    parameter AXI_DATA_BYTES = 32,
    parameter W_ADDR = 6,
    parameter N_SA = 4,
    parameter MOD2 = 8,
    parameter RESIZE_IW_WIDTH = 10
)(
    input                             clk,
    input                             rst,
    input  [W_ADDR:0]                 i_fifo_occupants,
    input  [AXI_DATA_BYTES-1:0]       i_fifo_empty,
    input  [RESIZE_IW_WIDTH-1:0]      i_resize_IW,
    input  [N_SA-1:0]                 i_busy,
    input                             i_resize_start,
    input                             i_resize_done,
    output reg [AXI_DATA_BYTES-1:0]   o_fifo_rden,
    output reg                        o_fire,
    input                             i_send_read
);
    /*  This module handles the read enable signals sent to the dram_fifos.
        For the initial start_RESIZE pulse (from start_block), the
        controller checks for rd_threshold number of occupants, i.e, 
        (input_width * AXI_DATA_BYTES)/ N_SA. For next iterations, it simply
        checks if the bram_wr_ctrl_resize module is busy. 
    */ 

    wire w_ready = &(~i_busy);
    wire [W_ADDR:0] rd_threshold;

    assign rd_threshold = (i_resize_IW / MOD2) + 1;

    localparam IDLE = 2'd0;
    localparam START = 2'd1;
    localparam READ = 2'd2;
    localparam SEND_READ = 2'd3;
    reg [1:0] state = 0;

    always @(posedge clk) begin
        if(!rst) begin
            state      <= IDLE;
            o_fire     <= 1'b0;
            o_fifo_rden <= {AXI_DATA_BYTES{1'b0}};
        end
        else begin
            case(state)
            IDLE: begin
                if (i_resize_start) state <= START;
            end
            START: begin
                if (w_ready && (i_fifo_occupants >= rd_threshold)) begin
                    o_fire      <= 1'b1;
                    o_fifo_rden <= {AXI_DATA_BYTES{1'b1}};
                    state <= READ;
                end
                else begin
                    o_fifo_rden <= {AXI_DATA_BYTES{1'b0}};
                    o_fire      <= 1'b0;
                    state <= START;
                end
            end
            READ: begin
                o_fifo_rden <= 0;
                if (i_resize_done) begin
                    state <= IDLE;
                end
                else if (w_ready && ~(|i_fifo_empty) && i_send_read) begin
                    o_fire      <= 1'b1;
                    o_fifo_rden <= {AXI_DATA_BYTES{1'b1}};
                end
            end
            endcase
        end 
    end

endmodule
