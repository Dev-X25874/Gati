module FC_OP_Data_reorder#(
    parameter ACC_DW = 32,
    parameter COL_FC = 32,
    parameter ACC_DATA_REORDER = 1
)
(
    input clk,
    input rst,
    input [(ACC_DW*COL_FC)-1:0] data_FC,
    input dv_FC,

    output reg [(ACC_DW*COL_FC)-1:0] reorder_data_FC,
    output reg o_dv_reorder
);

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
                    // reorder_data_FC <=
                    //     {
                    //      reorder_data_FC[1023:896] <= data_FC[1023:896];
                    //      reorder_data_FC[895:768]  <= data_FC[511:384];
                    //      reorder_data_FC[767:640]  <= data_FC[895:768];
                    //      reorder_data_FC[639:512]  <= data_FC[383:256];
                    //      reorder_data_FC[511:384]  <= data_FC[767:640];
                    //      reorder_data_FC[383:256]  <= data_FC[255:128];
                    //      reorder_data_FC[255:128]  <= data_FC[639:512];
                    //      reorder_data_FC[127:0]    <= data_FC[127:0];
                    //     };
                    reorder_data_FC <=
                        {
                         data_FC[1023:896],
                         data_FC[511:384],
                         data_FC[895:768],
                         data_FC[383:256],
                         data_FC[767:640],
                         data_FC[255:128],
                         data_FC[639:512],
                         data_FC[127:0]
                        };
                    o_dv_reorder <= 1;
                end

            end
            else begin
                reorder_data_FC <= reorder_data_FC;
                o_dv_reorder <= 0;
            end
        end
    end

endmodule