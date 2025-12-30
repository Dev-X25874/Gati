
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

    wire w_ready = &(~i_busy);
    wire [W_ADDR:0] rd_threshold;

    assign rd_threshold = (i_resize_IW / MOD2) + 1;

    localparam IDLE = 2'd0;
    localparam START = 2'd1;
    localparam READ = 2'd2;
    localparam SEND_READ = 2'd3;
    reg [1:0] state, state_n;

    always @(posedge clk) begin
        if (!rst) state <= IDLE;
        else state <= state_n;
    end

    always @(*) begin
        state_n = state;
        o_fire = 1'b0;
        o_fifo_rden = {AXI_DATA_BYTES{1'b0}};

        case(state)

        IDLE: begin
            if (i_resize_start) state_n = START;
        end

        START: begin
            if (w_ready && (i_fifo_occupants >= rd_threshold)) begin
                o_fire      = 1'b1;
                o_fifo_rden = {AXI_DATA_BYTES{1'b1}};
                state_n     = READ;
            end
        end
        READ: begin
            o_fifo_rden = 0;
            if (i_resize_done) begin
                state_n = IDLE;
            end
            else if (w_ready && ~(|i_fifo_empty) && i_send_read) begin
                o_fire      = 1'b1;
                o_fifo_rden = {AXI_DATA_BYTES{1'b1}};
            end
        end

        endcase
    end

endmodule
