/*
    Handles write enable signal of all the fifo in an array(north_fifo_array)
    that loads weights simultaneously into all the columns of systolic array.
*/
module internal_north_wren#(
    parameter COL = 3,
    parameter N_SA = 2
)(
    input i_clk,
    input i_rst,
    input i_enable,
    output [COL-1:0] o_data 
);
    
reg [COL-1:0] counter = 0;
reg [COL-1:0] data = 0;

assign o_data = data;

always @(posedge i_clk) begin
    if(i_rst)begin
        counter <= 0;
        data <= 0;
    end else begin
        if(i_enable) begin
            if (counter == COL - 1)
                counter <= 0;
            else
                counter <= counter + 1;
                
            data[counter] <= 1;
            
            if(COL > 1) begin
                if (counter == 0)
                    data[COL - 1] <= 0;
                else
                    data[counter - 1] <= 0;
            end
        end else begin
            counter <= 0;
            data <= 0;
        end
    end
end
    
endmodule