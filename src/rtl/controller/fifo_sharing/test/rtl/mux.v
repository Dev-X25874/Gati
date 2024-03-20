module mux#(
    parameter COL = 32,
    parameter W_DATA = 8,
    parameter N_SA_FC = 1,  //Number of engine in fully connected
    parameter N_SA_CNV = 4,  //Number of engines in convolution layer
    parameter W_ADDR = 8
)(
    input i_clk,
    input i_rst,
    input i_sel1,
    input i_sel2,
    input [(COL * (W_DATA + 1))-1 : 0] i_data,
    input [COL-1 : 0] i_empty,
    input [(COL * (W_ADDR + 1))-1: 0] i_occupants,
    output [(N_SA_FC * (COL * (W_DATA + 1)))-1 : 0] o_fc_data,
    output [(N_SA_FC * (COL * (W_ADDR + 1)))-1 : 0] o_fc_occ,
    output [(N_SA_FC * COL)-1 : 0] o_fc_empty,
    output [(N_SA_CNV * ((COL / 2) * (W_DATA + 1)))-1 : 0] o_sa_data,
    output [(N_SA_CNV * (COL / N_SA_CNV))-1 : 0] o_sa_empty,
    output [(N_SA_CNV * (((COL/2) / N_SA_CNV) * (W_ADDR + 1)))-1 : 0] o_sa_occ,
    output reg fc_data_valid = 0,   //For debug purpose only
    output reg sa_data_valid = 0    //For debug purpose only
);

reg [(N_SA_FC * (COL * (W_DATA + 1)))-1 : 0] fc_data = 0;
reg [(N_SA_FC * COL)-1 : 0] fc_empty = 1;
reg [(N_SA_FC * (COL * (W_ADDR + 1)))-1 : 0] fc_occ = 0;
reg [(N_SA_CNV * (COL / N_SA_CNV))-1 : 0] sa_empty = 1;
reg [(N_SA_CNV * ((COL / N_SA_CNV) * (W_ADDR + 1)))-1 : 0] sa_occ = 0;
reg [(N_SA_CNV * ((COL / 2) * (W_DATA + 1)))-1 : 0] sa_data = 0;

assign o_fc_data = fc_data;
assign o_fc_empty = fc_empty;
assign o_fc_occ = fc_occ;
assign o_sa_data = sa_data;
assign o_sa_occ = sa_occ;
assign o_sa_empty = sa_empty;

always @(posedge i_clk)begin
    if(i_rst)begin
        fc_data <= 0;
        fc_empty <= 1;
        fc_occ <= 0;
        sa_empty <= 1;
        sa_occ <= 0;
        sa_data <= 0;
        fc_data_valid <= 0;
    end else begin
        case (i_sel1)
            1'b0:begin  //Fully connected layer
                fc_data <= i_data;
                fc_occ <= i_occupants;
                fc_empty <= i_empty;
                fc_data_valid <= 1'b1;
            end
            
            1'b1: begin //Convolution layer
                case (i_sel2)
                    1'b0:begin  //32-17 set of north fifo
                        sa_data <= i_data[(N_SA_CNV * ((COL / N_SA_CNV) * (W_DATA + 1)))-1 -: (N_SA_CNV * ((((COL/2) / N_SA_CNV) * (W_DATA + 1))))];
                        sa_occ <= i_occupants[(N_SA_CNV * ((COL / N_SA_CNV) * (W_ADDR + 1)))-1 -: (N_SA_CNV * ((((COL/2) / N_SA_CNV) * (W_ADDR+1))))];
                        sa_empty <= i_empty[(N_SA_CNV * (COL / N_SA_CNV))-1 -: (N_SA_CNV * ((COL/2) / N_SA_CNV))];
                        sa_data_valid <= 1'b1;
                    end
                    
                    1'b1: begin //16-1 set of north fifo
                        sa_data <= i_data[(N_SA_CNV * ((((COL/2) / N_SA_CNV) * (W_DATA + 1))))-1 : 0];
                        sa_occ <= i_occupants[(N_SA_CNV * ((((COL/2) / N_SA_CNV) * (W_ADDR+1)))) : 0];
                        sa_empty <= i_empty[(N_SA_CNV * ((COL/2) / N_SA_CNV))-1 : 0];
                        sa_data_valid <= 1'b1;
                    end
                endcase
            end

            default: begin
                sa_data_valid <= 0;
                fc_data_valid <= 0;    
            end
        endcase
    end
end

endmodule 