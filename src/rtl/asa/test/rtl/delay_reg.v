/*
    Partial sums in the PE grid have a one clock cycle delay as they go downward in each ROW. 
    Therefore, a delay register is provided to inherit the delay of the image when 
    sending it to the PE block in order to match the inherent delay of partial sums. 
*/
module delay_reg #(
    parameter ROW = 9,
    parameter W_DATA = 8
)(  input in_clk,
    input i_rst,
    input [(ROW * (W_DATA + 1)) - 1 : 0] in_west,
    output [(ROW * (W_DATA + 1)) - 1 : 0] pe_grid_image
);

reg [(ROW * (W_DATA + 1)) - 1 : 0] r_pe_grid_image = 0;

//No delay is provided to the image going into first row of SA
assign pe_grid_image [((W_DATA+1) * ROW)-1 :((W_DATA+1) * (ROW-1))] = in_west[((W_DATA+1) * ROW)-1 : ((W_DATA+1) * (ROW-1))];

//Image from 2nd to the last ROW of SA is passed through registers before broadcasting it into PE blocks
assign pe_grid_image [(((W_DATA + 1) * ROW) - ROW - 1) : 0] = r_pe_grid_image[(((W_DATA + 1) * ROW) - ROW - 1) : 0];

genvar i , j;
    generate
    for (i = 1; i < ROW; i = i + 1) begin: FOR_ROW
        for (j = 0; j < i; j = j + 1) begin: FC_IN
            wire [W_DATA:0] data_out_reg;
            if (j == 0 && j == i - 1) begin

                always @(posedge clk) r_pe_grid_image[(ROW - i) * (W_DATA + 1) - 1 -: (W_DATA + 1)]
                        <= i_rst ? 0 : in_west[(ROW - i) * (W_DATA + 1) - 1 -: (W_DATA + 1)];
            
            end else if (j == 0) begin
            
                always @(posedge clk) data_out_reg <= i_rst ? 0
                        : in_west[(ROW - i) * (W_DATA + 1) - 1 -: (W_DATA + 1)];
            
            end else if (j == i - 1) begin
            
                always @(posedge clk) r_pe_grid_image[(ROW - i) * (W_DATA + 1) - 1 -: (W_DATA + 1)]
                        <= i_rst ? 0 : FOR_ROW[i].FC_IN[j-1].data_out_reg;
            
            end else begin
            
                always @(posedge clk) data_out_reg <= i_rst ? 0 : FOR_ROW[i].FC_IN[j-1].data_out_reg;
            
            end
        end
    end
endgenerate
endmodule    
