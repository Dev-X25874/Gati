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
    
reg [ROW-1:0] counter = 0;
reg [ROW-1:0] data = 0;

assign o_data = data;

always @(posedge i_clk) begin
    if(i_enable) begin
        if (counter == ROW - 1)
            counter <= 0;
        else
            counter <= counter + 1; 
        data[counter] <= 1;
        if (counter == 0)
            data[ROW - 1] <= 0;
        else
            data[counter - 1] <= 0;
    end else begin
        counter <= 0;
        data <= 0;
    end
end
    
endmodule