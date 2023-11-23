/*
    Handles write enable signal of all the fifo in an array that loads
    weights simultaneously into a6ll the columns of systolic array.
*/
module shift_reg_col #(
    parameter COL = 3
)(
    input i_clk,
    input i_enable,
    output [COL-1:0] o_data
);
reg [COL-1:0] we = 0;
assign o_data = we;

reg [1:0]cnt = 0;     
wire [COL-1:0] mux_out;

/*
    Selects fifo from an array to load weight into it
*/
mux_col 
col_sr_mux(
    .i_data1(3'b000),
    .i_data2(3'b001),
    .i_data3(3'b010),
    .i_data4(3'b100),
    .i_sel (cnt),
    .o_data (mux_out)
);

always @(posedge i_clk)begin
    if(i_enable) begin
        if(cnt == 2'd3)begin
            cnt <= 2'b1;
        end else begin
            cnt <= cnt + 1;
        end
        we <= mux_out;
    end else begin
        we <= 0;
    end 
end
endmodule