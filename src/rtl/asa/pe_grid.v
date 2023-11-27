//Array of PE blocks
module pe_grid#(
    parameter COL = 4,
    parameter ROW = 9,
    parameter W_DATA = 8
)(
    input i_clk,
    input i_sel,
    input [(COL * W_DATA) -1 : 0] i_weight,
    input [(ROW * (W_DATA + 1)) -1 : 0] in_data,
    output [(COL * 32)-1 : 0] o_partial_sum,
    output [COL-1: 0] o_select,
    output [(ROW * (W_DATA + 1))-1 : 0] o_data 
);

genvar i, j;
generate

    
    for(i = 0; i < ROW; i = i + 1)begin : FOR_ROW
        for(j = 0; j < COL; j = j + 1)begin : FOR_COL
            wire [31:0] w_psum;
            wire [W_DATA-1 : 0] w_weight;
            wire w_select;
            wire [W_DATA:0] w_data;
            
            if(COL > 2)begin
                if (i == 0 && j == 0) begin//1 
                top_pe_block pe(
                    .i_clk(i_clk),
                    .i_sel(i_sel),
                    .i_weight(i_weight[((COL - j)* W_DATA)-1 -: W_DATA]),
                    .i_data(in_data[((ROW - i)* (W_DATA + 1))-1 -: (W_DATA + 1)]),
                    .o_sel(w_select),
                    .o_weight(w_weight),
                    .o_p_sum(w_psum),
                    .o_data(w_data)
                );
                    
                end else if(i == ROW - 1 && j == 0) begin//2
                    bottom_pe_block pe(
                        .i_clk(i_clk),
                        .i_sel(FOR_ROW[i-1].FOR_COL[j].w_select),
                        .i_weight(FOR_ROW[i-1].FOR_COL[j].w_weight),
                        .i_p_sum(FOR_ROW[i-1].FOR_COL[j].w_psum),
                        .i_data(in_data[((ROW - i)* (W_DATA + 1))-1 -: (W_DATA + 1)]),
                        .o_p_sum(o_partial_sum[((COL - j) * 32)-1 -: 32]),
                        .o_sel(o_select[(COL- j)-1 : 0]),
                        .o_data(w_data)
                    );
                    
                    
                    
                end else if (j == 0) begin//3
                    pe_block pe(
                        .i_clk(i_clk),
                        .i_sel(FOR_ROW[i-1].FOR_COL[j].w_select),
                        .i_weight(FOR_ROW[i-1].FOR_COL[j].w_weight),
                        .i_p_sum(FOR_ROW[i-1].FOR_COL[j].w_psum),
                        .i_data(in_data[((ROW - i)* (W_DATA + 1))-1 -: (W_DATA + 1)]),
                        .o_weight(w_weight),
                        .o_p_sum(w_psum),
                        .o_sel(w_select),
                        .o_data(w_data)
                    );
                end

                else if (i == 0 && j == COL - 1) begin//4
                top_pe_block pe(
                    .i_clk(i_clk),
                    .i_sel(i_sel),
                    .i_weight(i_weight[((COL - j)* W_DATA)-1 -: W_DATA]),
                    .i_data(FOR_ROW[i].FOR_COL[j-1].w_data),
                    .o_sel(w_select),
                    .o_weight(w_weight),
                    .o_p_sum(w_psum),
                    .o_data(o_data[((ROW - i)*  (W_DATA + 1))-1 -: (W_DATA + 1)])
                );
                
                end else if (i == 0) begin//5
                top_pe_block pe(
                    .i_clk(i_clk),
                    .i_sel(i_sel),
                    .i_weight(i_weight[((COL - j)* W_DATA)-1 -: W_DATA]),
                    .i_data(FOR_ROW[i].FOR_COL[j-1].w_data),
                    .o_sel(w_select),
                    .o_weight(w_weight),
                    .o_p_sum(w_psum),
                    .o_data(w_data)
                );
                    
                end else if ((i == ROW - 1) && (j == COL - 1)) begin//6
                    bottom_pe_block pe(
                        .i_clk(i_clk),
                        .i_sel(FOR_ROW[i-1].FOR_COL[j].w_select),
                        .i_weight(FOR_ROW[i-1].FOR_COL[j].w_weight),
                        .i_p_sum(FOR_ROW[i-1].FOR_COL[j].w_psum),
                        .i_data(FOR_ROW[i].FOR_COL[j-1].w_data),
                        .o_p_sum(o_partial_sum[((COL - j) * 32)-1 -: 32]),
                        .o_sel(o_select[(COL- j)-1 : 0]),
                        .o_data(o_data[((ROW - i) * (W_DATA + 1))-1 -: (W_DATA + 1)])
                    );
                    
                end else if (j == COL - 1) begin //7
                    pe_block pe(
                        .i_clk(i_clk),
                        .i_sel(FOR_ROW[i-1].FOR_COL[j].w_select),
                        .i_weight(FOR_ROW[i-1].FOR_COL[j].w_weight),
                        .i_p_sum(FOR_ROW[i-1].FOR_COL[j].w_psum),
                        .i_data(FOR_ROW[i].FOR_COL[j-1].w_data),
                        .o_weight(w_weight),
                        .o_p_sum(w_psum),
                        .o_sel(w_select),
                        .o_data(o_data[((ROW - i)* (W_DATA + 1))-1 -: (W_DATA + 1)])
                    );
                    
                end else if (i == ROW - 1) begin//8
                    bottom_pe_block pe(
                        .i_clk(i_clk),
                        .i_sel(FOR_ROW[i-1].FOR_COL[j].w_select),
                        .i_weight(FOR_ROW[i-1].FOR_COL[j].w_weight),
                        .i_p_sum(FOR_ROW[i-1].FOR_COL[j].w_psum),
                        .i_data(FOR_ROW[i].FOR_COL[j-1].w_data),
                        .o_p_sum(o_partial_sum[((COL - j) * 32)-1 -: 32]),
                        .o_sel(o_select[(COL- j)-1 : 0]),
                        .o_data(w_data)
                    );
                    
                end else begin//9
                    pe_block pe(
                        .i_clk(i_clk),
                        .i_sel(FOR_ROW[i-1].FOR_COL[j].w_select),
                        .i_weight(FOR_ROW[i-1].FOR_COL[j].w_weight),
                        .i_p_sum(FOR_ROW[i-1].FOR_COL[j].w_psum),
                        .i_data(FOR_ROW[i].FOR_COL[j-1].w_data),
                        .o_weight(w_weight),
                        .o_p_sum(w_psum),
                        .o_sel(w_select),
                        .o_data(w_data)
                    );
                    
                end
            end else if(COL == 1)begin
                if (i == 0 && j == 0) begin//1 
                    top_pe_block pe(
                        .i_clk(i_clk),
                        .i_sel(i_sel),
                        .i_weight(i_weight[((COL - j)* W_DATA)-1 -: W_DATA]),
                        .i_data(in_data[((ROW - i)* (W_DATA + 1))-1 -: (W_DATA + 1)]),
                        .o_sel(w_select),
                        .o_weight(w_weight),
                        .o_p_sum(w_psum),
                        .o_data(o_data[((ROW - i) * (W_DATA + 1))-1 -: (W_DATA + 1)])
                    );
                    
                end else if(i == ROW - 1 && j == 0) begin//2
                    bottom_pe_block pe(
                        .i_clk(i_clk),
                        .i_sel(FOR_ROW[i-1].FOR_COL[j].w_select),
                        .i_weight(FOR_ROW[i-1].FOR_COL[j].w_weight),
                        .i_p_sum(FOR_ROW[i-1].FOR_COL[j].w_psum),
                        .i_data(in_data[((ROW - i)* (W_DATA + 1))-1 -: (W_DATA + 1)]),
                        .o_p_sum(o_partial_sum[((COL - j) * 32)-1 -: 32]),
                        .o_sel(o_select[(COL- j)-1 : 0]),
                        .o_data(o_data[((ROW - i) * (W_DATA + 1))-1 -: (W_DATA + 1)])
                    );
                    
                end else if (j == 0) begin//3
                    pe_block pe(
                        .i_clk(i_clk),
                        .i_sel(FOR_ROW[i-1].FOR_COL[j].w_select),
                        .i_weight(FOR_ROW[i-1].FOR_COL[j].w_weight),
                        .i_p_sum(FOR_ROW[i-1].FOR_COL[j].w_psum),
                        .i_data(in_data[((ROW - i)* (W_DATA + 1))-1 -: (W_DATA + 1)]),
                        .o_weight(w_weight),
                        .o_p_sum(w_psum),
                        .o_sel(w_select),
                        .o_data(o_data[((ROW - i) * (W_DATA + 1))-1 -: (W_DATA + 1)])
                    );
                end
            end else if( COL == 2) begin
             if (i == 0 && j == 0) begin//1 
                    top_pe_block pe(
                        .i_clk(i_clk),
                        .i_sel(i_sel),
                        .i_weight(i_weight[((COL - j)* W_DATA)-1 -: W_DATA]),
                        .i_data(in_data[((ROW - i)* (W_DATA + 1))-1 -: (W_DATA + 1)]),
                        .o_sel(w_select),
                        .o_weight(w_weight),
                        .o_p_sum(w_psum),
                        .o_data(w_data)
                    );
                    
                end else if(i == ROW - 1 && j == 0) begin//2
                    bottom_pe_block pe(
                        .i_clk(i_clk),
                        .i_sel(FOR_ROW[i-1].FOR_COL[j].w_select),
                        .i_weight(FOR_ROW[i-1].FOR_COL[j].w_weight),
                        .i_p_sum(FOR_ROW[i-1].FOR_COL[j].w_psum),
                        .i_data(in_data[((ROW - i)* (W_DATA + 1))-1 -: (W_DATA + 1)]),
                        .o_p_sum(o_partial_sum[((COL - j) * 32)-1 -: 32]),
                        .o_sel(o_select[(COL- j)-1 : 0]),
                        .o_data(w_data)
                    );
                    
                end else if (j == 0) begin//3
                    pe_block pe(
                        .i_clk(i_clk),
                        .i_sel(FOR_ROW[i-1].FOR_COL[j].w_select),
                        .i_weight(FOR_ROW[i-1].FOR_COL[j].w_weight),
                        .i_p_sum(FOR_ROW[i-1].FOR_COL[j].w_psum),
                        .i_data(in_data[((ROW - i)* (W_DATA + 1))-1 -: (W_DATA + 1)]),
                        .o_weight(w_weight),
                        .o_p_sum(w_psum),
                        .o_sel(w_select),
                        .o_data(w_data)
                    );
                end
                
                else if (i == 0 && j == COL - 1) begin//4
                top_pe_block pe(
                    .i_clk(i_clk),
                    .i_sel(i_sel),
                    .i_weight(i_weight[((COL - j)* W_DATA)-1 -: W_DATA]),
                    .i_data(FOR_ROW[i].FOR_COL[j-1].w_data),
                    .o_sel(w_select),
                    .o_weight(w_weight),
                    .o_p_sum(w_psum),
                    .o_data(o_data[((ROW - i)*  (W_DATA + 1))-1 -: (W_DATA + 1)])
                );
                    
                end else if ((i == ROW - 1) && (j == COL - 1)) begin//6
                bottom_pe_block pe(
                    .i_clk(i_clk),
                    .i_sel(FOR_ROW[i-1].FOR_COL[j].w_select),
                    .i_weight(FOR_ROW[i-1].FOR_COL[j].w_weight),
                    .i_p_sum(FOR_ROW[i-1].FOR_COL[j].w_psum),
                    .i_data(FOR_ROW[i].FOR_COL[j-1].w_data),
                    .o_p_sum(o_partial_sum[((COL - j) * 32)-1 -: 32]),
                    .o_sel(o_select[(COL- j)-1 : 0]),
                    .o_data(o_data[((ROW - i) * (W_DATA + 1))-1 -: (W_DATA + 1)])
                    );
                    
                end else if (j == COL - 1) begin //7
                pe_block pe(
                    .i_clk(i_clk),
                    .i_sel(FOR_ROW[i-1].FOR_COL[j].w_select),
                    .i_weight(FOR_ROW[i-1].FOR_COL[j].w_weight),
                    .i_p_sum(FOR_ROW[i-1].FOR_COL[j].w_psum),
                    .i_data(FOR_ROW[i].FOR_COL[j-1].w_data),
                    .o_weight(w_weight),
                    .o_p_sum(w_psum),
                    .o_sel(w_select),
                    .o_data(o_data[((ROW - i)* (W_DATA + 1))-1 -: (W_DATA + 1)])
                    ); 
                end
            end
        end
    end
    
endgenerate

endmodule