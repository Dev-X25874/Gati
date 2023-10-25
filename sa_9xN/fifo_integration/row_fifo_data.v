module row_fifo_data#(
    parameter ROW = 3
)(
    input i_clk,
    input [(9 * ROW) -1:0] i_data,
    input [($clog2(ROW))-1:0] i_sel,
    input [ROW-1:0] i_fifo_empty,
    output [8:0] o_data,
    output [ROW-1:0] o_read_enable,
    output reg row_fifo_wren = 0
);

reg [8:0] data = 0;
reg [1:0] state = 0;
reg [ROW-1:0] rden = 0;

assign o_data = data;
assign o_read_enable = rden;

always @(posedge i_clk)begin
    case(state)
        0: begin
            data <= data;
            if(i_fifo_empty == 0)begin
                state <= 1;
                rden <= ~rden;
            end
        end
        
        1: begin
            rden <= 0;
            state <= 2;
        end
        
        2: begin
            if(i_sel == ROW)begin
                state <= 0;
                row_fifo_wren <= 1'b0;
            end else begin
                data <= i_data[(((ROW - i_sel) * 9)-1) -: 9];
                state <= 2;
                row_fifo_wren <= 1'b1;
            end
        end
    endcase
end

endmodule