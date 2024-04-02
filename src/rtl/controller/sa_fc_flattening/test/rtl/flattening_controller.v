module flattening_controller#(
    parameter N_BANK = 4,
    parameter N_BRAM = 8,
    parameter W_DATA = 8
)(
    input clk,
    input rst,
    input [(N_BANK * N_BRAM)-1 : 0] i_valid,
    input flatten,
    input [((N_BANK * N_BRAM) * W_DATA)-1 : 0] i_data,
    output [((N_BANK * N_BRAM) * W_DATA)-1 : 0] o_data,
    output data_valid
);

reg valid = 0;
reg [1:0] state = 0;
reg [(W_DATA * (N_BANK * N_BRAM))-1 : 0] data = 0;
assign o_data = data;
assign data_valid = valid;

always @(posedge clk ) begin
    if(rst)begin
        data <= 0;        
        valid <= 0;
    end else begin
        case (state)
            0: begin
                valid <= 1'b0;
                data <= 0;
                if(i_valid)begin
                    if(flatten)
                        state <= 2;
                    else
                        state <= 1;
                end
                    
            end
            
            1:begin
                data <= i_data;
                valid <= 1'b1;
                state <= 0;
            end

            2: begin
                data[31:28] <= i_data[31:28];   //C1E1 - C1E4
                data[27:24] <= i_data[15:12];   //C1E5 - C1E8
                data[23:20] <= i_data[27:24];   //C2E1 - C2E4
                data[19:16] <= i_data[11:8];    //C2E5 - C2E8
                data[15:12] <= i_data[23:20];   //C3E1 - C3E4
                data[11:8] <= i_data[7:4];      //C3E5 - C3E8
                data[7:4] <= i_data[19:16];     //C4E1 - C4E4
                data[3:0] <= i_data[3:0];       //C4E5 - C4E8
                valid <= 1'b1;
                state <= 0;
            end

            default: state <= 0;
        endcase
    end
end

endmodule