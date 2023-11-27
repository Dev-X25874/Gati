module col_fifo_data#(
    parameter COL = 3
)(
    input i_clk,
    input [(9 * COL) -1:0] i_data,
    input [($clog2(COL))-1:0] i_sel,
    input [COL-1:0] i_fifo_empty,
    output [8:0] o_data,
    output reg wr_en_final_fifo = 0,
     output [COL-1:0] o_read_enable
);

reg [8:0] data = 0;
reg [1:0] state = 0;
reg [COL-1:0] rden = 0;
reg [$clog2(COL) - 1 : 0] cnt = 0;

assign o_data = data;
assign o_read_enable = rden;

always @(posedge i_clk)begin
    case(state)
        0: begin
            if(i_fifo_empty == 0)begin
                state <= 1;
                rden <= ~rden;
            end
            cnt <= 0;
            wr_en_final_fifo <= 0;
        end
        
        1: begin
            rden <= 0;
            state <= 2; 
        end
        
        2: begin
        if(cnt == COL - 1)begin
            state <= 0;
            cnt <= 0;
        end
        data <= i_data[(((COL - cnt) * 9)-1) -: 9];
        wr_en_final_fifo <= 1;
        cnt <= cnt + 1;
        end
    endcase
end

endmodule