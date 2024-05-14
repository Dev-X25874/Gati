module mux_final_pool(
    input clk,
    input [7:0] din_final_pool,
    input [7:0] din_demux_for_fifo1,
    input datavalid_final_pool,
    input datavalid_demux_for_fifo1,
    output reg dv = 0,
    output reg [7:0] dout_fifo1 = 0
);

always @(posedge clk) begin
    case(state)
    0: begin
        dout_fifo1 <= 0;
        state <= 1;
        sel <= 0;
    end
    1: begin
        if(datavalid_final_pool) begin
            sel <= 1;
            state <= 2;
        end 
        else begin
            sel <= 0;
            state <= 2;
        end
    end
    2: begin
        if(sel) begin
            dout_fifo1 <= din_final_pool;
            dv <= 1;
            state <= 0;
        end
        else begin
            dout_fifo1 <= din_demux_for_fifo1;
            state <= 0;
            dv <= 1;
        end
    end
    endcase
end

endmodule