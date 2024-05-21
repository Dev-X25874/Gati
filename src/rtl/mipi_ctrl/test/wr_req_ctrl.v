/*
    Send request to DDR controller
*/
module wr_req_ctrl#(
    parameter W_DATA = 32,
    parameter W_BURST_LEN = 8,
    parameter BURST_LEN = 15,
    parameter W_ADDR = 8,
    parameter AXI_BYTES = 32,
    parameter N_FIFO = 8
)(
    input i_clk,
    input i_rstn,
    input i_data_last,   //burst last, comes from DDR write controller
    input i_data_valid,
    input [((W_ADDR + 1) * N_FIFO)-1 : 0] i_fifo_occupants, //comes from fifo array
    input [W_DATA-1 : 0] i_start_address,   //comes from fifo_wr_ctrl
    input [W_DATA-1 : 0] i_data_size,   //comes from fifo_wr_ctrl
    output o_request,   //request goes to DDR ctrl
    output [7:0]o_address, //requested address, goes to DDR ctrl
    output [W_BURST_LEN-1 : 0]o_burst_len,  //requested burst length, goes to DDR ctrl
    output o_last,
    output o_valid
);

reg req = 0;
reg last = 0;
reg valid = 0;
reg [2:0] state = 0;
reg [W_BURST_LEN-1 : 0] burst_len = BURST_LEN + 1; 
reg [7:0] addr = 0;
reg [W_DATA-1 : 0] r_addr = 0;  //reg to hold updated address
reg [W_BURST_LEN-1 : 0] r_burst_len = 0;   //reg to hold updated burst length before sending it
reg [W_DATA-1 : 0] data_size = 0;
reg [W_DATA-1 : 0] offset = 0;
reg [2:0] addr_counter = 0;
assign o_address = addr;
assign o_request = req;
assign o_burst_len = burst_len;
assign o_last = last;
assign o_valid = valid;

always @(posedge i_clk)begin
    if(~i_rstn)begin
        req <= 0;
        state <= 0;
        burst_len <= 0;
        addr <= 0;
        r_addr <= 0;
        data_size <= 0;
        valid <= 0;
    end else begin
        case (state)
            0:begin
                if(i_data_valid)begin
                    r_addr <= i_start_address;
                    state <= 1;
                end
            end

            1: begin
                if(i_fifo_occupants == {N_FIFO{burst_len}})begin
                    state <= 2;
                end
            end
            2: begin
                //send req to DDR
                req <= 1'b1;
                //Add addr_valid in address counter
                addr <= r_addr;//Add counter 1-4
                if(addr_counter < 3)begin
                    addr_counter <= addr_counter + 1;
                    addr <= r_addr[(W_DATA - (addr_counter * 8))-1 -: 8];
                    valid <= 1'b1;
                end 
                else if(addr_counter == 3)begin
                    addr_counter <= addr_counter + 1;
                    addr <= r_addr[(W_DATA - (addr_counter * 8))-1 -: 8];
                    last <= 1'b1;
                    valid <= 1'b1;
                    //reduce data size
                    data_size <= (i_data_size - (((W_DATA >> $clog2(8)) * N_FIFO)*(r_burst_len + 1)));  //For eg, 98x4 - 256/8
                end else begin
                    addr_counter <= 0;
                    last <= 1'b0;
                    valid <= 1'b0;
                    state <= 3;
                end
                burst_len <= r_burst_len;
                offset <=((burst_len)<<$clog2(W_DATA));
            end
            3: begin
                r_addr <= r_addr + offset;
                if(data_size != 0)begin
                    if(data_size >= (((W_DATA >> $clog2(8)) * N_FIFO)*(r_burst_len + 1))) begin  //if data size = 32 * (blen+1)
                        r_burst_len <= BURST_LEN + 1;
                        if(i_data_last)
                            state <= 0;
                    end else begin
                        r_burst_len <= (data_size >> $clog2(AXI_BYTES))-1;
                        if(i_data_last)
                            state <= 0;
                    end
                end else begin
                    state <= 0;
                end
            end

            default: state <= 0; 
        endcase
    end
end

    
endmodule