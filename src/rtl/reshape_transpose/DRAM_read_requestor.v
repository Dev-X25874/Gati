module DRAM_read_requestor #(parameter AXI_BYTES = 32,
                             parameter BURST_LENGTH_WIDTH = 8,
                             parameter W_CITER_CNT = 10,
                             parameter IMG_HEIGHT = 16,
                             parameter N_SA = 16,
                             parameter ADDR_OUT_CHUNCK_WIDTH = 8)
(
    input clk,
    input rst_n,
    input rd_start,
    input last_data, //from Dram read fifo array controller
    input                                        empty, //from L fifos
    input      [(2*IMG_HEIGHT) - 1 : 0]          img_dimension, //from software
    input      [(AXI_BYTES - 1) : 0]             offset, // from software
    input      [(W_CITER_CNT - 1) : 0]           channel_itr_count,
    input      [(AXI_BYTES - 1) : 0]             start_addr,
    output reg [(BURST_LENGTH_WIDTH - 1) : 0]    burst_length = 0,
    output reg [(ADDR_OUT_CHUNCK_WIDTH - 1) : 0] addr_out = 0,
    output reg rw_enable = 0,
    output reg last = 0,
    output reg valid = 0,
    output reg channel_last = 0
);

reg [(AXI_BYTES - 1) : 0] nxt_addr = 0;
reg [(AXI_BYTES - 1) : 0] r_start_addr = 0;
reg [1:0]                 state = 0;
reg [7:0]                 count_addr_out = 0;
reg [15:0]                count_channel_offset = 0;
reg [15:0]                count_channel_elments = 0;

//assign r_start_addr = start_addr;

always @(posedge clk) begin
    if(!rst_n) begin
        burst_length <= 0;
        addr_out <= 0;
        rw_enable <= 0;
        last <= 0;
        valid <= 0;
        state <= 0;
        count_addr_out <= 0;
        count_channel_offset <= 0;
        count_channel_elments <= 0;
        nxt_addr <= 0;
        r_start_addr <= 0;
    end
    else begin
        case(state)
        0: begin
            if(rd_start) begin
                state <= 1;
                channel_last <= 0;
                nxt_addr <= start_addr;
            end
            else begin
                state <= 0;
            end
        end
        1: begin
            if(count_addr_out < 3) begin
                addr_out <= nxt_addr[32-(count_addr_out*8)-1 -:8];
                count_addr_out <= count_addr_out + 1;
                valid <= 1;
                state <= 1;
                burst_length <= 0;
                last <= 0;
            end
            else begin
                addr_out <= nxt_addr[32-(count_addr_out*8)-1 -:8];
                count_addr_out <= 0;
                valid <= 1;
                state <= 2;
                burst_length <= 0;
                last <= 1;
            end
        end
        2: begin
            last <= 0;
            valid <= 0;
            if(count_channel_offset < (channel_itr_count - 1)) begin //channel_itr_count = 7
                if(last_data) begin
                    nxt_addr <= (nxt_addr + (offset<<$clog2(AXI_BYTES)));
                    count_channel_offset <= count_channel_offset + 1;
                    state <= 1;
                    channel_last <= 0;
                end
                else begin
                    state <= 2;
                    count_channel_offset <= count_channel_offset;
                    nxt_addr <= nxt_addr;
                    channel_last <= 0;
                end
            end
            else begin
                nxt_addr <= nxt_addr;
                count_channel_offset <= 0;
                count_channel_elments <= count_channel_elments + AXI_BYTES/N_SA;
                state <= 3;
                channel_last <= 1;
            end
        end
        3: begin
            channel_last <= 0;
            if(empty) begin
                if(count_channel_elments < img_dimension) begin //img_dimension = 19x19/2 ~ 181
                    nxt_addr <= (start_addr+((count_channel_elments/(AXI_BYTES/N_SA))<<$clog2(AXI_BYTES)));
                    state <= 1;
                end 
                else begin
                    count_channel_elments <= 0;
                    state <= 0;
                end
            end
        end
        endcase
    end
end
endmodule