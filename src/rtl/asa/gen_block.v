/*module gen_block(
    input clk,
    input sel1,
    input sel2,
    input trigger1,
    input trigger2,
    input [(N * W_DATA)-1 : 0] in_data,
    input rx_data_valid
    
); 

genvar i;
generate
    for(i = 0; i < N; i = i + 1)begin
        block#(
    .ROW(ROWS),
    .COL(COLS),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(RAM_DEPTH),
    .TOTAL_BYTES(TOTAL_BYTES)
) computational_block (
    .in_clk(i_clk),
    .in_sel1(select1),
    .in_sel2(select2),
    .in_trigger1(i_trigger_1),
    .in_trigger2(i_trigger_2),
    .in_rx_dv(rx_dv),
    .in_data(rx_byte),
    .out_column_data(tx_col_byte),
    .out_row_data(tx_row_byte),
    .out_column_dv(tx_col_dv),
    .out_row_dv(tx_row_dv),
    .o_row_trigger_counter(row_trigger)
);
    end
endgenerate

endmodule*/