module rden_delay_reg #(
    parameter ROW = 9
)(
    input i_clk,
    input i_rden,
    output [ROW-1 : 0] o_rden_img_fifo
);
    
    reg [ROW-2 : 0] delay_reg;
    genvar i;
    generate
        if(ROW > 1) begin
            for(i=0; i<ROW-1; i=i+1) begin
                if(i==0) always@(posedge i_clk) delay_reg[0] <= i_rden;
                else     always@(posedge i_clk) delay_reg[i] <= delay_reg[i-1];
            end
        end
    endgenerate
    
    generate
        if(ROW==1) begin 
            assign o_rden_img_fifo = i_rden;
        end
        else begin
            assign o_rden_img_fifo[0] = i_rden;
            assign o_rden_img_fifo[ROW-1 : 1] = delay_reg;
        end
    endgenerate

endmodule