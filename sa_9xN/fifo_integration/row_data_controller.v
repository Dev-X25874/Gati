module row_data_controller#(
    parameter ROW = 9
)(
    input i_clk,
    input [ROW-1:0] i_fifo_empty,
    input [(9*ROW)-1:0] i_data,
    output [8:0] o_data,
    output [ROW-1:0] o_read_enable,
    output wren
);

reg [($clog2(ROW))-1:0] counter = 0;
reg [1:0] state = 0;

always @(posedge i_clk)begin
    case(state)
        0: begin
            counter <= 0;
            if(i_fifo_empty == 0) begin
                state <= 1;
            end
        end
        
        1: begin
            counter <= 0;
            state <= 2;
        end
        
        2: begin
            counter <= counter + 1;
            if(counter == ROW)
                state <= 0;
            else
                state <= 2;
        end
    endcase
end

row_fifo_data#(
    .ROW(ROW)
) row_data_demux (
    .i_clk (i_clk),
    .i_data (i_data),
    .i_sel (counter),
    .i_fifo_empty (i_fifo_empty),
    .o_data (o_data),
    .o_read_enable (o_read_enable),
    .row_fifo_wren(wren)
);

endmodule