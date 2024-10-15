/*
    Receives read enable signal from weight fifo array controller present in SA and FC.
    Further, this mux decides whether to send read enable signal of SA or FC into weight fifo array.
*/
module rden_mux#(
    parameter COL = 16,
    parameter COL_FC = 32,
    parameter N_SA = 4,
    parameter COL_SA = 4,
    parameter N_DRAM_BYTES = 32
)(
    input i_clk,
    input i_rstn,
    input [COL_FC-1 : 0] i_fc_rden,
    input [(N_SA * COL_SA)-1 : 0] i_sa_rden,
    input i_sel_1,
    input i_sel_2,
    output [COL-1 : 0] o_north_rden
);

reg [COL-1 : 0] north_rden = 0;
assign o_north_rden = north_rden;
/*
always @(posedge i_clk)begin
    if(~i_rstn)begin
        north_rden <= 0;
    end else begin
        case (i_sel_1)
            1'b0:begin  //Fully connected layer
                north_rden <= i_fc_rden;
            end
            1'b1: begin //Convolution layer
                if((N_SA * COL_SA) < N_DRAM_BYTES)begin
                    case (i_sel_2)
                        1'b1:begin  //First half of weight fifo array (starting from MSB)
                            north_rden <= {i_sa_rden, {(COL_SA * N_SA){1'b0}}};
                        end
                        1'b0: begin //Second half of weight fifo array
                            north_rden <= {{(COL_SA * N_SA){1'b0}}, i_sa_rden};
                        end 
                    endcase
                end else begin
                    north_rden <= i_sa_rden;
                end
            end
        endcase
    end
end
*/
always @(*)begin
    if(~i_rstn)begin
        north_rden = 0;
    end else begin
        case (i_sel_1)
            1'b0:begin  //Fully connected layer
                north_rden = i_fc_rden;
            end
            1'b1: begin //Convolution layer
                if((N_SA * COL_SA) < N_DRAM_BYTES)begin
                    case (i_sel_2)
                        1'b1:begin  //First half of weight fifo array (starting from MSB)
                            north_rden = {i_sa_rden, {(COL_SA * N_SA){1'b0}}};
                        end
                        1'b0: begin //Second half of weight fifo array
                            north_rden = {{(COL_SA * N_SA){1'b0}}, i_sa_rden};
                        end 
                    endcase
                end else begin
                    north_rden = i_sa_rden;
                end
            end
        endcase
    end
end
endmodule
