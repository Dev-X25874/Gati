module controller_after_main_design_gen #(parameter DESIGN_NO = 8) (
    input clk,
    input rst, 
    input [DESIGN_NO-1:0] empty,
    output[DESIGN_NO-1:0] re_en,
    output wr_en
);

always @(posedge clk ) begin
    if(empty == 0) begin
        re_en <= {DESIGN_NO{1'b1}};
        wr_en <= 1'b1;
    end  
    else begin
        re_en <= {DESIGN_NO{1'b1}};
        wr_en <= 1'b1;
    end
end

endmodule