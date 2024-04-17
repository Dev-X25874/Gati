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
        if(i_valid)begin
            if(flatten)begin
                data[255:248] <= i_data[255:248];   //C1E1
                data[247:240] <= i_data[247:240];   //C1E2
                data[239:232] <= i_data[239:232];   //C1E3
                data[231:224] <= i_data[231:224];   //C1E4
                data[223:216] <= i_data[127:120];   //C1E5
                data[215:208] <= i_data[119:112];   //C1E6
                data[207:200] <= i_data[111:104];   //C1E7
                data[199:192] <= i_data[103:96];    //C1E8
                data[191:184] <= i_data[223:216];   //C2E1
                data[183:176] <= i_data[215:208];   //C2E2
                data[175:168] <= i_data[207:200];   //C2E3
                data[167:160] <= i_data[199:192];   //C2E4
                data[159:152] <= i_data[95:88];     //C2E5
                data[151:144] <= i_data[87:80];     //C2E6
                data[143:136] <= i_data[79:72];     //C2E7
                data[135:128] <= i_data[71:64];     //C2E8
                data[127:120] <= i_data[191:184];   //C3E1
                data[119:112] <= i_data[183:176];   //C3E2
                data[111:104] <= i_data[175:168];   //C3E3
                data[103:96] <= i_data[167:160];    //C3E4
                data[95:88] <= i_data[63:56];       //C3E5
                data[87:80] <= i_data[55:48];       //C3E6
                data[79:72] <= i_data[47:40];       //C3E7
                data[71:64] <= i_data[39:32];       //C3E8
                data[63:56] <= i_data[159:152];     //C4E1
                data[55:48] <= i_data[151:144];     //C4E2
                data[47:40] <= i_data[143:136];     //C4E3
                data[39:32] <= i_data[135:128];     //C4E4
                data[31:24] <= i_data[31:24];       //C4E5
                data[23:16] <= i_data[23:16];       //C4E6
                data[15:8] <= i_data[15:8];         //C4E7
                data[7:0] <= i_data[7:0];           //C4E8
                valid <= 1'b1;
            end else begin
                data <= i_data;
                valid <= 1'b1;
            end
        end else begin
            data <= 0;
            valid <= 0;
        end
    end
end

endmodule