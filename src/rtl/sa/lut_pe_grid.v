/*
    Generates a grid of processing elements, wherein all the PE blocks
    uses multipliers generated with LUTs.
*/
module lut_pe_grid#(
    parameter COL = 1,
    parameter ROW = 1,
    parameter W_DATA = 8,
    parameter W_PSUM = 19
)(
    input i_clk,
    input i_rstn,
    input [(COL * (W_DATA + 1)) -1 : 0] i_weight,
    input [(ROW * (W_DATA + 1)) -1 : 0] in_data,
    output [(COL * (W_PSUM + 1))-1 : 0] o_partial_sum,
    output [(ROW * (W_DATA + 1))-1 : 0] o_data 
);

genvar i, j;
generate
    for(i = 0; i < ROW; i = i + 1)begin : FOR_ROW
        for(j = 0; j < COL; j = j + 1)begin : FOR_COL
            wire [W_PSUM : 0] w_psum;
            wire [W_DATA : 0] w_weight;
            wire w_select;
            wire [W_DATA:0] w_data;

            if(ROW == 1) begin
                if(COL == 1) begin
                    if(i == 0 && j == 0)begin
                        lut_bottom_pe_block#(
                            .W_PSUM(W_PSUM),
                            .W_DATA(W_DATA)
                        )bottom_pe(
                            .i_clk(i_clk),
                            .i_rstn(i_rstn),
                            .i_weight(i_weight[((COL - j) * (W_DATA + 1))-1 -: (W_DATA + 1)]),
                            .i_p_sum({(W_PSUM+1){1'b0}}),
                            .i_data(in_data[((ROW - i) * (W_DATA + 1))-1 -: (W_DATA + 1)]),
                            .o_data(o_data[((ROW - i) * (W_DATA + 1))-1 -: (W_DATA + 1)]),
                            .o_p_sum(o_partial_sum[((COL - j) * (W_PSUM + 1)) -1 -: (W_PSUM + 1)])
                        );
                    end //if(i == 0 && j == 0)
                end //if ROW = 1, COL = 1

                else if(COL == 2)begin
                    if(i == 0 && j == 0)begin
                        lut_bottom_pe_block#(
                            .W_PSUM(W_PSUM),
                            .W_DATA(W_DATA)
                        )bottom_pe(
                            .i_clk(i_clk),
                            .i_rstn(i_rstn),
                            .i_weight(i_weight[((COL - j) * (W_DATA + 1))-1 -: (W_DATA + 1)]),
                            .i_p_sum({(W_PSUM+1){1'b0}}),
                            .i_data(in_data[((ROW - i) * (W_DATA + 1))-1 -: (W_DATA + 1)]),
                            .o_data(w_data),
                            .o_p_sum(o_partial_sum[((COL - j) * (W_PSUM + 1)) -1 -: (W_PSUM + 1)])
                        );
                    end //if(i == 0 && j == 0)
                    
                    else if(i == 0 && j == COL-1)begin
                        lut_bottom_pe_block#(
                            .W_PSUM(W_PSUM),
                            .W_DATA(W_DATA)
                        )bottom_pe(
                            .i_clk(i_clk),
                            .i_rstn(i_rstn),
                            .i_weight(i_weight[((COL - j) * (W_DATA + 1))-1 -: (W_DATA + 1)]),
                            .i_p_sum({(W_PSUM+1){1'b0}}),
                            .i_data(FOR_ROW[i].FOR_COL[j-1].w_data),
                            .o_data(o_data[((ROW - i) * (W_DATA + 1))-1 -: (W_DATA + 1)]),
                            .o_p_sum(o_partial_sum[((COL - j) * (W_PSUM + 1)) -1 -: (W_PSUM + 1)])
                        );
                    end //if(i == 0 && j == COL-1)
                end //if ROW = 1, COL = 2 

                else begin
                    if(i == 0 && j == 0) begin
                        lut_bottom_pe_block#(
                            .W_PSUM(W_PSUM),
                            .W_DATA(W_DATA)
                        )bottom_pe(
                            .i_clk(i_clk),
                            .i_rstn(i_rstn),
                            .i_weight(i_weight[((COL - j) * (W_DATA + 1))-1 -: (W_DATA + 1)]),
                            .i_p_sum({(W_PSUM+1){1'b0}}),
                            .i_data(in_data[((ROW - i) * (W_DATA + 1))-1 -: (W_DATA + 1)]),
                            .o_data(w_data),
                            .o_p_sum(o_partial_sum[((COL - j) * (W_PSUM + 1)) -1 -: (W_PSUM + 1)])
                        );
                    end //if(i == 0 && j == 0)

                    else if(i == 0 && j == COL-1)begin
                        lut_bottom_pe_block#(
                            .W_PSUM(W_PSUM),
                            .W_DATA(W_DATA)
                        )bottom_pe(
                            .i_clk(i_clk),
                            .i_rstn(i_rstn),
                            .i_weight(i_weight[((COL - j) * (W_DATA + 1))-1 -: (W_DATA + 1)]),
                            .i_p_sum({(W_PSUM+1){1'b0}}),
                            .i_data(FOR_ROW[i].FOR_COL[j-1].w_data),
                            .o_data(o_data[((ROW - i) * (W_DATA + 1))-1 -: (W_DATA + 1)]),
                            .o_p_sum(o_partial_sum[((COL - j) * (W_PSUM + 1)) -1 -: (W_PSUM + 1)])
                        );
                    end //if(i == 0 && j == COL-1)

                    else if(i == 0 && j < COL-1)begin
                        lut_bottom_pe_block#(
                            .W_PSUM(W_PSUM),
                            .W_DATA(W_DATA)
                        )bottom_pe(
                            .i_clk(i_clk),
                            .i_rstn(i_rstn),
                            .i_weight(i_weight[((COL - j) * (W_DATA + 1))-1 -: (W_DATA + 1)]),
                            .i_p_sum({(W_PSUM+1){1'b0}}),
                            .i_data(FOR_ROW[i].FOR_COL[j-1].w_data),
                            .o_data(w_data),
                            .o_p_sum(o_partial_sum[((COL - j) * (W_PSUM + 1)) -1 -: (W_PSUM + 1)])
                        );
                    end //if(i == 0 && j < COL-1)
                end //if ROW = 1, COL > 2
            end //if ROW = 1 

            else begin
                if(COL > 2)begin
                    if(i == 0 && j == 0)begin
                        lut_top_pe_block#(
                            .W_PSUM(W_PSUM),
                            .W_DATA(W_DATA)
                        )pe(
                            .i_clk(i_clk),
                            .i_rstn(i_rstn),
                            .i_weight(i_weight[((COL - j)* (W_DATA +  1))-1 -: (W_DATA +  1)]),
                            .i_data(in_data[((ROW - i)* (W_DATA + 1))-1 -: (W_DATA + 1)]),
                            .o_weight(w_weight),
                            .o_p_sum(w_psum),
                            .o_data(w_data)
                        );
                    end //if(i == 0 && j == 0)

                    else if(i == ROW-1 && j == 0)begin
                        lut_bottom_pe_block#(
                            .W_PSUM(W_PSUM),
                            .W_DATA(W_DATA)
                        )pe(
                            .i_clk(i_clk),
                            .i_rstn(i_rstn),
                            .i_weight(FOR_ROW[i-1].FOR_COL[j].w_weight),
                            .i_p_sum(FOR_ROW[i-1].FOR_COL[j].w_psum),
                            .i_data(in_data[((ROW - i)* (W_DATA + 1))-1 -: (W_DATA + 1)]),
                            .o_p_sum(o_partial_sum[((COL - j) * (W_PSUM +  1))-1 -: (W_PSUM +  1)]),
                            .o_data(w_data)
                        );
                    end //if(i == ROW-1 && j == 0)

                    else if(j == 0)begin
                        lut_pe_block#(
                            .W_PSUM(W_PSUM),
                            .W_DATA(W_DATA)
                        )pe(
                            .i_clk(i_clk),
                            .i_rstn(i_rstn),
                            .i_weight(FOR_ROW[i-1].FOR_COL[j].w_weight),
                            .i_p_sum(FOR_ROW[i-1].FOR_COL[j].w_psum),
                            .i_data(in_data[((ROW - i)* (W_DATA + 1))-1 -: (W_DATA + 1)]),
                            .o_weight(w_weight),
                            .o_p_sum(w_psum),
                            .o_data(w_data)
                        );
                    end //if(j == 0)

                    else if(i == 0 && j == COL-1)begin
                        lut_top_pe_block#(
                            .W_PSUM(W_PSUM),
                            .W_DATA(W_DATA)
                        )pe(
                            .i_clk(i_clk),
                            .i_rstn(i_rstn),
                            .i_weight(i_weight[((COL - j)* (W_DATA +  1))-1 -: (W_DATA +  1)]),
                            .i_data(FOR_ROW[i].FOR_COL[j-1].w_data),
                            .o_weight(w_weight),
                            .o_p_sum(w_psum),
                            .o_data(o_data[((ROW - i)*  (W_DATA + 1))-1 -: (W_DATA + 1)])
                        );
                    end //if(i == 0 && j == COL-1)

                    else if(i == 0)begin
                        lut_top_pe_block#(
                            .W_PSUM(W_PSUM),
                            .W_DATA(W_DATA)
                        )pe(
                            .i_clk(i_clk),
                            .i_rstn(i_rstn),
                            .i_weight(i_weight[((COL - j)* (W_DATA +  1))-1 -: (W_DATA +  1)]),
                            .i_data(FOR_ROW[i].FOR_COL[j-1].w_data),
                            .o_weight(w_weight),
                            .o_p_sum(w_psum),
                            .o_data(w_data)
                        );
                    end //if(i == 0)

                    else if((i == ROW-1) && (j == COL-1))begin
                        lut_bottom_pe_block#(
                            .W_PSUM(W_PSUM),
                            .W_DATA(W_DATA)
                        )pe(
                            .i_clk(i_clk),
                            .i_rstn(i_rstn),
                            .i_weight(FOR_ROW[i-1].FOR_COL[j].w_weight),
                            .i_p_sum(FOR_ROW[i-1].FOR_COL[j].w_psum),
                            .i_data(FOR_ROW[i].FOR_COL[j-1].w_data),
                            .o_p_sum(o_partial_sum[((COL - j) * (W_PSUM +  1))-1 -: (W_PSUM +  1)]),
                            .o_data(o_data[((ROW - i) * (W_DATA + 1))-1 -: (W_DATA + 1)])
                        );
                    end //if((i == ROW-1) && (j == COL-1))

                    else if(j == COL-1)begin
                        lut_pe_block#(
                            .W_PSUM(W_PSUM),
                            .W_DATA(W_DATA)
                        )pe(
                            .i_clk(i_clk),
                            .i_rstn(i_rstn),
                            .i_weight(FOR_ROW[i-1].FOR_COL[j].w_weight),
                            .i_p_sum(FOR_ROW[i-1].FOR_COL[j].w_psum),
                            .i_data(FOR_ROW[i].FOR_COL[j-1].w_data),
                            .o_weight(w_weight),
                            .o_p_sum(w_psum),
                            .o_data(o_data[((ROW - i)* (W_DATA + 1))-1 -: (W_DATA + 1)])
                        );
                    end //if(j == COL-1)

                    else if(i == ROW-1)begin
                        lut_bottom_pe_block#(
                            .W_PSUM(W_PSUM),
                            .W_DATA(W_DATA)
                        )pe(
                            .i_clk(i_clk),
                            .i_rstn(i_rstn),
                            .i_weight(FOR_ROW[i-1].FOR_COL[j].w_weight),
                            .i_p_sum(FOR_ROW[i-1].FOR_COL[j].w_psum),
                            .i_data(FOR_ROW[i].FOR_COL[j-1].w_data),
                            .o_p_sum(o_partial_sum[((COL - j) * (W_PSUM +  1))-1 -: (W_PSUM +  1)]),
                            .o_data(w_data)
                        );
                    end //if(i == ROW-1)

                    else begin
                        lut_pe_block#(
                            .W_PSUM(W_PSUM),
                            .W_DATA(W_DATA)
                        )pe(
                            .i_clk(i_clk),
                            .i_rstn(i_rstn),
                            .i_weight(FOR_ROW[i-1].FOR_COL[j].w_weight),
                            .i_p_sum(FOR_ROW[i-1].FOR_COL[j].w_psum),
                            .i_data(FOR_ROW[i].FOR_COL[j-1].w_data),
                            .o_weight(w_weight),
                            .o_p_sum(w_psum),
                            .o_data(w_data)
                        );
                    end
                end //if ROW > 1, COL > 2

                else if(COL == 2) begin
                    if(i == 0 && j == 0)begin
                        lut_top_pe_block#(
                            .W_PSUM(W_PSUM),
                            .W_DATA(W_DATA)
                        )pe(
                            .i_clk(i_clk),
                            .i_rstn(i_rstn),
                            .i_weight(i_weight[((COL - j)* (W_DATA +  1))-1 -: (W_DATA +  1)]),
                            .i_data(in_data[((ROW - i)* (W_DATA + 1))-1 -: (W_DATA + 1)]),
                            .o_weight(w_weight),
                            .o_p_sum(w_psum),
                            .o_data(w_data)
                        );
                    end //if(i == 0 && j == 0)

                    else if(i == ROW-1 && j == 0)begin
                        lut_bottom_pe_block#(
                            .W_PSUM(W_PSUM),
                            .W_DATA(W_DATA)
                        )pe(
                            .i_clk(i_clk),
                            .i_rstn(i_rstn),
                            .i_weight(FOR_ROW[i-1].FOR_COL[j].w_weight),
                            .i_p_sum(FOR_ROW[i-1].FOR_COL[j].w_psum),
                            .i_data(in_data[((ROW - i)* (W_DATA + 1))-1 -: (W_DATA + 1)]),
                            .o_p_sum(o_partial_sum[((COL - j) * (W_PSUM +  1))-1 -: (W_PSUM +  1)]),
                            .o_data(w_data)
                        );
                    end //if(i == ROW-1 && j == 0)

                    else if(j == 0)begin
                        lut_pe_block#(
                            .W_PSUM(W_PSUM),
                            .W_DATA(W_DATA)
                        )pe(
                            .i_clk(i_clk),
                            .i_rstn(i_rstn),
                            .i_weight(FOR_ROW[i-1].FOR_COL[j].w_weight),
                            .i_p_sum(FOR_ROW[i-1].FOR_COL[j].w_psum),
                            .i_data(in_data[((ROW - i)* (W_DATA + 1))-1 -: (W_DATA + 1)]),
                            .o_weight(w_weight),
                            .o_p_sum(w_psum),
                            .o_data(w_data)
                        );
                    end
                
                    else if(i == 0 && j == COL-1)begin
                        lut_top_pe_block#(
                            .W_PSUM(W_PSUM),
                            .W_DATA(W_DATA)
                        )pe(
                            .i_clk(i_clk),
                            .i_rstn(i_rstn),
                            .i_weight(i_weight[((COL - j)* (W_DATA +  1))-1 -: (W_DATA +  1)]),
                            .i_data(FOR_ROW[i].FOR_COL[j-1].w_data),
                            .o_weight(w_weight),
                            .o_p_sum(w_psum),
                            .o_data(o_data[((ROW - i)*  (W_DATA + 1))-1 -: (W_DATA + 1)])
                        );
                    end //if(i == 0 && j == COL-1)
                    
                    else if((i == ROW-1) && (j == COL-1))begin
                        lut_bottom_pe_block#(
                            .W_PSUM(W_PSUM),
                            .W_DATA(W_DATA)
                        )pe(
                            .i_clk(i_clk),
                            .i_rstn(i_rstn),
                            .i_weight(FOR_ROW[i-1].FOR_COL[j].w_weight),
                            .i_p_sum(FOR_ROW[i-1].FOR_COL[j].w_psum),
                            .i_data(FOR_ROW[i].FOR_COL[j-1].w_data),
                            .o_p_sum(o_partial_sum[((COL - j) * (W_PSUM +  1))-1 -: (W_PSUM +  1)]),
                            .o_data(o_data[((ROW - i) * (W_DATA + 1))-1 -: (W_DATA + 1)])
                        );
                    end //if((i == ROW-1) && (j == COL-1))
                    
                    else if(j == COL-1)begin
                        lut_pe_block#(
                            .W_PSUM(W_PSUM),
                            .W_DATA(W_DATA)
                        )pe(
                            .i_clk(i_clk),
                            .i_rstn(i_rstn),
                            .i_weight(FOR_ROW[i-1].FOR_COL[j].w_weight),
                            .i_p_sum(FOR_ROW[i-1].FOR_COL[j].w_psum),
                            .i_data(FOR_ROW[i].FOR_COL[j-1].w_data),
                            .o_weight(w_weight),
                            .o_p_sum(w_psum),
                            .o_data(o_data[((ROW - i)* (W_DATA + 1))-1 -: (W_DATA + 1)])
                        ); 
                    end //if(j == COL-1)
                end //if ROW > 1, COL = 2

                else if(COL == 1)begin
                    if(i == 0 && j == 0)begin
                        lut_top_pe_block#(
                            .W_PSUM(W_PSUM),
                            .W_DATA(W_DATA)
                        )pe(
                            .i_clk(i_clk),
                            .i_rstn(i_rstn),
                            .i_weight(i_weight[((COL - j)* (W_DATA +  1))-1 -: (W_DATA +  1)]),
                            .i_data(in_data[((ROW - i)* (W_DATA + 1))-1 -: (W_DATA + 1)]),
                            .o_weight(w_weight),
                            .o_p_sum(w_psum),
                            .o_data(o_data[((ROW - i) * (W_DATA + 1))-1 -: (W_DATA + 1)])
                        );
                    end //if(i == 0 && j == 0)

                    else if(i == ROW-1 && j == 0)begin
                        lut_bottom_pe_block#(
                            .W_PSUM(W_PSUM),
                            .W_DATA(W_DATA)
                        )pe(
                            .i_clk(i_clk),
                            .i_rstn(i_rstn),
                            .i_weight(FOR_ROW[i-1].FOR_COL[j].w_weight),
                            .i_p_sum(FOR_ROW[i-1].FOR_COL[j].w_psum),
                            .i_data(in_data[((ROW - i)* (W_DATA + 1))-1 -: (W_DATA + 1)]),
                            .o_p_sum(o_partial_sum[((COL - j) * (W_PSUM +  1))-1 -: (W_PSUM +  1)]),
                            .o_data(o_data[((ROW - i) * (W_DATA + 1))-1 -: (W_DATA + 1)])
                        );
                    end //if(i == ROW-1 && j == 0)

                    else if (j == 0) begin
                        lut_pe_block#(
                            .W_PSUM(W_PSUM),
                            .W_DATA(W_DATA)
                        )pe(
                            .i_clk(i_clk),
                            .i_rstn(i_rstn),
                            .i_weight(FOR_ROW[i-1].FOR_COL[j].w_weight),
                            .i_p_sum(FOR_ROW[i-1].FOR_COL[j].w_psum),
                            .i_data(in_data[((ROW - i)* (W_DATA + 1))-1 -: (W_DATA + 1)]),
                            .o_weight(w_weight),
                            .o_p_sum(w_psum),
                            .o_data(o_data[((ROW - i) * (W_DATA + 1))-1 -: (W_DATA + 1)])
                        );
                    end //if(j == 0)
                end //if ROW > 1, COL = 1
            end //if ROW > 1
        end //for(j = 0; j < COL; j = j + 1)
    end //for(i = 0; i < ROW; i = i + 1)
endgenerate

endmodule
