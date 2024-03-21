module internal_west_wren_gen#(
    parameter ROW = 9,
    parameter N_SA = 1
)(
    input i_clk,
    input i_rst,
    input [N_SA-1 : 0] i_enb,
    output [(N_SA * ROW)-1 : 0] o_wren
);

genvar i;
generate
    for(i = 0; i < N_SA; i = i +1)begin
        internal_west_wren#(
            .ROW(ROW)
        )int_west_wren_ctrl(
            .i_clk(i_clk),
            .i_enable(i_enb[i]),
            .i_rst(i_rst),
            .o_data(o_wren[(ROW * (N_SA - i))-1 -: ROW]) 
        );
    end
endgenerate
    
endmodule

/*
    Handles write enable signal of internal west fifo array that loads
    image simultaneously into all rows of systolic array.
*/
module internal_west_wren#(
    parameter ROW = 9
)(
    input i_clk,
    input i_enable,
    input i_rst,
    output [ROW-1:0] o_data 
);
    
reg [ROW-1:0] counter = 0;
reg [ROW-1:0] data = 0;

assign o_data = data;

always @(posedge i_clk) begin
    if(i_rst)begin
        counter <= 0;
        data <= 0;
    end else begin
    if(i_enable) begin
        if (counter == ROW - 1) begin
            counter <= 0;
        end else
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
end
    
endmodule