module controller_col#(
    parameter COL = 16,
    parameter ROW = 9,
    parameter W_ADDR = 8
)(
    input i_clk,
    input i_trigger,
    input [(COL * 32)-1 : 0] i_data,
    input [COL-1 : 0] i_fifo_empty,
    input [((W_ADDR + 1) * COL) -1 : 0] i_fifo_occupants,
    output o_select,
    output [COL - 1 : 0] o_fifo_read_enable,
    output [(COL * 32) -1 : 0] o_data
);

reg sel = 0;
reg [1:0] state = 0;
reg [COL-1 : 0] rden = 0;
reg [((W_ADDR + 1) * COL)-1 : 0] replicated_value = 0;

reg [($clog2(COL * 32)) : 0] counter = 0;

assign o_fifo_read_enable = rden;
assign o_select = sel;

always @(*)begin
    replicated_value <= {COL{9'b000001001}};
end

assign o_data = (~counter[0]) ? 0 : i_data;

always @(posedge i_clk) begin
    case(state)
        0: begin
            sel <= 0;
            counter <= 0;
            rden <= 0;
            if((i_fifo_empty == 0) && (i_fifo_occupants == replicated_value)) begin
                state <= 1;
            end
        end

        1: begin
            if(counter == (2 * ROW) + 1)begin
                state <= 0;
            end else begin
                counter <= counter + 1;
                sel <= 1'b1;
                //if(rden_counter[0] == 1)begin
                if(counter[0] == 1) begin
                    rden <= 0;
                end else begin
                    rden <= ~rden;
                end
            end

        end
    endcase
end

endmodule