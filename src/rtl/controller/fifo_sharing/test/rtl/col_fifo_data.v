//Controller to read partial sums from array of fifo and writes it into single fifo(one byte at a time) 
module col_fifo_data#(
    parameter COL = 3,
    parameter W_PSUM = 8
)(
    input i_clk,
    input i_rst,
    input [((W_PSUM + 1) * COL) -1:0] i_data,
    input [COL-1:0] i_fifo_empty,
    output [W_PSUM: 0] o_data,
    output reg wr_en_final_fifo = 0,
    output [COL-1:0] o_read_enable
);

reg [W_PSUM : 0] data = 0;
reg [1:0] state = 0;
reg [COL-1:0] rden = 0;
reg [($clog2(COL)): 0] cnt = 0;

assign o_data = data;
assign o_read_enable = rden;

always @(posedge i_clk)begin
    if(i_rst)begin
        data <= 0;
        rden <= 0;
        state <= 0;
        cnt <= 0;
    end else begin
        case(state)
            0: begin
                if(i_fifo_empty == 0)begin
                    state <= 1;
                    rden <= {COL{1'b1}};
                end
                    cnt <= 0;
                    wr_en_final_fifo <= 0;
            end

            1: begin
                rden <= 0;
                state <= 2; 
            end

            2: begin
                if(cnt == COL)begin
                    state <= 0;
                    wr_en_final_fifo <= 0;
                    cnt <= 0;
                    data <= 0;
                end else begin
                    data <= i_data[(((COL - cnt) * (W_PSUM + 1))-1) -: (W_PSUM + 1)];
                    wr_en_final_fifo <= 1;
                    cnt <= cnt + 1;
                end
            end
        endcase
    end
end

endmodule