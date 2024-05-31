module counters#(
    parameter W_BLEN = 8
)(
    input i_clk,
    input i_rstn,
    input i_last,
    input [W_BLEN-1 : 0] i_burst_len, //comes from wr_req_ctl
    output o_select,
    output [W_BLEN-1 : 0] o_burst_length,
    output o_w_ready
);

reg [8:0] wait_counter = 0; //provide delay of few clock cycles to send select, write ready signals to dram_wr_ctrl
reg [W_BLEN-1 : 0] ack_counter = 0; //request will be assertes till i_burst_len number of cycles
reg wready = 0;
reg sel = 0;
reg [1:0] state = 0;
reg [W_BLEN-1 : 0] blen = 0;

assign o_burst_length = blen;
assign o_select = sel;
assign o_w_ready = wready;

always @(posedge i_clk) begin
    if(~i_rstn)begin
        wait_counter <= 0;
    end else begin
        case (state)
            0:begin
                if(i_last)begin
                    state <= 1;
                end
            end
            1: begin
                if(wait_counter == 30)begin
                    if(ack_counter < (i_burst_len+1))begin
                        ack_counter <= ack_counter + 1;
                        sel <= 1'b1;
                        wready <= 1'b1;
                        blen <= i_burst_len;
                    end else begin
                        sel <= 1'b0;
                        wready <= 1'b0;
                        blen <= 0;
                        ack_counter <= 0;
                        state <= 0;
                    end
                end else begin
                    wait_counter <= wait_counter + 1;
                end 
            end
            default: state <= 0;
        endcase
    end
end
    
endmodule
