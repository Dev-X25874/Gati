module col_data_controller#(
    parameter COL = 3
)(
    input i_clk,
    input [COL-1:0] i_fifo_empty,
    input [(9*COL)-1:0] i_data,
    output [8:0] o_data,
    output [COL-1:0] o_read_enable,
    output wren
);

reg [($clog2(COL))-1:0] counter = 0;
reg [1:0] state = 0;


always @(posedge i_clk)begin
    case(state)
        0: begin
            counter <= 0;
            if(i_fifo_empty[COL -1] == 0) begin
                state <= 1;
            end
        end
        
        1: begin
            counter <= 0;
            state <= 2;
        end
        
        2: begin
            counter <= counter + 1;
            if(counter == COL)
                state <= 0;
            else
                state <= 2;
        end
    endcase
end

col_fifo_data#(
    .COL(COL)
) col_data_demux (
    .i_clk (i_clk),
    .i_data (i_data),
    .i_sel (counter),
    .i_fifo_empty (i_fifo_empty),
    .o_data (o_data),
    .o_read_enable (o_read_enable),
    .wr_en_final_fifo(wren)
);

endmodule