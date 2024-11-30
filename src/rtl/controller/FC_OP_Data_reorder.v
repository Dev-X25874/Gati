module FC_OP_Data_reorder#(
    parameter ACC_DW = 32,
    parameter COL_FC = 32,
    parameter ACC_DATA_REORDER = 1,
    parameter SHFT_REG_X = 4,
    parameter N_SA = 4,
    parameter DRAM_BW = 32
)
(
    input clk,
    input rst,
    input [(ACC_DW*COL_FC)-1:0] data_FC,
    input dv_FC,

    output reg [(ACC_DW*COL_FC)-1:0] reorder_data_FC,
    output reg o_dv_reorder
);
    wire [(ACC_DW*COL_FC)-1:0] temp_FC;

    always@(posedge clk) begin
        if(!rst) begin
            reorder_data_FC <= 0;
            o_dv_reorder <= 0;
        end
        else begin
            if(dv_FC) begin
                if(ACC_DATA_REORDER==0) begin
                    reorder_data_FC <= data_FC;
                    o_dv_reorder <= 1;
                end
                else begin
                    o_dv_reorder <= 1;
                    reorder_data_FC <= temp_FC;
                end

            end
            else begin
                reorder_data_FC <= reorder_data_FC;
                o_dv_reorder <= 0;
            end
        end
    end

  localparam OFFSET = N_SA;
  localparam UPPER_LOOP = N_SA;
  localparam LOWER_LOOP = (DRAM_BW/(SHFT_REG_X*N_SA));

    
  genvar i,j;
  generate
  for(i=0;i<UPPER_LOOP;i=i+1) begin
    for (j=0;j<LOWER_LOOP;j=j+1) begin
        localparam k = i * LOWER_LOOP + j;
        assign temp_FC[(((SHFT_REG_X*ACC_DW)*((DRAM_BW/SHFT_REG_X)- k))-1) -: SHFT_REG_X*ACC_DW] =
        data_FC[(((SHFT_REG_X*ACC_DW)*(((DRAM_BW/SHFT_REG_X)-i)-(j*OFFSET)))-1) -: SHFT_REG_X*ACC_DW];
    end
  end
  endgenerate

endmodule
