module delay_reg_rt #(
    parameter N_BRAM = 32)
(
    input clk,
    input rst,
    input  [N_BRAM-1:0] i_rd_en,
    output reg [N_BRAM-1:0] o_rd_en,
    input  i_valid,
    output reg o_valid
);

genvar i;
generate
    for(i=0; i<3; i=i+1) begin: delay
        reg [N_BRAM-1:0] r_rd_en;
        reg r_valid;
        if(i == 0) begin
            always @ (posedge clk) begin
                r_rd_en <= (!rst)? 0:i_rd_en;
                r_valid <= (!rst)? 0:i_valid;
            end
        end
        else if (i == 1) begin
            always @ (posedge clk) begin
                o_rd_en <= (!rst)? 0:delay[i-1].r_rd_en;
                o_valid <= (!rst)? 0:delay[i-1].r_valid;
            end
        end
        else begin
            always @ (posedge clk) begin
                r_rd_en <= (!rst)? 0:delay[i-1].r_rd_en;
                r_valid <= (!rst)? 0:delay[i-1].r_valid;
            end
        end
    end
endgenerate

endmodule