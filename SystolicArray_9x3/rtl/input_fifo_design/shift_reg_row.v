/*
    Handles write enable signal of all the fifo in an array that loads
    data simultaneously into all rows of systolic array.
*/
module shift_reg_row #(
    parameter ROW = 9
)(
    input i_clk,
    input i_enable,
    output [ROW-1:0] o_data
);
reg [ROW-1:0] we = 0;
reg [3:0] cnt = 0;
assign o_data = we;

/*
    Selects fifo from array to store data into it.
*/
mux_row #(.ROW (9)) 
row_sr_mux(
    .i_data1 (9'b000_000_000),
    .i_data2 (9'b000_000_001),
    .i_data3 (9'b000_000_010),
    .i_data4 (9'b000_000_100),
    .i_data5 (9'b000_001_000),
    .i_data6 (9'b000_010_000),
    .i_data7 (9'b000_100_000),
    .i_data8 (9'b001_000_000),
    .i_data9 (9'b010_000_000),
    .i_data10(9'b100_000_000),  
    .i_sel (cnt),
    .o_data (mux_out)
);

wire [ROW-1:0] mux_out;

always @(posedge i_clk)begin
    if(i_enable)begin
        we <= mux_out;
        if(cnt == 4'd9)begin
            cnt <= 4'd1;
        end else begin
            cnt <= cnt + 1;
        end
    end else begin
        we <= 0;
    end
end

endmodule