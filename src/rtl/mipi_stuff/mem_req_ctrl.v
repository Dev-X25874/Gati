module mem_req_ctrl #(
    parameter ADDR_W = 32,
    parameter DATA_SIZE = 20,
    parameter BURST_LEN = 16)
(
    input  clk,
    input  rst,
    input  [ADDR_W-1:0] i_addr,
    input  [DATA_SIZE-1:0] i_data_size,
    input  i_data_last, //comes from data read controller
    input  i_valid_req, //comes from request generator
    input  fifo_status, //comes from mipi fifo
    output reg o_ready, //gives ready to generate next request
    output reg read_write,
    output reg valid,
    output reg last,
    output [7:0] o_addr,
    output [$clog2(BURST_LEN)-1:0] o_blen
);

reg [ADDR_W-1:0] r_addr = 0; //reg for updating the addr
reg [7:0] addr = 0; //reg for holding the updated addr before sending it to DDR
reg [DATA_SIZE-1:0] r_data_size = 0;
reg [$clog2(BURST_LEN)-1:0] r_blen = 0, blen = 0; //one reg for updating burst length and one for storing the updated one before sending to DDR
reg [3:0] state = 0;
reg [ADDR_W-1:0] offset = 0; //reg for holding the offset value to update addr
reg [2:0] addr_counter = 0;

assign o_addr = addr;
assign o_blen = blen;

always @ (posedge clk) begin
    if(!rst) begin
        state <= 0;
        r_blen <= 0;
        r_addr <= 0;
        offset <= 0;
        addr_counter <= 0;
        addr <= 0;
        blen <= 0;
        r_data_size <= 0;
        last <= 0;
        valid <= 0;
        read_write <= 0;
        o_ready <= 0;
    end

    else begin
        case(state)
        0:begin
            if(i_valid_req) begin
                o_ready <= 0;
                if(!fifo_status) begin
                    r_data_size <= i_data_size;
                    r_addr <= i_addr;
                    state <= 1;
                end
                else begin
                    r_data_size <= r_data_size;
                    r_addr <= r_addr;
                    state <= 0;
                end
            end
            else begin
                o_ready <= 1;
                state <= 0;
            end
        end

        1:begin //checking for data size to calculate burst length
            if(r_data_size < 512) begin 
                r_blen <= (r_data_size >> $clog2(ADDR_W)) - 1;
                state <= 2;
            end
            else begin
                r_blen <= BURST_LEN-1;
                state <= 2;
            end
        end
        2:begin
            blen <= r_blen;
            offset <= (r_blen + 1) << $clog2(ADDR_W);
            if(addr_counter < 3) begin
                addr_counter <= addr_counter + 1;
                addr <= r_addr[(ADDR_W - (addr_counter*8)) - 1 -:8];
                valid <= 1;
                state <= 2;
            end
            else if (addr_counter == 3) begin
                addr_counter <= addr_counter + 1;
                addr <= r_addr[(ADDR_W - (addr_counter*8)) - 1 -:8];
                last <= 1;
                valid <= 1;
                r_data_size <= r_data_size - (ADDR_W * (r_blen + 1)); //updating data size according to burst length
                state <= 2;
            end
            else begin
                addr_counter <= 0;
                last <= 0;
                valid <= 0;
                state <= 3;
            end
        end

        3:begin
            if(i_data_last) begin
                if((r_data_size > 32) && (r_data_size[DATA_SIZE-1] != 1)) begin //checking data size before proceeding ahead
                    r_addr <= r_addr + offset;
                    state <= 1;
                end
                else if (r_data_size[DATA_SIZE-1] == 1) begin
                    state <= 0;
                    o_ready <= 1;
                end
                else if (r_data_size == 0) begin
                    state <= 0;
                    o_ready <= 1;
                end 
                else begin
                    r_addr <= r_addr + offset;
                    r_blen <= 0;
                    state <= 2;
                end
            end
            else begin
                r_addr <= r_addr;
                state <= 3;
            end
        end
        endcase
    end
end
endmodule









            
    
